#!/usr/bin/env python
# -*- coding: utf-8 -*-

'''This script builds a multilingual forrest site.
--destination (-d) an ssh destination
--sitehome (-s) where sd and techdoc lives
'''
from __future__ import absolute_import
from __future__ import print_function

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
    '''Class to build a multilingual static version of the divvun site.

    Args:
        builddir (str):     The directory where the forrest site is
        destination (str):  Where the built site is copied (using rsync)
        langs (list):       List of langs to be built

    Attributes:
        builddir (str): The directory where the forrest site is
        destination (str): where the built site is copied (using rsync)
        langs (list): list of langs to be built
        logfile (file handle)
    '''

    def __init__(self, builddir, destination, langs):
        if builddir.endswith('/'):
            builddir = builddir[:-1]
        self.builddir = builddir
        self.clean()

        if not destination.endswith('/'):
            destination = destination + '/'
        self.destination = destination
        self.langs = langs
        if os.path.isdir(os.path.join(self.builddir, 'built')):
            shutil.rmtree(os.path.join(self.builddir, 'built'))

        os.mkdir(os.path.join(self.builddir, 'built'))

    def clean(self):
        (returncode, _) = self.run_command('forrest validate')
        if returncode != 0:
            logger.warn('forrest clean failed in {}'.format(self.builddir))
            raise SystemExit(returncode)

    def validate(self):
        '''Run forrest validate'''
        (returncode, _) = self.run_command('forrest validate')
        if returncode != 0:
            logger.warn('Invalid xml files found, site was not built')
            raise SystemExit(returncode)

    def set_forrest_lang(self, lang):
        '''Set the language that should be built

        Args:
            lang (str): a two or three character long string
        '''
        logger.debug('Setting language {}'.format(lang))
        for line in fileinput.FileInput(
            os.path.join(self.builddir, 'forrest.properties'),
                inplace=1):
            if 'forrest.jvmargs' in line:
                line = (
                    'forrest.jvmargs=-Djava.awt.headless=true '
                    '-Dfile.encoding=utf-8 -Duser.language={}'.format(lang)
                )
            if 'project.i18n' in line:
                line = 'project.i18n=true'
            print(line.rstrip())

    def parse_broken_links(self):
        '''Parse brokenlinks.xml

        Since the xml file is not valid xml, do plain text parsing
        '''
        logger.error('Broken links:')

        counter = collections.Counter()
        for line in fileinput.FileInput(os.path.join(self.builddir, 'build',
                                                     'tmp',
                                                     'brokenlinks.xml')):
            if '<link' in line and '</link>' in line:
                if 'tca2testing' in line:
                    counter['tca2testing'] += 1
                else:
                    counter['broken'] += 1
                    line = line.strip().replace('<link message="', '')
                    line = line.replace('</link>', '')

                    message = line[:line.rfind('"')]
                    text = line[line.rfind('>') + 1:]
                    logger.error('{message}: {text}\n'.format(
                        message=message, text=text))
            elif '<link' in line:
                line = line.strip().replace('<link message="', '')
                logger.error('{message}'.format(message=line))
            elif '</link>' in line:
                counter['broken'] += 1
                line = line.strip().replace('</link>', '')

                message = line[:line.rfind('"')]
                text = line[line.rfind('>') + 1:]
                logger.error('{message}: {text}\n'.format(message=message,
                                                          text=text))

        for name, number in counter.items():
            if 'tca2' in name:
                logger.error(name)
            logger.error('{} broken links'.format(number))

    def parse_buildtimes(self, log):
        def print_buildtime_distribution(buildtimes):
            def make_info(build_time, buildtimes):
                return '{time}: {infolist}'.format(
                    time=datetime.timedelta(seconds=build_time),
                    infolist=', '.join(
                        ' '.join(info_item)
                        for info_item in buildtimes[build_time]))

            logger.info('\nDistribution of build times')
            logger.info('approx seconds: number of links')
            for build_time in sorted(buildtimes, reverse=True):
                if len(buildtimes[build_time]) < 10:
                    logger.info(make_info(build_time, buildtimes))
                else:
                    logger.info('{}s: {}'.format(
                        build_time, len(buildtimes[build_time])))

        buildline = re.compile('^\* \[\d+/\d+\].+Kb.+/.+')
        buildtimes = collections.defaultdict(list)
        info = collections.namedtuple('info', ['link', 'size'])

        for line in log.split('\n'):
            if buildline.match(line):
                parts = line.split()
                seconds = int(parts[-3].split('.')[0])
                buildtimes[seconds].append(info(link=parts[-1],
                                                size=parts[-2]))
        print_buildtime_distribution(buildtimes)

    def buildsite(self, lang):
        '''Builds a site in the specified language

        Clean up the build files
        Validate files. If they don't validate, exit program
        Build site. stdout and stderr are stored in output and error,
        respectively.
        If we aren't able to rename the built site, exit program

        Args:
            lang (str): a two or three character long string
        '''
        # This ensures that the build directory is build/site/en
        logger.debug('Building {}'.format(lang))
        os.environ['LC_ALL'] = 'C'

        self.set_forrest_lang(lang)

        before = datetime.datetime.now()
        (_, output) = self.run_command('forrest site')
        logger.info('Building {} lasted {}'.format(
            lang, datetime.datetime.now() - before))

        self.parse_buildtimes(output)
        self.parse_broken_links()

    def add_language_changer(self, this_lang):
        '''Add a language changer in all .html files for one language

        Args:
            this_lang (str): a two or three character long string
        '''
        builddir = os.path.join(self.builddir, 'build/site/en')

        for root, dirs, files in os.walk(builddir):
            for f in files:
                if f.endswith('.html'):
                    f2b = LanguageAdder(os.path.join(root, f), this_lang,
                                        self.langs, builddir)
                    f2b.add_lang_info()

    def rename_site_files(self, lang):
        '''Search for files ending with html and pdf in the build site.

        Give all these files the ending '.lang'.
        Move them to the 'built' dir

        Args:
            lang (str): a two or three character long string
        '''

        builddir = os.path.join(self.builddir, 'build/site/en')
        builtdir = os.path.join(self.builddir, 'built')

        if len(self.langs) == 1:
            for item in glob.glob(builddir + '/*'):
                shutil.move(item, builtdir)
        else:
            for root, dirs, files in os.walk(builddir):
                goal_dir = root.replace('build/site/en', 'built')

                if not os.path.exists(goal_dir):
                    os.mkdir(goal_dir)

                for file_ in files:
                    newname = file_
                    if file_.endswith('.html') or file_.endswith('.pdf'):
                        newname = file_ + '.' + lang

                    shutil.copy(
                        os.path.join(root, file_),
                        os.path.join(goal_dir, newname))

            shutil.move(builddir, os.path.join(builtdir, lang))

    def build_all_langs(self):
        '''Build all the langs'''
        logger.info('Building all langs')
        for lang in self.langs:
            self.buildsite(lang)
            if len(self.langs) > 1:
                self.add_language_changer(lang)
            self.rename_site_files(lang)

    def run_command(self, command):
        '''Run a shell command

        Arguments:
            command: string containing the shell command
        '''
        logger.info('Running {}'.format(command))
        subp = subprocess.Popen(
            command.split(),
            stdout=subprocess.PIPE, stderr=subprocess.PIPE, cwd=self.builddir)

        (output, error) = subp.communicate()

        if subp.returncode != 0:
            logger.error('{} finished with errors'.format(command))
            logger.error('stdout')
            for line in output.split('\n'):
                logger.error(line)
            logger.error('stderr')
            for line in error.split('\n'):
                logger.error(line)
        else:
            logger.info('{} finished without errors'.format(command))
            logger.debug('stdout')
            logger.debug(output)
            logger.debug('stderr')
            logger.debug(error)

        return (subp.returncode, output)

    def copy_to_site(self):
        '''Copy the entire site to self.destination'''
        (returncode, _) = self.run_command('rsync -avz -e ssh {src} {dst}'.format(
            src=os.path.join(self.builddir, 'built/'), dst=self.destination))
        if returncode != 0:
            raise SystemExit(returncode)

        ckdir = os.path.join(self.builddir,
                             'src/documentation/resources/ckeditor')
        if os.path.exists(ckdir):
            self.run_command('rsync -avz -e ssh {src} {dst}'.format(
                src=ckdir, dst=self.destination + 'skin/'))
            if returncode != 0:
                raise SystemExit(returncode)

