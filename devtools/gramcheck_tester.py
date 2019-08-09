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
from pathlib import Path

import editdistance
from lxml import etree

from corpustools import util


def getpath(
        lang: str,
        converted_corpus: str,
) -> str:
    """Get the corpus path."""
    return ' '.join([
        os.path.join(corpus, converted_corpus, 'converted', lang)
        for corpus in [str(os.getenv('GTFREE')),
                       str(os.getenv('GTBOUND'))]
    ])


def get_error_sentences(lang: str, converted_corpus: str,
                        runner: util.ExternalCommandRunner) -> str:
    """Get the sentences containing errors from the corpus."""
    runner.run(f'ccat -a -l {lang} {getpath(lang, converted_corpus)}'.split())
    return runner.stdout.decode('utf-8')


def get_correct_sentences(lang: str, converted_corpus: str,
                          runner: util.ExternalCommandRunner) -> str:
    """Get the corrected sentences from the corpus."""
    runner.run(
        f'ccat -c -a -l {lang} {getpath(lang, converted_corpus)}'.split())
    return runner.stdout.decode('utf-8')


def gramcheck(sentence: str, zcheck_file: str,
              runner: util.ExternalCommandRunner) -> dict:
    """Run the gramchecker on the error_sentence."""
    runner.run(
        f'divvun-checker -a {zcheck_file} '.split(),
        to_stdin=sentence.encode('utf-8'))

    return json.loads(runner.stdout)


def make_corrected(gramcheck_dict: dict) -> str:
    """Make a corrected sentence."""
    text = gramcheck_dict['text']
    for error in reversed(gramcheck_dict['errs']):
        before = text[:error[1]]
        after = text[error[2]:]
        if error[5] and error[5][0]:
            correction = error[5][0]
        else:
            correction = error[0]

        text = f'{before}{correction}{after}'

    return text


def make_orig(gramcheck_dict: dict) -> etree.Element:
    """Make an original sentence.

    Mark it up with error classes.
    """
    text = gramcheck_dict['text']
    errors = gramcheck_dict['errs']

    orig = etree.Element('div')
    orig.set('class', 'grid-item')
    orig.text = text[:errors[0][1]]

    for error_count, error in enumerate(errors, start=1):
        span = etree.SubElement(orig, 'span')
        span.set('class', f'error{error_count}')
        span.text = text[error[1]:error[2]]
        if error_count < len(errors):
            span.tail = text[error[2]:errors[error_count][1]]
        else:
            span.tail = text[error[2]:]

    return orig


def make_corrected_web(gramcheck_dict: dict) -> etree.Element:
    """Make a corrected sentence to be used in the html report."""
    text = gramcheck_dict['text']
    errors = gramcheck_dict['errs']

    corrected = etree.Element('div')
    corrected.set('class', 'grid-item')
    corrected.text = text[:errors[0][1]]

    for error_count, error in enumerate(errors, start=1):
        span = etree.SubElement(corrected, 'span')
        span.set('class', f'error{error_count}')
        if error[5] and error[5][0]:
            span.text = error[5][0]
        else:
            span.text = error[0]

        if error_count < len(errors):
            span.tail = text[error[2]:errors[error_count][1]]
        else:
            span.tail = text[error[2]:]

    return corrected


def make_error(gramcheck_dict: list) -> etree.Element:
    """Make an error list.

    It has the same class as the errors.
    """
    table_d = etree.Element('div')
    table_d.set('class', 'grid-item')
    unordered_list = etree.SubElement(table_d, 'ul')
    for error_count, error in enumerate(gramcheck_dict['errs'], start=1):
        unordered_list = etree.SubElement(table_d, 'ul')
        list_element = etree.SubElement(unordered_list, 'li')
        list_element.set('class', f'error{error_count}')
        list_element.text = f'«{error[0]}» ➞ [{error[3]}]'.replace(' ', ' ')
        sublist = etree.SubElement(list_element, 'ul')
        if error[5]:
            for suberror in error[5]:
                sub_li = etree.SubElement(sublist, 'li')
                sub_li.set('class', f'error{error_count}')
                sub_li.text = f'«{suberror}»'.replace(' ', ' ')
        else:
            sub_li = etree.SubElement(sublist, 'li')
            sub_li.set('class', f'error{error_count}')
            sub_li.text = 'No suggestions'

    return table_d


