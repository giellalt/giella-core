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
"""Run grammarchecker tests."""
import argparse
import json
import multiprocessing
import os
import pickle
from pathlib import Path

from lxml import etree

from corpustools import util


def getpath(lang: str) -> str:
    """Get the corpus path."""
    gtfree = str(os.getenv('GTFREE'))

    return os.path.join(gtfree, 'goldstandard/converted', lang)


def get_error_sentences(lang: str, runner: util.ExternalCommandRunner) -> str:
    """Get the sentences containing errors from the corpus."""
    runner = util.ExternalCommandRunner()
    runner.run(f'ccat -a -l {lang} {getpath(lang)}'.split())
    return runner.stdout.decode('utf-8')


def get_correct_sentences(lang: str,
                          runner: util.ExternalCommandRunner) -> str:
    """Get the corrected sentences from the corpus."""
    runner.run(f'ccat -c -a -l {lang} {getpath(lang)}'.split())
    return runner.stdout.decode('utf-8')


def gramcheck(sentence: str, zcheck_file: str,
              runner: util.ExternalCommandRunner) -> dict:
    """Run the gramchecker on the error_sentence."""
    runner.run(
        f'divvun-checker -a {zcheck_file} -n smegram'.split(),
        to_stdin=sentence.encode('utf-8'))

    return json.loads(runner.stdout)


def make_error_parts(grammarcheck_result: dict) -> list:
    """Make a list out of a grammarchecker error dict.

    This list will later be used to construct strings for the report.
    """
    hint: list = []
    previous_end: int = 0
    text: str = grammarcheck_result['text']
    for error in grammarcheck_result['errs']:
        hint.append(text[previous_end:error[1]])
        if error[3] == 'typo':
            hint.append([error[0], error[5] if error[5] else [error[0]]])
        else:
            hint.append([error[0], error[5] if error[5] else ['']])
        previous_end = error[2]
    hint.append(text[previous_end:])

    return hint


def make_orig(error_parts: list) -> str:
    """Make a original sentence.

    Mark it up with error classes.
    """
    orig = etree.Element('div')
    orig.set('class', 'grid-item')
    orig.text = error_parts[0]

    error_count = 0
    span = etree.Element('span')
    for error_part in error_parts[1:]:
        if isinstance(error_part, str):
            span.tail = error_part
            orig.append(span)
            span = etree.Element('span')
        else:
            span.set('class', 'error{error_count}')
            span.text = f'{error_part[0]}'
            error_count += 1

    return orig


def make_corrected(error_parts: list) -> str:
    """Make a corrected sentence."""
    orig = []
    error_count = 0
    for error_part in error_parts:
        if isinstance(error_part, str):
            orig.append(error_part)
        else:
            if error_part[1][0].strip():
                orig.append(error_part[1][0])
            else:
                orig.append('😱')
            error_count += 1

    return ''.join(orig)


def make_corrected_web(error_parts: list) -> etree.Element:
    """Make a corrected sentence to be used in the html report."""
    corrected = etree.Element('div')
    corrected.set('class', 'grid-item')
    corrected.text = error_parts[0]

    error_count = 0
    span = etree.Element('span')
    for error_part in error_parts[1:]:
        if isinstance(error_part, str):
            span.tail = error_part
            corrected.append(span)
            span = etree.Element('span')
        else:
            span.set('class', 'error{error_count}')
            if error_part[1][0].strip():
                span.text = error_part[1][0]
            else:
                span.text = '😱'
            error_count += 1

    return corrected


