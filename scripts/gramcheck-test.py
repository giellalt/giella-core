#!/usr/bin/env python3
# -*- coding:utf-8 -*-

# Copyright © 2020 UiT The Arctic University of Norway
# License: GPL3
# Author: Børre Gaup <borre.gaup@uit.no>
"""Check if grammarchecker tests pass."""

import os
import sys
from collections import Counter
from pathlib import Path

import libdivvun
import yaml

from corpustools import errormarkup
from gramcheck_comparator import COLORS, UI, GramChecker, GramTest


class YamlGramChecker(GramChecker):
    def __init__(self, config, yaml_parent):
        self.config = config
        self.yaml_parent = yaml_parent
        self.checker = self.app()

    def app(self):
        def print_error(string):
            print(string, file=sys.stderr)

        config = self.config

        if config.get('Archive'):
            archive_file = Path(f'{self.yaml_parent}/{config.get("Archive")}')
            if archive_file.is_file():
                spec = libdivvun.ArCheckerSpec(str(archive_file))
                pipename = spec.defaultPipe()
                verbose = False
                return spec.getChecker(pipename, verbose)
            else:
                print_error('Error in section Archive of the yaml file.\n' +
                            f'The file {archive_file} does not exist')
                sys.exit(2)

        if {config.get("Spec")}:
            spec_file = Path(f'{self.yaml_parent}/{config.get("Spec")}')
            if spec_file.is_file():
                os.chdir(spec_file.parent)
                spec = libdivvun.CheckerSpec(spec_file.name)
                if spec.hasPipe(config.get("Variant")):
                    verbose = False
                    return spec.getChecker(config.get("Variant"), verbose)
                else:
                    print_error(
                        'Error in section Variant of the yaml file.\n' +
                        'There is no pipeline named '
                        f'"{config.get("Variant")}" in {spec_file}')
                    sys.exit(3)
            else:
                print_error('Error in section Spec of the yaml file.\n' +
                            f'The file {spec_file} does not exist')
                sys.exit(4)

        print_error('Error in Config section of yaml file. '
                    'Neither Archive nor Spec exists')
        sys.exit(5)


class YamlGramTest(GramTest):
    explanations = {
        'tp':
        'GramDivvun found marked up error and has the suggested correction',
        'fp1':
        'GramDivvun found manually marked up error, but corrected wrongly',
        'fp2': 'GramDivvun found error which is not manually marked up',
        'fn1':
        'GramDivvun found manually marked up error, but has no correction',
        'fn2': 'GramDivvun did not find manually marked up error'
    }

    def __init__(self, args):
        self.args = args
        self.config = self.load_config()
        self.count = Counter()

    def load_config(self):
        args = self.args
        config = {}

        if args.silent:
            config['out'] = GramTest.NoOutput(args)
        else:
            config['out'] = {
                "normal": GramTest.NormalOutput,
                "terse": GramTest.TerseOutput,
                "compact": GramTest.CompactOutput,
                "silent": GramTest.NoOutput,
                "final": GramTest.FinalOutput
            }.get(args.output, lambda x: None)(args)

        config['test_file'] = Path(args.test_file)

        if not args.colour:
            for key in list(COLORS.keys()):
                COLORS[key] = ""

        return config

    def yaml_reader(self):
        test_file = self.config.get('test_file')
        with test_file.open() as test_file:
            return yaml.load(test_file, Loader=yaml.FullLoader)

    @property
    def tests(self):
        yaml_stream = self.yaml_reader()
        grammarchecker = YamlGramChecker(yaml_stream.get('Config'),
                                         self.config['test_file'].parent)

        return {
            test: grammarchecker.get_data(test)
            for test in yaml_stream['Tests']
        }


class YamlUI(UI):
    def __init__(self):
        super().__init__()

        self.description = "Test errormarkuped up sentences"
        self.add_argument("-o",
                          "--output",
                          choices=['normal', 'compact', 'terse', 'final'],
                          dest="output",
                          default="normal",
                          help="""Desired output style (Default: normal)""")
        self.add_argument("-q",
                          "--silent",
                          dest="silent",
                          action="store_true",
                          help="Hide all output; exit code only")
        self.add_argument(
            "-p",
            "--hide-passes",
            dest="hide_pass",
            action="store_true",
            help="Suppresses passes to make finding fails easier")
        self.add_argument(
            "-t",
            "--test",
            dest="test",
            nargs='?',
            required=False,
            help="""Which test to run (Default: all). TEST = test ID, e.g.
            'Noun - g\u00E5etie' (remember quotes if the ID contains spaces)"""
        )
        self.add_argument("-v",
                          "--verbose",
                          dest="verbose",
                          action="store_true",
                          help="More verbose output.")
        self.add_argument("test_file", help="YAML file with test rules")

        self.test = YamlGramTest(self.parse_args())

    def start(self):
        ret = self.test.run()
        sys.stdout.write(str(self.test))
        sys.exit(ret)


def main():
    try:
        ui = YamlUI()
        ui.start()
    except KeyboardInterrupt:
        sys.exit(130)


if __name__ == "__main__":
    try:
        main()
    except (FileNotFoundError, yaml.scanner.ScannerError,
            yaml.parser.ParserError, errormarkup.ErrorMarkupError) as error:
        raise SystemExit(error)