def make_error_parts_table(gramcheck_dicts: list):
    """Make the sub table to display errors."""

    error_table = etree.Element('div')
    error_table.set('class', 'grid-container')
    for header in ['ErrorSentence', 'Corrections', 'Suggestions']:
        thead = etree.SubElement(error_table, 'div')
        thead.set('class', f'grid-item {header.replace(" ", "_")}')
        thead.text = header

    for gramcheck_dict in gramcheck_dicts:
        error_table.append(make_orig(gramcheck_dict))
        error_table.append(make_corrected_web(gramcheck_dict))
        error_table.append(make_error(gramcheck_dict))

    return error_table


def make_gramcheck_runs(error_sentence: str, correct_sentence: str, lang: str,
                        runner: util.ExternalCommandRunner) -> tuple:
    """Turn error_sentence and grammar checks to a list."""
    gramcheck_dicts: list = []
    gramcheck_dict: dict = gramcheck(error_sentence, lang, runner)

    gramcheck_runs = 0
    while gramcheck_dict['errs'] and gramcheck_runs < 10:
        gramcheck_dicts.append(gramcheck_dict)
        if len(gramcheck_dicts) > 1 and gramcheck_dict == gramcheck_dicts[-1]:
            break
        gramcheck_runs += 1
        try:
            gramcheck_dict = gramcheck(
                make_corrected(gramcheck_dicts[-1]), lang, runner)
        except json.decoder.JSONDecodeError:
            util.print_frame(gramcheck_runs, gramcheck_dicts[-1])
            util.print_frame(
                f'failed on sentence: {make_corrected(gramcheck_dicts[-1])}')
            break

    return error_sentence, correct_sentence, gramcheck_dicts


def make_levenshtein(error_data: list) -> etree.Element:
    """Make levenshtein, TP/FN/TN/FP"""
    levenshtein = etree.Element('p')
    if error_data[0] == error_data[1] and error_data[2]:
        levenshtein.set('class', 'false_positive')
        levenshtein.text = 'FP'
    elif error_data[0] != error_data[1] and not error_data[2]:
        levenshtein.set('class', 'false_negative')
        levenshtein.text = 'FN'
    elif error_data[0] != error_data[1] and error_data[2]:
        lev = editdistance.eval(error_data[1],
                                make_corrected(error_data[2][-1]))
        if lev < 20:
            levenshtein.set('class', f'true_positive_{lev}')
        else:
            levenshtein.set('class', f'true_positive_20')
        levenshtein.text = f'TP {lev:02}'
    else:
        levenshtein.set('class', 'true_negative')
        levenshtein.text = 'TN'

    return levenshtein


def make_table(error_data_list: list):
    """Make the main table that displays all error data."""
    main_table = etree.Element('table')
    main_table.set('id', 'results')
    main_table_head = etree.SubElement(main_table, 'thead')
    first_tr = etree.SubElement(main_table_head, 'tr')
    for header in [('Original', 'orig'), ('Reference', 'ref'),
                   ('Leven', 'leven'), ('Runs', 'runs'),
                   ('Corrections', 'corrections')]:
        thead = etree.SubElement(first_tr, 'th')
        thead.text = header[0]
        thead.set('id', header[1])

    main_table_tbody = etree.SubElement(main_table, 'tbody')
    for error_data in error_data_list:
        table_row = etree.SubElement(main_table_tbody, 'tr')
        td1 = etree.SubElement(table_row, 'td')
        td1.text = error_data[0]
        td2 = etree.SubElement(table_row, 'td')
        td2.text = error_data[1]
        td3 = etree.SubElement(table_row, 'td')
        td3.append(make_levenshtein(error_data))
        td4 = etree.SubElement(table_row, 'td')
        td4.text = str(len(error_data[2]) if error_data[2] else 1)
        td5 = etree.SubElement(table_row, 'td')
        if error_data[2]:
            td5.append(make_error_parts_table(error_data[2]))
        else:
            td5.text = 'No errors found'

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
    parser.add_argument(
        '-goldstandard',
        dest='goldstandard',
        action='store_true',
        help='Set this for testing with the goldstandard corpus. The default '
        'is to use correct-no-gs, which is meant to be used for development '
        'of this tool.')
    parser.add_argument('zcheck_file', help='Path to the zcheck file to use.')
    parser.add_argument('result_file', help='Path to resulting html file.')

    return parser.parse_args()


