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
    runner.run(
        f'divvun-checker -a {zcheck_file} '.split(),
        to_stdin=sentence.encode('utf-8'))
    return json.loads(runner.stdout)


def parse_options():
    """Parse the options given to the program."""
    parser = argparse.ArgumentParser(
        description='Print the contents of a corpus in XML format\n\
        The default is to print paragraphs with no type (=text type).')

    parser.add_argument('zcheck_file', help='The grammarchecker archive')
    parser.add_argument(
        'targets',
        nargs='+',
        help='Name of the files or directories to process. \
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
                yield text.replace('\n', ' '), errors, filename


def print_orig(parts, errors, para):
    info = {}
    if para.tag.startswith('error'):
        for name, value in para.items():
            info[name] = value
        info['type'] = para.tag
        info['start'] = len("".join(parts))
        info['error'] = para.text if para.text is not None else ''

    if para.text:
        parts.append(para.text)

    for child in para:
        errors.append(print_orig(parts, errors, child))

    if para.tag.startswith('error'):
        info['end'] = len("".join(parts))

    if para.tail:
        parts.append(para.tail)

    return info


if __name__ == '__main__':
    ARGS = parse_options()
    RUNNER = util.ExternalCommandRunner()
    POOL = multiprocessing.Pool(multiprocessing.cpu_count() * 2)
    RESULTS = [
        POOL.apply_async(
            make_gramcheck_runs,
            args=(
                text,
                errors,
                filename,
                ARGS.zcheck_file,
                RUNNER
            )) for text, errors, filename in get_all(ARGS.targets)
        ]

    with open('results.pickle', 'wb') as pickle_stream:
        pickle.dump([result.get() for result in RESULTS], pickle_stream)
