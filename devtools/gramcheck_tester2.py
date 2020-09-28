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


# Post process gramchecker results


def filter_dc(d_result, zcheck_file, runner):
    """Remove errors that cover the same area of the typo and msyn types."""
    d_errors = d_result['errs']

    fix_double_space(d_result, zcheck_file, runner)

    if any([d_error[3].startswith('punct-aistton') for d_error in d_errors]):
        for d_error in d_errors:
            fix_aistton(d_errors, d_errors.index(d_error), zcheck_file, runner)

    for d_error in d_errors:
        if d_error[3] == 'no-space-before-parent-start':
            fix_no_space_before_parent_start(d_error, d_errors, zcheck_file,
                                             runner)
        if d_error[3] == 'no-space-after-punct-mark':
            fix_no_space_after_punct_mark(d_error, d_errors, zcheck_file,
                                          runner)

    return d_result


def fix_double_space(d_result, zcheck_file, runner):
    d_errors = d_result['errs']

    double_spaces = get_unique_double_spaces(d_errors)
    remove_dupes(double_spaces, d_errors)

    for double_space in double_spaces:
        make_new_double_space_errors(double_space, d_result)

    new_double_spaces = get_unique_double_spaces(d_errors)

    for new_double_space in new_double_spaces:
        make_new_errors(new_double_space, d_result, zcheck_file, runner)

    d_errors.sort(key=sortByRange)


def fix_aistton(d_errors, position, zcheck_file, runner):
    d_error = d_errors[position]
    if d_error[3] == 'punct-aistton-left' and len(d_error[0]) > 1:
        sentence = d_error[0][1:]
        d_error[0] = d_error[0][0]
        d_error[5] = ['”']
        d_error[2] = d_error[1] + 1

        new_d_error = new_errors(sentence, zcheck_file, runner)
        if new_d_error:
            new_d_error[0][1] = d_error[1] + 1
            new_d_error[0][2] = d_error[1] + 1 + len(sentence)
            d_errors.insert(position + 1, new_d_error[0])

    if d_error[3] == 'punct-aistton-right' and len(d_error[0]) > 1:
        sentence = d_error[0][:-1]
        d_error[0] = d_error[0][-1]
        d_error[5] = ['”']
        d_error[1] = d_error[2] - 1

        new_d_error = new_errors(sentence, zcheck_file, runner)
        if new_d_error:
            new_d_error[0][1] = d_error[1] - len(sentence)
            new_d_error[0][2] = d_error[1]
            d_errors.insert(position, new_d_error[0])

    if d_error[3] == 'punct-aistton-both':
        previous_error = d_errors[position - 1]
        remove_previous = previous_error[1] == d_error[1] and previous_error[
            2] == d_error[2] and previous_error[3] == 'typo'

        sentence = d_error[0][1:-1]

        right_error = [part for part in d_error]
        right_error[0] = right_error[0][-1]
        right_error[5] = ['”']
        right_error[1] = right_error[2] - 1
        right_error[3] = 'punct-aistton-right'
        d_errors.insert(position + 1, right_error)

        d_error[0] = d_error[0][0]
        d_error[5] = ['”']
        d_error[2] = d_error[1] + 1
        d_error[3] = 'punct-aistton-left'

        new_d_error = new_errors(sentence, zcheck_file, runner)
        if new_d_error:
            new_d_error[0][1] = d_error[1] + 1
            new_d_error[0][2] = d_error[1] + 1 + len(sentence)
            d_errors.insert(position + 1, new_d_error[0])

        if remove_previous:
            del d_errors[position - 1]


def fix_no_space_before_parent_start(space_error, d_errors, zcheck_file,
                                     runner):
    for dupe in [
            d_error for d_error in d_errors if d_error[1:2] == space_error[1:2]
    ]:
        d_errors.remove(dupe)

    parenthesis = space_error[0].find('(')
    d_errors.append([
        space_error[0][parenthesis:], space_error[1] + parenthesis,
        space_error[2], space_error[3], space_error[4], [' ('], space_error[6]
    ])
    part1 = space_error[0][:parenthesis]
    start = space_error[1]
    end = space_error[1] + len(part1)
    if part1:
        add_part(part1, start, end, d_errors, zcheck_file, runner)

    part2 = space_error[0][parenthesis + 1:]
    start = space_error[1] + parenthesis + 1
    end = space_error[1] + parenthesis + 1 + len(part2)
    if part2:
        add_part(part2, start, end, d_errors, zcheck_file, runner)

    d_errors.sort(key=sortByRange)


