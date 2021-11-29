#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""This script builds a multilingual forrest site.

--destination (-d) an ssh destination
--sitehome (-s) where sd and techdoc lives
"""

import argparse
import collections
import datetime
import fileinput
import glob
import logging
import os
import re
import shutil
import subprocess

import lxml.etree as etree

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)


class StaticSiteBuilder(object):
    """Class to build a multilingual static version of the divvun site.

    Attributes:
        sitehome (str): The directory where the forrest site is
        destination (str): where the built site is copied (using rsync)
        langs (list): list of langs to be built
        logfile (file handle)
    """

    def __init__(self, sitehome, destination, langs):
        """Init StaticSiteBuilder with sitehome, destination and langs.

        Args:
            sitehome (str):     The directory where the forrest site is
            destination (str):  Where the built site is copied (using rsync)
            langs (list):       List of langs to be built

        """
        if sitehome.endswith("/"):

            sitehome = sitehome[:-1]
        self.sitehome = sitehome
        if not destination.endswith("/"):
            destination = destination + "/"
        self.destination = destination
        self.mainlang = langs[0]
        self.langs = langs[1:]
        if os.path.isdir(os.path.join(self.sitehome, "built")):
            shutil.rmtree(os.path.join(self.sitehome, "built"))

        os.mkdir(os.path.join(self.sitehome, "built"))

    def __enter__(self):
        """Open a lock file."""
        lockname = os.path.join(self.sitehome, ".lock")

        if os.path.exists(lockname):
            with open(lockname) as lock:
                logger.warn(
                    "Another build with PID {} has been running "
                    "since {}".format(
                        lock.read(),
                        datetime.datetime.fromtimestamp(os.path.getmtime(lockname)),
                    )
                )
                raise SystemExit(5)

        self.lockfile = open(lockname, "w")
        self.lockfile.write(str(os.getpid()))
        self.lockfile.flush()

        return self

    def __exit__(self, *args):
        """Close the lockfile and remove the lockfile."""
        self.lockfile.close()
        os.remove(os.path.join(self.sitehome, ".lock"))

    def clean(self):
        """Run forrest clean."""
        (returncode, _) = self.run_command("forrest validate")
        if returncode != 0:
            logger.warn("forrest clean failed in {}".format(self.sitehome))
            raise SystemExit(returncode)

    def validate(self):
        """Run forrest validate."""
        (returncode, _) = self.run_command("forrest validate")
        if returncode != 0:
            logger.warn("Invalid xml files found, site was not built")
            raise SystemExit(returncode)

    def set_forrest_lang(self, lang):
        """Set the language that should be built.

        Args:
            lang (str): a two or three character long string
        """
        logger.debug("Setting language {}".format(lang))
        for line in fileinput.FileInput(
            os.path.join(self.sitehome, "forrest.properties"), inplace=1
        ):
            if "forrest.jvmargs" in line:
                line = (
                    "forrest.jvmargs=-Djava.awt.headless=true "
                    "-Dfile.encoding=utf-8 -Duser.language={}".format(lang)
                )
            if "project.i18n" in line:
                line = "project.i18n=true"
            print(line.rstrip())

    def parse_broken_links(self):
        """Parse brokenlinks.xml.

        Since the xml file is not valid xml, do plain text parsing
        """
        counter = collections.Counter()
        for line in fileinput.FileInput(
            os.path.join(self.sitehome, "build", "tmp", "brokenlinks.xml")
        ):
            if "<link" in line and "</link>" in line:
                if "tca2testing" in line:
                    counter["tca2testing"] += 1
                else:
                    counter["broken"] += 1
                    line = line.strip().replace('<link message="', "")
                    line = line.replace("</link>", "")

                    message = line[: line.rfind('"')]
                    text = line[line.rfind(">") + 1 :]
                    logger.error(
                        "{message}: {text}\n".format(message=message, text=text)
                    )
            elif "<link" in line:
                line = line.strip().replace('<link message="', "")
                logger.error("{message}".format(message=line))
            elif "</link>" in line:
                counter["broken"] += 1
                line = line.strip().replace("</link>", "")

                message = line[: line.rfind('"')]
                text = line[line.rfind(">") + 1 :]
                logger.error("{message}: {text}\n".format(message=message, text=text))

        for name, number in list(counter.items()):
            if "tca2" in name:
                logger.error(name)
            logger.error("{} broken links".format(number))

    def parse_buildtimes(self, log):
        """Parse the buildtimes found in the logfile."""

        def print_buildtime_distribution(buildtimes):
            def make_info(build_time, buildtimes):
                return "{time}: {infolist}".format(
                    time=datetime.timedelta(seconds=build_time),
                    infolist=", ".join(
                        " ".join(info_item) for info_item in buildtimes[build_time]
                    ),
                )

            logger.info("\nDistribution of build times")
            logger.info("approx seconds: number of links")
            for build_time in sorted(buildtimes, reverse=True):
                if len(buildtimes[build_time]) < 10:
                    logger.info(make_info(build_time, buildtimes))
                else:
                    logger.info(
                        "{}s: {}".format(build_time, len(buildtimes[build_time]))
                    )

        buildline = re.compile("^\* \[\d+/\d+\].+Kb.+/.+")
        buildtimes = collections.defaultdict(list)
        info = collections.namedtuple("info", ["link", "size"])

        for line in log.split("\n"):
            try:
                if buildline.match(line):
                    parts = line.split()
                    seconds = int(parts[-3].split(".")[0])
                    buildtimes[seconds].append(info(link=parts[-1], size=parts[-2]))
            except ValueError as error:
                logger.info(
                    "Error parsing buildtimes.\n"
                    "Line: {}\n"
                    "Error: {}\n".format(line, str(error))
                )

        print_buildtime_distribution(buildtimes)

    def buildsite(self, lang):
        """Build a site in the specified language.

        Clean up the build files
        Validate files. If they don't validate, exit program
        Build site. stdout and stderr are stored in output and error,
        respectively.
        If we aren't able to rename the built site, exit program

        Args:
            lang (str): a two or three character long string
        """
        logger.debug("Building {}".format(lang))
        os.environ["LC_ALL"] = "en_US.UTF-8"

        self.set_forrest_lang(lang)

        before = datetime.datetime.now()
        (_, output) = self.run_command("forrest site")
        logger.info(
            "Building {} lasted {}".format(lang, datetime.datetime.now() - before)
        )

        self.parse_buildtimes(output)
        self.parse_broken_links()

    def files_to_collect(self, builddir, extension):
        """Search for files with extension in builddir.

        Args:
            builddir (str): the directory where interesting files are.
            extension (str): interesting files has this extension.

        Yields:
            str: path to the interesting file
        """
        for root, _, files in os.walk(builddir):
            if "ckeditor" not in root:
                for f in files:
                    if f.endswith(extension):
                        yield os.path.join(root, f)

    def add_language_changer(self, this_lang):
        """Add a language changer in all .html files for one language.

        Args:
            this_lang (str): a two or three character long string
        """
        builddir = self.builddir

        for path in self.files_to_collect(builddir, ".html"):
            f2b = LanguageAdder(path, this_lang, self.mainlang, self.langs, builddir)
            f2b.add_lang_info()

    @property
    def builddir(self):
        site = os.path.join(self.sitehome, "build/site")
        builddir = (
            site
            if os.path.isfile(os.path.join(site, "index.html"))
            else os.path.join(site, "en")
        )
        return builddir

    def rename_site_files(self, lang):
        """Search for files ending with html and pdf in the build site.

        Give all these files the ending '.lang'.
        Move them to the 'built' dir

        Args:
            lang (str): a two or three character long string
        """
        builtdir = (
            os.path.join(self.sitehome, "built")
            if lang == self.mainlang
            else os.path.join(self.sitehome, "built", lang)
        )

        self.copy_ckeditor()
        for item in glob.glob(self.builddir + "/*"):
            shutil.copytree(item, builtdir)
            shutil.rmtree(item)

    def build_all_langs(self):
        """Build all the langs."""
        logger.info("Building all langs")
        for lang in self.langs + [self.mainlang]:
            self.buildsite(lang)
            if self.langs:
                self.add_language_changer(lang)
            self.rename_site_files(lang)

    def run_command(self, command):
        """Run a shell command.

        Arguments:
            command: string containing the shell command
        """
        logger.info("Running {}".format(command))
        subp = subprocess.Popen(
            command.split(),
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            cwd=self.sitehome,
        )

        (output, error) = subp.communicate()

        output = output.decode("utf8")
        error = error.decode("utf8")
        if subp.returncode != 0:
            logger.error("{} finished with errors".format(command))
            logger.error("stdout")
            for line in output.split("\n"):
                logger.error(line)
            logger.error("stderr")
            for line in error.split("\n"):
                logger.error(line)
        else:
            logger.info("{} finished without errors".format(command))
            logger.debug("stdout")
            logger.debug(output)
            logger.debug("stderr")
            logger.debug(error)

        return (subp.returncode, output)

    def copy_ckeditor(self):
        """Copy the ckeditor to the built version of the site."""
        ckdir = os.path.join(self.sitehome, "src/documentation/resources/ckeditor")
        if os.path.exists(ckdir):
            returncode, _ = self.run_command(
                "rsync -av {src} {dst}".format(
                    src=ckdir, dst=os.path.join(self.sitehome, self.builddir)
                )
            )
            if returncode != 0:
                raise SystemExit(returncode)

    def copy_to_site(self):
        """Copy the entire site to self.destination."""
        if "techdoc" in self.sitehome and "commontec" not in self.sitehome:
            offending_file = os.path.join(self.sitehome, "built", "index.html")
            if os.path.exists(offending_file):
                os.remove(offending_file)
        (returncode, _) = self.run_command(
            "rsync -avz -e ssh {src} {dst}".format(
                src=os.path.join(self.sitehome, "built/"), dst=self.destination
            )
        )
        if returncode != 0:
            raise SystemExit(returncode)


class LanguageAdder(object):
    """Add a language changer to an html document.

    Attributes:
        filename (str):     path to the html file
        this_lang (str):     The language of this document
        langs (list):   The list of all languages that should added to the
                        language element
        builddir (str): The basedir where the html files are found
        namespace (dict):   the namespace used in the html document
        tree (lxml etree):  an lxml etree of the parsed file
    """

    namespace = {"html": "http://www.w3.org/1999/xhtml"}

    def __init__(self, filename, this_lang, mainlang, langs, builddir):
        """Init the LanguageAdder.

        Args:
            filename (str):     path to the html file
            this_lang (str):     The language of this document
            langs (list):   The list of all languages that should added to the
                            language element
            builddir (str): The basedir where the html files are found
        """
        self.filename = filename
        self.this_lang = this_lang
        self.mainlang = mainlang
        self.langs = langs
        self.builddir = builddir

        self.tree = etree.parse(filename, etree.HTMLParser())

    def __del__(self):
        """Write self.tree to self.filename."""
        with open(self.filename, "w") as outhtml:
            outhtml.write(
                etree.tostring(
                    self.tree, encoding="unicode", pretty_print=True, method="html"
                )
            )

    def add_lang_info(self):
        """Create the language navigation element and add it to self.tree."""
        my_nav_bar = self.tree.getroot().find(
            './/ul[@class="navbar-nav"]', namespaces=self.namespace
        )
        my_nav_bar.append(self.make_lang_menu())

    def make_lang_menu(self):
        """Make the language menu for self.this_lang."""
        trlangs = {
            "fi": "Suomeksi",
            "no": "På norsk",
            "sma": "Åarjelsaemien",
            "se": "Davvisámegillii",
            "smj": "Julevsábmáj",
            "sv": "På svenska",
            "en": "In English",
            "ru": "на русском",
        }

        right_menu = etree.Element("li")
        right_menu.set("class", "nav-item dropdown")

        dropdown = etree.SubElement(right_menu, "a")
        dropdown.set("aria-expanded", "false")
        dropdown.set("aria-haspopup", "true")
        dropdown.set("data-toggle", "dropdown")
        dropdown.set("class", "nav-link dropdown-toggle")
        dropdown.set("href", "#")
        dropdown.text = "Change language"

        dropdown_toggle = etree.SubElement(right_menu, "div")
        dropdown_toggle.set("aria-labelledby", "navbarDropdownMenuLink")
        dropdown_toggle.set("class", "dropdown-menu")

        for lang in self.langs + [self.mainlang]:
            if lang != self.this_lang:
                a = etree.SubElement(dropdown_toggle, "a")
                a.set("class", "dropdown-item")
                if lang != self.mainlang:
                    filename = "/" + lang + self.filename.replace(self.builddir, "")
                else:
                    filename = self.filename.replace(self.builddir, "")
                a.set("href", filename)
                a.text = trlangs[lang]

        return right_menu


def parse_options():
    """Parse command line options."""
    parser = argparse.ArgumentParser(
        description="This script builds a multilingual forrest site."
    )
    parser.add_argument("--destination", "-d", help="an ssh destination", required=True)
    parser.add_argument(
        "--sitehome", "-s", help="where the forrest site lives", required=True
    )
    parser.add_argument(
        "--verbosity",
        "-V",
        help="Set the logger level, default is warning\n"
        "The allowed values are: warning, info, debug\n"
        "Default is info.",
        default="info",
    )
    parser.add_argument(
        "langs",
        help="list of languages, the first one becomes the default language",
        nargs="+",
    )

    args = parser.parse_args()
    return args


def main():
    """Build a forrest site, copy the static site to its destination."""
    logging_dict = {
        "info": logging.INFO,
        "warning": logging.WARNING,
        "debug": logging.DEBUG,
    }
    args = parse_options()

    if args.verbosity in list(logging_dict.keys()):
        if args.verbosity == "debug":
            logging.info("Logging level is set to debug. Output will very verbose")
        logger.setLevel(logging_dict[args.verbosity])
    else:
        raise SystemExit(
            "-V|--verbosity must be one of: {}\n{} was given.".format(
                "|".join(list(logging_dict.keys())), args.verbosity
            )
        )

    with StaticSiteBuilder(args.sitehome, args.destination, args.langs) as builder:
        builder.clean()
        builder.build_all_langs()
        builder.copy_to_site()


if __name__ == "__main__":
    main()
