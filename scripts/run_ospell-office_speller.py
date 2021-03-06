#!/usr/bin/env python3

import argparse
import os
import sys
import timeit
from collections import defaultdict

import pexpect


def parse_options():
    parser = argparse.ArgumentParser(
        description='Runs the command line speller "{}"'.format(sys.argv[0])
    )
    parser.add_argument('infile',
                        help='The input for the speller.')
    parser.add_argument('outfile',
                        help='Output from the speller is written to'
                        'this file.')
    parser.add_argument('timeuse',
                        help='Time usage is written to this file.')
    parser.add_argument('langcode',
                        help='ISO 639-1, -2 or -3 language code '
                        'for the language to test. '
                        'Please use the 639-1 code if there is one.')
    parser.add_argument('dictdir',
                        help='directory containing a zhfst file.')

    return parser.parse_args()


def set_baseline(lang):
    """Get a baseline time for known words.

    Compute the time python uses to send and receive an answer for word
    known to hfst-ospell.

    Arguments:
        lang (str): a language code
    """
    testword = {
        'sma': 'jïh',
        'sme': 'ja',
        'smj': 'ja',
        'nob': 'ja',
        'fin': 'ja',
    }

    correct = '5 {}\n'.format(testword.get(lang, 'qw')).encode('utf8')
    times = 10
    return timeit.timeit(
        'test({})'.format(correct),
        number=times,
        globals=globals()) / times


def test(word):
    HFSTOSPELL.send(word)
    HFSTOSPELL.expect('[*#&!].*\r\n')


def imitate_bash_time(time):
    """Imitate the bash function time.

    Arguments:
        time (defaultdict of floats): contains real and user times.
    """
    with open(ARGS.timeuse, 'w') as timeuse:
        for key in time.keys():
            uff = divmod(time[key], 60)
            print('{}\t{:d}m{:f}s'.format(key, int(uff[0]), uff[1]),
                  file=timeuse)


ARGS = parse_options()
SPELLER_ARCHIVE = '{}/{}.zhfst'.format(ARGS.dictdir, ARGS.langcode)
if os.path.exists(SPELLER_ARCHIVE):
    HFSTOSPELL = pexpect.spawn(
        'hfst-ospell-office {}'.format(SPELLER_ARCHIVE))
else:
    raise SystemExit('{} does not exist'.format(SPELLER_ARCHIVE))


if __name__ == '__main__':
    time = defaultdict(float)
    HFSTOSPELL.expect('@@ hfst-ospell-office is alive\r\n')
    basetime = set_baseline(ARGS.langcode)

    max = 0
    min = 1000000

    with open(ARGS.infile, 'rb') as infile, open(ARGS.outfile, 'wb') as outfile:
        for x, word in enumerate(infile, start=1):
            t = timeit.timeit(
                'test({})'.format(word),
                number=1, globals=globals())
            time['real'] += t
            real = t - basetime
            if real < min:
                min = real
            if real > max:
                max = real
            time['user'] += real
            uff = '{:f}\t'.format(real)
            outfile.write(uff.encode('utf8'))
            outfile.write(HFSTOSPELL.after.replace(b'\x0D', b''))


        print('\nAverage speed:   {:f}'.format(time['user']/x))
        print('Min:             {:f}'.format(min))
        print('Max:             {:f}'.format(max))
        print('Baseline:        {:f}'.format(basetime))

    imitate_bash_time(time)