def make_error(error_parts: list) -> str:
    """Make an error list.

    It has the same class as the errors.
    """
    table_d = etree.Element('div')
    table_d.set('class', 'grid-item')
    unordered_list = etree.SubElement(table_d, 'ul')
    for errno, error in enumerate([
            error_part for error_part in error_parts
            if not isinstance(error_part, str)
    ]):
        unordered_list = etree.SubElement(table_d, 'ul')
        list_element = etree.SubElement(unordered_list, 'li')
        list_element.set('class', f'error{errno}')
        list_element.text = f'«{error[0]}» ➞'.replace(' ', ' ')
        sublist = etree.SubElement(list_element, 'ul')
        for suberror in error[1]:
            sub_li = etree.SubElement(sublist, 'li')
            sub_li.set('class', f'error{errno}')
            sub_li.text = f'«{suberror}»'.replace(' ', ' ')

    return table_d


def make_error_parts_table(error_parts_list: list):
    """Make the sub table to display errors."""

    error_table = etree.Element('div')
    error_table.set('class', 'grid-container')
    for header in ['error sentence', 'corrections', 'errors']:
        thead = etree.SubElement(error_table, 'div')
        thead.set('class', 'grid-item')
        thead.text = header

    for error_parts in error_parts_list:
        error_table.append(make_orig(error_parts))
        error_table.append(make_corrected_web(error_parts))
        error_table.append(make_error(error_parts))

    return error_table


def make_gramcheck_runs(error_sentence: str, correct_sentence: str, lang: str,
                        runner: util.ExternalCommandRunner) -> tuple:
    """Turn error_sentence and grammar checks to a list."""
    gramcheck_dict: dict = gramcheck(error_sentence, lang, runner)
    error_parts_list: list = []

    gramcheck_runs = 0
    while gramcheck_dict['errs'] and gramcheck_runs < 10:
        error_parts = make_error_parts(gramcheck_dict)
        error_parts_list.append(error_parts)
        gramcheck_runs += 1
        gramcheck_dict = gramcheck(make_corrected(error_parts), lang, runner)

    util.print_frame(gramcheck_runs, len(error_sentence))

    return error_sentence, correct_sentence, error_parts_list


def make_table(error_data_list: list):
    """Make the main table that displays all error data."""
    main_table = etree.Element('table')
    main_table.set('id', 'results')
    main_table_head = etree.SubElement(main_table, 'thead')
    first_tr = etree.SubElement(main_table_head, 'tr')
    for header in [
            'orig sentence', 'reference sentence', 'runs', 'corrections'
    ]:
        thead = etree.SubElement(first_tr, 'th')
        thead.text = header

    main_table_tbody = etree.SubElement(main_table, 'tbody')
    for error_data in error_data_list:
        table_row = etree.SubElement(main_table_tbody, 'tr')
        td1 = etree.SubElement(table_row, 'td')
        td1.text = error_data[0]
        td2 = etree.SubElement(table_row, 'td')
        td2.text = error_data[1]
        td3 = etree.SubElement(table_row, 'td')
        td3.text = str(len(error_data[2]) if error_data[2] else 1)
        td4 = etree.SubElement(table_row, 'td')
        if error_data[2]:
            td4.append(make_error_parts_table(error_data[2]))
        else:
            td4.text = 'No errors found'

    return main_table


def make_html():
    """Make the head of the grammarcheck_result html file."""
    html = etree.Element('html')
    html.append(
        etree.fromstring('''
        <head>
            <meta charset="UTF-8"/>
            <script src="https://cdnjs.cloudflare.com/ajax/libs/jquery/3.1.1/jquery.min.js" integrity="sha256-hVVnYaiADRTO2PzUGmuLJr8BLUSjGIZsDYGmIJLv2b8=" crossorigin="anonymous"> </script>
            <script src="https://cdnjs.cloudflare.com/ajax/libs/Dynatable/0.3.1/jquery.dynatable.min.js" integrity="sha256-/kLSC4kLFkslkJlaTgB7TjurN5TIcmWfMfaXyB6dVh0=" crossorigin="anonymous"> </script>
            <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/Dynatable/0.3.1/jquery.dynatable.min.css" integrity="sha256-lxcbK1S14B8LMgrEir2lv2akbdyYwD1FwMhFgh2ihls=" crossorigin="anonymous"/>
            <link type="text/css" rel="stylesheet" href="https://gtsvn.uit.no/langtech/trunk/giella-core/scripts/style/gramcheck.css"/>
        </head>
    '''))  # noqa: E501

    return html


