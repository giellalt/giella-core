#!/usr/bin/env python3
# -*- coding:utf-8 -*-
import argparse
import json
import multiprocessing
import pickle

from lxml import etree

from corpustools import ccat, util


def make_gramcheck_runs(text, error, filename, zcheck_file, runner):
    try:
        return text, error, filename, gramcheck(text, zcheck_file, runner)
    except json.decoder.JSONDecodeError:
        print(f'gramcheck error: {text, filename}')


def gramcheck(sentence: str, zcheck_file: str,
              runner: util.ExternalCommandRunner) -> dict:
    """Run the gramchecker on the error_sentence."""
    runner.run(f'divvun-checker -a {zcheck_file} '.split(),
               to_stdin=sentence.encode('utf-8'))

    return runner.stdout


def parse_options():
    """Parse the options given to the program."""
    parser = argparse.ArgumentParser(
        description='Print the contents of a corpus in XML format\n\
        The default is to print paragraphs with no type (=text type).')

    parser.add_argument('zcheck_file', help='The grammarchecker archive')
    parser.add_argument('target',
                        help='Name of the file or directorie to process. \
                        If a directory is given, all files in this directory \
                        and its subdirectories will be listed.')

    args = parser.parse_args()
    return args


def get_all(targets):
    for filename in ccat.find_files(targets, '.xml'):
        root = etree.parse(filename)
        for para in root.iter('p'):
            parts = []
            errors = []
            print_orig(parts, errors, para)
            text = ''.join(parts)
            if not text.startswith('#'):
                yield text.replace('\n',
                                   ' '), [error for error in errors
                                          if error], filename


def get_error_corrections(para):
    parts = []
    if para.text is not None:
        parts.append(para.text)
    for child in para:
        parts.append(child.get('correct'))
        for grandchild in child:
            parts.append(get_error_corrections(grandchild))

    if not len(para) and para.tail:
        parts.append(para.tail)

    return ''.join(parts)


def print_orig(parts, errors, para):
    info = {}
    if para.tag.startswith('error'):
        for name, value in para.items():
            info[name] = value
        info['type'] = para.tag
        info['start'] = len("".join(parts))
        info['error'] = get_error_corrections(para) if len(para) else para.text

    if para.text:
        parts.append(para.text)

    for child in para:
        errors.append(print_orig(parts, errors, child))

    if para.tag.startswith('error'):
        info['end'] = len("".join(parts))

    if para.tail:
        parts.append(para.tail)

    return info


def fix_double_space_d_error(d_error, zcheck_file, runner):
    """Fix double space errors reported by divvun-checker."""
    double_space_position = d_error[0].find('  ')
    if double_space_position == -1:
        new_errors = [[
            "  ", d_error[1] - 2, d_error[1], d_error[3], d_error[4], [' '],
            d_error[6]
        ]]
        return new_errors

    new_errors = []
    if double_space_position:
        before_json = gramcheck(d_error[0][:double_space_position],
                                zcheck_file, runner)
        for before_d_error in before_json['errs']:
            before_d_error[1] += d_error[1]
            before_d_error[2] += d_error[1]
            new_errors.append(before_d_error)

    new_errors.append([
        "  ", d_error[1] + double_space_position,
        d_error[1] + double_space_position + 2, d_error[3], d_error[4], [' '],
        d_error[6]
    ])

    after_json = gramcheck(d_error[0][double_space_position + 2:], zcheck_file,
                           runner)
    for after_d_error in after_json['errs']:
        after_d_error[1] += d_error[1] + double_space_position + 2
        after_d_error[2] += d_error[1] + double_space_position + 2
        new_errors.append(after_d_error)

    return new_errors


if __name__ == '__main__':
    ARGS = parse_options()
    TEXT = {
        text: {
            'error': errors,
            'filename': filename
        }
        for text, errors, filename in get_all([ARGS.target])
    }
    RUNNER = util.ExternalCommandRunner()
    gramcheck_output = gramcheck('\n'.join(TEXT), ARGS.zcheck_file, RUNNER)
    for line in gramcheck_output.decode('utf-8').split('\n'):
        if line:
            gram_error = json.loads(line.encode('utf-8'))
            TEXT[gram_error['text']]['gram_error'] = gram_error

    with open(f'{ARGS.target.replace("/", "_")}.pickle',
              'wb') as pickle_stream:
        pickle.dump([(text, TEXT[text]['error'], TEXT[text]['filename'],
                      TEXT[text]['gram_error'])
                     for text in TEXT], pickle_stream)
