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


def getpath(corpus_lang: str) -> str:
    """Get the corpus path."""
    gtfree = str(os.getenv('GTFREE'))

    return os.path.join(gtfree, 'goldstandard/converted', corpus_lang)


def get_error_sentences(corpus_lang: str,
                        runner: util.ExternalCommandRunner) -> str:
    """Get the sentences containing errors from the corpus."""
    runner = util.ExternalCommandRunner()
    runner.run(f'ccat -a -l {corpus_lang} {getpath(corpus_lang)}'.split())
    return runner.stdout.decode('utf-8')


def get_correct_sentences(corpus_lang: str,
                          runner: util.ExternalCommandRunner) -> str:
    """Get the corrected sentences from the corpus."""
    runner.run(f'ccat -c -a -l {corpus_lang} {getpath(corpus_lang)}'.split())
    return runner.stdout.decode('utf-8')


def correct(error: list, sentence: str) -> str:
    """Replace the given error with the first correction."""
    print(error)
    start = error[1]
    fixes = error[5]
    end = error[2]
    if fixes:
        return ''.join([sentence[:start], fixes[0], sentence[end:]])

    return sentence


def gramcheck(sentence: str, corpus_lang: str,
              runner: util.ExternalCommandRunner) -> str:
    """Run the gramchecker on the error_sentence."""
    three2two = {'sme': 'se'}
    runner.run(
        f'divvun-checker -l {three2two[corpus_lang]} -n smegram'.split(),
        to_stdin=sentence.encode('utf-8'))

    output = json.loads(runner.stdout)
    if output['errs']:
        output['errs'] = [error for error in output['errs'] if error[5]]

    return output


def get_gramcheck_results(sentence: str, errors: dict) -> str:
    """Replace errors with corrections from the error dict."""
    corrected_sentence = sentence
    for error in reversed(errors):
        corrected_sentence = correct(error, corrected_sentence)

    return corrected_sentence


for lang in sys.argv[1:]:
    command_runner = util.ExternalCommandRunner()
    error_sentences = [
        sentence
        for sentence in get_error_sentences(lang, command_runner).split(u'\n')
        if sentence.strip()
    ]
    correct_sentences = [
        sentence for sentence in get_correct_sentences(lang, command_runner).
        split(u'\n') if sentence.strip()
    ]

    err_len = len(error_sentences)
    corr_len = len(correct_sentences)
    if err_len != corr_len:
        raise SystemExit(f'erroneous input. err: {err_len}, corr: {corr_len}')

    for sentence_no, error_sentence in enumerate(error_sentences):
        if sentence_no < 50:
            if error_sentence.strip():
                check_output = gramcheck(error_sentence, lang, command_runner)
                corrected = check_output['text']
                gramcheck_runs = 0
                while check_output['errs'] and gramcheck_runs < 10:
                    to_correct = corrected
                    corrected = get_gramcheck_results(to_correct,
                                                      check_output['errs'])
                    check_output = gramcheck(corrected, lang, command_runner)
                    gramcheck_runs += 1
                if gramcheck_runs:  # to only print those with errors
                    print(f'errorsentence\t{sentence_no} {gramcheck_runs} '
                          f'{error_sentence}')
                    print(f'gramcheck\t{sentence_no} {gramcheck_runs} '
                          f'{corrected}')
                    print(f'ccat facit\t{sentence_no} {gramcheck_runs} '
                          f'{correct_sentences[sentence_no]}')
                    print()