def parse_options():
    """Parse the options given to the program."""
    parser = argparse.ArgumentParser(description='Test the grammarchecker.')
    parser.add_argument('zcheck_file', help='Path to the zcheck file to use.')
    parser.add_argument('result_file', help='Path to resulting html file.')

    return parser.parse_args()


def get_sentences(zcheck_file):
    """Get error and reference sentences from goldstandard corpus."""
    zcheck_path = Path(zcheck_file)
    lang = zcheck_path.name.replace(zcheck_path.suffix, '')
    if lang == 'se':
        lang = 'sme'

    runner = util.ExternalCommandRunner()

    error_sentences = [
        sentence for sentence in get_error_sentences(lang, runner).split(u'\n')
        if sentence.strip()
    ]
    correct_sentences = [
        sentence
        for sentence in get_correct_sentences(lang, runner).split(u'\n')
        if sentence.strip()
    ]

    err_len = len(error_sentences)
    corr_len = len(correct_sentences)
    if err_len != corr_len:
        raise SystemExit(f'erroneous input. err: {err_len}, corr: {corr_len}')

    return [(error_sentence, correct_sentence)
            for error_sentence, correct_sentence in zip(
                error_sentences, correct_sentences)]


def get_error_data_list(zcheck_file: str) -> list:
    """Make error data from grammar checker."""
    runner = util.ExternalCommandRunner()
    sentences = get_sentences(zcheck_file)

    pool = multiprocessing.Pool(multiprocessing.cpu_count() * 2)
    results = [
        pool.apply_async(
            make_gramcheck_runs,
            args=(
                error_sentence,
                correct_sentence,
                zcheck_file,
                runner,
            )) for error_sentence, correct_sentence in sentences
        if error_sentence.strip()
        and not ('Nu fal. Nu dehalaš' in error_sentence
                 or 'Okta joavku mas čuojahan' in error_sentence)
    ]

    return [result.get() for result in results]


def create_html(error_data_list: list) -> etree.Element:
    """Create errordata html."""
    html = make_html()
    body = etree.SubElement(html, 'body')
    body.append(make_table(error_data_list))
    body.append(
        etree.fromstring('''
       <script
           src="https://gtsvn.uit.no/langtech/trunk/giella-core/scripts/javascript/tablesorter.js">
       </script>'''))  # noqa: E501

    return html


def write_html(html: etree.Element, result_file: str) -> None:
    with open(result_file, 'wb') as result_stream:
        result_stream.write(
            etree.tostring(
                html,
                pretty_print=True,
                encoding='utf-8',
                xml_declaration=True))


def main() -> None:
    """The main routine of the grammarcheck result script."""
    args = parse_options()

    runner = util.ExternalCommandRunner()
    sentences = get_sentences(args.zcheck_file)

    pool = multiprocessing.Pool(multiprocessing.cpu_count() * 2)
    results = [
        pool.apply_async(
            make_gramcheck_runs,
            args=(
                error_sentence,
                correct_sentence,
                args.zcheck_file,
                runner,
            )) for error_sentence, correct_sentence in sentences
        if error_sentence.strip()
        and not ('Nu fal. Nu dehalaš' in error_sentence
                 or 'Okta joavku mas čuojahan' in error_sentence)
    ]

    error_data_list = [result.get() for result in results]

    with open('test.txt', 'wb') as kruff:
        pickle.dump(error_data_list, kruff)

    #with open('test.txt', 'rb') as kruff:
        #error_data_list = pickle.load(kruff)

    print('so far, so good')
    html = create_html(error_data_list)
    write_html(html, args.result_file)


if __name__ == '__main__':
    main()