class LanguageAdder(object):
    '''Add a language changer to an html document

    Args:
        filename (str):     path to the html file
        this_lang (str):     The language of this document
        langs (list):   The list of all languages that should added to the
                        language element
        builddir (str): The basedir where the html files are found

    Attributes:
        filename (str):     path to the html file
        this_lang (str):     The language of this document
        langs (list):   The list of all languages that should added to the
                        language element
        builddir (str): The basedir where the html files are found
        namespace (dict):   the namespace used in the html document
        tree (lxml etree):  an lxml etree of the parsed file
    '''
    def __init__(self, filename, this_lang, langs, builddir):
        self.filename = filename
        self.this_lang = this_lang
        self.langs = langs
        self.builddir = builddir

        self.namespace = {'html': 'http://www.w3.org/1999/xhtml'}
        self.tree = etree.parse(filename, etree.HTMLParser())

    def __del__(self):
        '''Write self.tree to self.filename'''
        with open(self.filename, 'w') as outhtml:
            outhtml.write(etree.tostring(self.tree, encoding='utf8',
                                         pretty_print=True, method='html'))

    def add_lang_info(self):
        '''Create the language navigation element and add it to self.tree

        '''
        my_nav_bar = self.tree.getroot().find('.//div[@id="myNavbar"]',
                                              namespaces=self.namespace)
        my_nav_bar.append(self.make_lang_menu())

    def make_lang_menu(self):
        '''Make the language menu for self.this_lang'''
        trlangs = {u'fi': u'Suomeksi', u'no': u'På norsk',
                   u'sma': u'Åarjelsaemien', u'se': u'Davvisámegillii',
                   u'smj': u'Julevsábmáj', u'sv': u'På svenska',
                   u'en': u'In English'}

        right_menu = etree.Element('ul')
        right_menu.set('class', 'nav navbar-nav navbar-right')

        dropdown = etree.Element('li')
        dropdown.set('class', 'dropdown')
        right_menu.append(dropdown)

        dropdown_toggle = etree.Element('a')
        dropdown_toggle.set('class', 'dropdown-toggle')
        dropdown_toggle.set('data-toggle', 'dropdown')
        dropdown_toggle.set('href', '#')
        dropdown_toggle.text = u'Change language'
        dropdown.append(dropdown_toggle)

        span = etree.Element('span')
        span.set('class', 'caret')
        dropdown_toggle.append(span)

        dropdown_menu = etree.Element('ul')
        dropdown_menu.set('class', 'dropdown-menu')
        dropdown.append(dropdown_menu)

        for lang in self.langs:
            if lang != self.this_lang:
                li = etree.Element('li')
                a = etree.Element('a')
                filename = '/' + lang + self.filename.replace(self.builddir,
                                                              '')
                a.set('href', filename)
                a.text = trlangs[lang]
                li.append(a)
                dropdown_menu.append(li)

        return right_menu


