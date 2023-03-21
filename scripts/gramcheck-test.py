#!/usr/bin/env python3
# -*- coding:utf-8 -*-

# Copyright © 2020-2021 UiT The Arctic University of Norway
# License: GPL3
# Author: Børre Gaup <borre.gaup@uit.no>
"""Check if grammarchecker tests pass."""

import sys
from pathlib import Path

import libdivvun
import yaml
from lxml import etree

from corpustools import errormarkup
from gramcheck_comparator import COLORS, UI, GramChecker, GramTest


class YamlGramChecker(GramChecker):
    def __init__(self, config, yaml_parent):
        self.config = config
        self.yaml_parent = yaml_parent
        self.checker = self.app()

    @staticmethod
    def print_error(string):
        print(string, file=sys.stderr)

    @property
    def archive_path(self):
        if self.config.get("spec"):
            archive_file = Path(self.config.get("spec"))
            if archive_file.is_file():
                return archive_file
            else:
                self.print_error(f'The file {self.config.get("spec")} does not exist')
                sys.exit(2)

        if self.config.get("Config").get("Archive"):
            archive_file = Path(
                f'{self.yaml_parent}/{self.config.get("Config").get("Archive")}'
            )
            if archive_file.is_file():
                return str(archive_file)
            else:
                self.print_error(
                    "Error in section Archive of the yaml file.\n"
                    + f"The file {archive_file} does not exist"
                )
                sys.exit(3)

        spec_file = Path(f'{self.yaml_parent}/{self.config.get("Config").get("Spec")}')
        if spec_file.is_file():
            return spec_file
        else:
            self.print_error(
                "Error in section Spec of the yaml file.\n"
                + f"The file {spec_file} does not exist"
            )
            sys.exit(4)

    @staticmethod
    def check_spec(spec_file, variant):
        xml_spec = etree.parse(str(spec_file))
        tags = xml_spec.xpath(f'.//pipeline[@name="{variant}"]//*[@n]')
        for tag in tags:
            name = Path(tag.get("n"))
            this_path = spec_file.parent / name
            if not this_path.is_file():
                raise SystemExit(
                    f"""
    ERROR: Cannot run this this test!
    {this_path.resolve()}
    is listed as a dependency in
    {spec_file.resolve()}
    but does not exist.\n
    Run:
    ./configure --enable-grammarchecker\n
    Then:
    make"""
                )

    def app(self):
        config = self.config
        spec_file = self.archive_path

        if spec_file.suffix == ".zcheck":
            spec = libdivvun.ArCheckerSpec(str(spec_file))
            return spec.getChecker(pipename=spec.defaultPipe(), verbose=False)

        spec = libdivvun.CheckerSpec(str(spec_file))
        if spec.hasPipe(config.get("Config").get("Variant")):
            self.check_spec(spec_file, config.get("Config").get("Variant"))
            return spec.getChecker(
                pipename=config.get("Config").get("Variant"), verbose=False
            )
        else:
            self.print_error(
                "Error in section Variant of the yaml file.\n"
                + "There is no pipeline named "
                f'"{config.get("Config").get("Variant")}" in {spec_file}'
            )
            sys.exit(5)


class YamlGramTest(GramTest):
    explanations = {
        "tp": "GramDivvun found marked up error and has the suggested correction",
        "fp1": "GramDivvun found manually marked up error, but corrected wrongly",
        "fp2": "GramDivvun found error which is not manually marked up",
        "fn1": "GramDivvun found manually marked up error, but has no correction",
        "fn2": "GramDivvun did not find manually marked up error",
    }

    def __init__(self, args):
        super().__init__()
        self.args = args
        self.config = self.load_config()

    def load_config(self):
        args = self.args
        config = {}

        if args.silent:
            config["out"] = GramTest.NoOutput(args)
        else:
            config["out"] = {
                "normal": GramTest.NormalOutput,
                "terse": GramTest.TerseOutput,
                "compact": GramTest.CompactOutput,
                "silent": GramTest.NoOutput,
                "final": GramTest.FinalOutput,
            }.get(args.output, lambda x: None)(args)

        config["test_file"] = Path(args.test_files[0])

        if not args.colour:
            for key in list(COLORS.keys()):
                COLORS[key] = ""

        config["spec"] = args.spec
        config.update(self.yaml_reader(config["test_file"]))

        if not config.get("Tests"):
            config["Tests"] = []

        if args.total and len(args.test_files) == 1:
            notfixed = (
                config["test_file"].parent / f"{config['test_file'].stem}.notfixed.yaml"
            )
            tests = self.yaml_reader(notfixed).get("Tests")
            if notfixed.is_file() and tests:
                config["Tests"].extend(tests)

        if len(args.test_files) > 1:
            for test_file in args.test_files[1:]:
                tests = self.yaml_reader(Path(test_file)).get("Tests")
                if tests:
                    config["Tests"].extend(tests)

        return config

    @staticmethod
    def yaml_reader(test_file):
        with test_file.open() as test_file:
            return yaml.load(test_file, Loader=yaml.FullLoader)

    def make_error_markup(self, text):
        para = etree.Element("p")
        try:
            para.text = text
            errormarkup.convert_to_errormarkupxml(para)
        except TypeError:
            print(f'Error in {self.config["test_file"]}')
            print(text, "is not a string")
        return para

    @property
    def paragraphs(self):
        grammarchecker = YamlGramChecker(self.config, self.config["test_file"].parent)

        return (
            grammarchecker.get_data(
                str(self.config["test_file"]), self.make_error_markup(text)
            )
            for text in self.config["Tests"]
        )


class YamlUI(UI):
    def __init__(self):
        super().__init__()

        self.description = "Test errormarkuped up sentences"
        self.add_argument(
            "-o",
            "--output",
            choices=["normal", "compact", "terse", "final"],
            dest="output",
            default="normal",
            help="""Desired output style (Default: normal)""",
        )
        self.add_argument(
            "-q",
            "--silent",
            dest="silent",
            action="store_true",
            help="Hide all output; exit code only",
        )
        self.add_argument(
            "-p",
            "--hide-passes",
            dest="hide_pass",
            action="store_true",
            help="Suppresses passes to make finding fails easier",
        )
        self.add_argument(
            "-s",
            "--spec",
            dest="spec",
            required=False,
            help="""Path to the pipeline.xml spec file. Usefull when doing out
            of tree builds""",
        )
        self.add_argument(
            "-t",
            "--total",
            dest="total",
            action="store_true",
            required=False,
            help="""Merge tests from x.yaml and x.notfixed.yaml""",
        )
        self.add_argument(
            "-v",
            "--verbose",
            dest="verbose",
            action="store_true",
            help="More verbose output.",
        )
        self.add_argument("test_files", nargs="+", help="YAML files with test rules")

        self.test = YamlGramTest(self.parse_args())


def main():
    try:
        ui = YamlUI()
        ui.start()
    except KeyboardInterrupt:
        sys.exit(130)


if __name__ == "__main__":
    try:
        main()
    except (
        FileNotFoundError,
        yaml.scanner.ScannerError,
        yaml.parser.ParserError,
        errormarkup.ErrorMarkupError,
    ) as error:
        print(str(error), file=sys.stderr)
        raise SystemExit(1)
