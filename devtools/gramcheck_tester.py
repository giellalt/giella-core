#!/usr/bin/env python3
# -*- coding:utf-8 -*-

#
#   This program is free software: you can redistribute it and/or modify
#   it under the terms of the GNU General Public License as published by
#   the Free Software Foundation, either version 3 of the License, or
#   (at your option) any later version.
#
#   This program is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
#   GNU General Public License for more details.
#
#   You should have received a copy of the GNU General Public License
#   along with this file. If not, see <http://www.gnu.org/licenses/>.
#
#   Copyright © 2019 The University of Tromsø
#   http://giellatekno.uit.no & http://divvun.no
#
"""Classes and functions to run grammarchecker tests."""
import json
import os
import sys

from corpustools import util


def getpath(lang: str) -> str:
    gtfree = str(os.getenv('GTFREE'))

    return os.path.join(gtfree, 'goldstandard/converted', lang)


def get_error_sentences(lang: str, runner: util.ExternalCommandRunner) -> str:
    runner = util.ExternalCommandRunner()
    runner.run(f'ccat -a -l {lang} {getpath(lang)}'.split())
    return runner.stdout.decode('utf-8')


def get_correct_sentences(lang: str,
                          runner: util.ExternalCommandRunner) -> str:
    runner.run(f'ccat -c -a -l {lang} {getpath(lang)}'.split())
    return runner.stdout.decode('utf-8')


def correct(error: list, to_correct: str) -> str:
    print(error)
    start = error[1]
    fixes = error[5]
    end = error[2]
    if fixes:
        return ''.join([to_correct[:start], fixes[0], to_correct[end:]])
    else:
        return to_correct


def gramcheck(error_sentence: str, lang: str,
              runner: util.ExternalCommandRunner) -> str:
    three2two = {'sme': 'se'}
    runner.run(
        f'divvun-checker -l {three2two[lang]} -n smegram'.split(),
        to_stdin=error_sentence.encode('utf-8'))

    output = json.loads(runner.stdout)
    if output['errs']:
        output['errs'] = [error for error in output['errs'] if error[5]]

    return output


for lang in sys.argv[1:]:
    runner = util.ExternalCommandRunner()
    error_sentences = get_error_sentences(lang, runner).split(u'\n')
    correct_sentences = get_correct_sentences(lang, runner).split(u'\n')

    err_len = len(error_sentences)
    corr_len = len(correct_sentences)
    if err_len != corr_len:
        raise SystemExit(f'erroneous input. err: {err_len}, corr: {corr_len}')

    print(f'all well so far. err: {err_len}, corr: {corr_len}')

    for x, error_sentence in enumerate(error_sentences):
        if x < 50:
            if error_sentence.strip():
                check_output = gramcheck(error_sentence, lang, runner)
                corrected = check_output['text']
                y = 0
                while check_output['errs'] and y < 10:
                    print(f'hoi! {y} {check_output}')
                    to_correct = corrected
                    for error in reversed(check_output['errs']):
                        print(f'before {y}: {corrected}')
                        corrected = correct(error, corrected)
                        print(f'after {y}: {corrected}\n')
                    check_output = gramcheck(corrected, lang, runner)
                    y += 1
                if y:  #  to only print those with errors
                    print(f'{x} {error_sentence}')
                    print(f'{x} {corrected}')
                    print()