def parse_options():
    parser = argparse.ArgumentParser(
        description='This script builds a multilingual forrest site.')
    parser.add_argument('--destination', '-d',
                        help='an ssh destination',
                        required=True)
    parser.add_argument('--sitehome', '-s',
                        help='where the forrest site lives',
                        required=True)
    parser.add_argument('--verbosity', '-V',
                        help='Set the logger level, default is warning\n'
                        'The allowed values are: warning, info, debug\n'
                        'Default is info.',
                        default='info')
    parser.add_argument('langs', help='list of languages',
                        nargs='+')

    args = parser.parse_args()
    return args


def main():
    logging_dict = {'info': logging.INFO,
                    'warning': logging.WARNING,
                    'debug': logging.DEBUG}
    args = parse_options()

    if args.verbosity in logging_dict.keys():
        if args.verbosity == 'debug':
            logging.info(
                'Logging level is set to debug. Output will very verbose')
        logger.setLevel(logging_dict[args.verbosity])
    else:
        raise SystemExit('-V|--verbosity must be one of: {}\n{} was given.'.format(
            '|'.join(logging_dict.keys()), args.verbosity))

    lockname = os.path.join(args.sitehome, '.lock')
    if not os.path.exists(lockname):
        with open(lockname, 'w') as lockfile:
            print(datetime.datetime.now(), file=lockfile)

        builder = StaticSiteBuilder(args.sitehome, args.destination, args.langs)
        builder.build_all_langs()
        builder.copy_to_site()
        os.remove(lockname)
    else:
        with open(lockname) as lockfile:
            dateformat = "%Y-%m-%d %H:%M:%S.%f"
            datestring = lockfile.read().strip()
            starttime = datetime.datetime.strptime(datestring, dateformat)
            delta = datetime.datetime.now() - starttime
            logger.error('A build of this site is still running and was started {} ago'.format(delta))


if __name__ == '__main__':
    main()