def get_sentences(zcheck_file, converted_corpus: str):
    """Get error and reference sentences from goldstandard corpus."""
    zcheck_path = Path(zcheck_file)
    lang = zcheck_path.name.replace(zcheck_path.suffix, '')
    if lang == 'se':
        lang = 'sme'

    runner = util.ExternalCommandRunner()

    error_sentences = [
        sentence.replace(' ¶', '') for sentence in get_error_sentences(
            lang, converted_corpus, runner).split(u'\n') if sentence.strip()
    ]
    correct_sentences = [
        sentence.replace(' ¶', '') for sentence in get_correct_sentences(
            lang, converted_corpus, runner).split(u'\n') if sentence.strip()
    ]

    err_len = len(error_sentences)
    corr_len = len(correct_sentences)
    if err_len != corr_len:
        raise SystemExit(f'erroneous input. err: {err_len}, corr: {corr_len}')

    return [(error_sentence, correct_sentence)
            for error_sentence, correct_sentence in zip(
                error_sentences, correct_sentences)]


def create_html(error_data_list: list) -> etree.Element:
    """Create errordata html."""
    html = make_html()
    body = etree.SubElement(html, 'body')
    error_table = make_table(error_data_list)
    stat = statistics(error_table)
    body.append(stat)
    body.append(error_table)
    body.append(
        etree.fromstring('''
       <script
           src="https://gtsvn.uit.no/langtech/trunk/giella-core/scripts/javascript/tablesorter.js">
       </script>'''))  # noqa: E501

    return html


def write_html(html: etree.Element, result_file: str) -> None:
    """Write the report."""
    with open(result_file, 'wb') as result_stream:
        result_stream.write(
            etree.tostring(
                html,
                pretty_print=True,
                encoding='utf-8',
                xml_declaration=True))


def statistics(html):
    """Basic statistics

    presicion = tp / (tp + fp)
    recall = tp / (tp + fn)
    """
    searches = [
        './/p[@class="false_positive"]', './/p[@class="false_negative"]',
        './/p[@class="true_negative"]', './/p[starts-with(text(), "TP")]'
    ]

    results = [len(html.xpath(search)) for search in searches]
    stat = etree.Element('div')

    for text in [
            f'Total sentences: {sum(results)}',
            f'False positive: {results[0]}', f'False negative: {results[1]}',
            f'True negative: {results[2]}', f'True positive: {results[3]}',
            f'Presicion: {results[-1]*100/(results[-1] + results[0])}',
            f'Recall: {results[-1]*100/(results[-1] + results[1])}'
    ]:
        abba = etree.SubElement(stat, 'p')
        abba.text = text

    return stat


if __name__ == '__main__':
    ARGS = parse_options()
    CORPUS = 'goldstandard' if ARGS.goldstandard else 'correct-no-gs'
    RUNNER = util.ExternalCommandRunner()
    SENTENCES = get_sentences(ARGS.zcheck_file, CORPUS)

    POOL = multiprocessing.Pool(multiprocessing.cpu_count() * 2)
    RESULTS = [
        POOL.apply_async(
            make_gramcheck_runs,
            args=(
                error_sentence,
                correct_sentence,
                ARGS.zcheck_file,
                RUNNER,
            )) for error_sentence, correct_sentence in SENTENCES
        if error_sentence.strip()
        and not ('Nu fal. Nu dehalaš' in error_sentence
                 or 'Okta joavku mas čuojahan' in error_sentence)
    ]

    GRAMCHECK_RESULTS = [result.get() for result in RESULTS]

    HTML = create_html(sorted(GRAMCHECK_RESULTS))
    write_html(HTML, ARGS.result_file)