def fix_no_space_after_punct_mark(punct_error, d_errors, zcheck_file, runner):
    remove_dupes([punct_error], d_errors)
    error_message = punct_error[4]
    current_punct = error_message[error_message.find('"') +
                                  1:error_message.rfind('"')]
    parenthesis = punct_error[0].find(current_punct)

    d_errors.append([
        punct_error[0][parenthesis:], punct_error[1] + parenthesis,
        punct_error[1] + parenthesis + len(punct_error[0][parenthesis:]),
        punct_error[3], punct_error[4],
        [f'{current_punct} {punct_error[0][parenthesis + 1:]}'], punct_error[6]
    ])

    part1 = punct_error[0][:parenthesis]
    start = punct_error[1]
    end = punct_error[1] + len(part1)
    if part1:
        add_part(part1, start, end, d_errors, zcheck_file, runner)

    part2 = punct_error[0][parenthesis + 1:]
    start = punct_error[1] + parenthesis + 1
    end = punct_error[1] + parenthesis + 1 + len(part2)
    if part2:
        add_part(part2, start, end, d_errors, zcheck_file, runner)

    d_errors.sort(key=sortByRange)


def get_unique_double_spaces(d_errors):
    double_spaces = []
    indexes = set()
    for d_error in d_errors:
        if d_error[3] == 'double-space-before' and (d_error[1],
                                                    d_error[2]) not in indexes:
            double_spaces.append(d_error)
            indexes.add((d_error[1], d_error[2]))

    return double_spaces


def remove_dupes(double_spaces, d_errors):
    for removable_error in [
            d_error for double_space in double_spaces for d_error in d_errors
            if double_space[1:2] == d_error[1:2]
    ]:
        d_errors.remove(removable_error)


def make_new_double_space_errors(double_space, d_result):
    d_errors = d_result['errs']
    parts = double_space[0].split('  ')

    for position, part in enumerate(parts[1:], start=1):
        error = f'{parts[position - 1]}  {part}'
        start = d_result['text'].find(error)
        end = start + len(error)
        candidate = [
            error, start, end, 'double-space-before',
            f'Leat guokte gaskka ovdal "{part}"',
            [f'{parts[position - 1]} {part}'], 'Sátnegaskameattáhusat'
        ]
        if candidate not in d_errors:
            d_errors.append(candidate)


def make_new_errors(double_space, d_result, zcheck_file, runner):
    d_errors = d_result['errs']
    parts = double_space[0].split('  ')

    error = double_space[0]
    min = 0
    max = len(error)
    position = d_errors.index(double_space)
    for new_position, part in enumerate(
        [part for part in double_space[0].split() if part], start=position):
        part_errors = new_errors(part, zcheck_file, runner)
        min = error[min:max].find(part)
        for p_error in part_errors:
            p_error[1] = min + double_space[1]
            p_error[2] = min + double_space[1] + len(part)
            d_errors.insert(new_position, p_error)


def sortByRange(error):
    return error[1:2]


def new_errors(sentence, zcheck_file, runner):
    runner.run(f'divvun-checker -a {zcheck_file} '.split(),
               to_stdin=sentence.encode('utf-8'))

    return json.loads(runner.stdout)['errs']


def add_part(part, start, end, d_errors, zcheck_file, runner):
    errors = new_errors(part, zcheck_file, runner)
    for error in [error for error in errors if error]:
        candidate = [
            error[0], start, end, error[3], error[4], error[5], error[6]
        ]
        if candidate not in d_errors:
            d_errors.append(candidate)


if __name__ == '__main__':
    ARGS = parse_options()
    print('Getting all sentences that should be checked …')
    TEXT = {
        text: {
            'error': errors,
            'filename': filename
        }
        for text, errors, filename in get_all([ARGS.target])
    }
    RUNNER = util.ExternalCommandRunner()
    print('Running grammar checker …')
    gramcheck_output = gramcheck('\n'.join(TEXT), ARGS.zcheck_file, RUNNER)
    print('Post processing grammar checker output …')
    for line in gramcheck_output.decode('utf-8').split('\n'):
        if line:
            gram_error = json.loads(line.encode('utf-8'))
            TEXT[gram_error['text']]['gram_error'] = filter_dc(
                gram_error, ARGS.zcheck_file, RUNNER)

    with open(f'{ARGS.target.replace("/", "_")}.pickle',
              'wb') as pickle_stream:
        pickle.dump([(text, TEXT[text]['error'], TEXT[text]['filename'],
                      TEXT[text]['gram_error'])
                     for text in TEXT], pickle_stream)
