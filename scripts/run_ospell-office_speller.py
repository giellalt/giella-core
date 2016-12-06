#!/usr/bin/env python3

import sys
import timeit
from collections import defaultdict

import pexpect

if len(sys.argv) < 4:
    print(
        '''
Runs the command line speller 'voikkospell' with input from INFILE,
writing the result to OUTFILE for the language given by LANGCODE,
optionally using the zhfst file found in DICTDIR.

Usage: {} INFILE OUTFILE TIMEUSE LANGCODE [DICTDIR]

INFILE   = list of potential misspellings, one word pr line
OUTFILE  = output from speller
TIMEUSE  = filename for storing the elapsed time for the speller run
LANGCODE = ISO 639-1, -2 or -3 language code for the language to test
           Please use the 639-1 code if there is one.
DICTDIR  = directory containing a subdir 3/ containin a zhfst file.
           Optional. If not specified, speller files from the default
           directories will be used.
        '''.format(sys.argv[0]),
        file=sys.stderr)
    sys.exit(1)


LANGCODE = sys.argv[4]
DICTDIR = sys.argv[5]

COMMAND = 'hfst-ospell-office {}/{}.zhfst'.format(DICTDIR, LANGCODE)

HFSTOSPELL = pexpect.spawn(COMMAND)


def set_baseline():
    """Get a baseline time for known words.

    Compute the time python uses to send and receive an answer for word
    known to hfst-ospell.
    """
    correct = '5 jïh\n'.encode('utf8')
    times = 10
    return timeit.timeit(
        'test({})'.format(correct),
        number=times,
        globals=globals()) / times


def test(word):
    HFSTOSPELL.send(word)
    HFSTOSPELL.expect('[*#&!].*\r\n')


if __name__ == '__main__':
    time = defaultdict(float)
    HFSTOSPELL.expect('@@ hfst-ospell-office is alive\r\n')
    with open(sys.argv[1], 'rb') as infile, open(sys.argv[2], 'wb') as outfile:
        basetime = set_baseline()
        for x, word in enumerate(infile, start=1):
            t = timeit.timeit(
                'test({})'.format(word), number=1, globals=globals())
            time['real'] += t
            time['user'] += (t - basetime)
            print(
                x, '{}: {:f}'.format(word.decode('utf8').strip(), t - basetime))
            outfile.write(HFSTOSPELL.after.replace(b'\x0D', b''))

    TIMEUSE = sys.argv[3]
    with open(TIMEUSE, 'w') as timeuse:
        for key in time.keys():
            uff = divmod(time[key], 60)
            print('{}\t{:d}m{:f}s'.format(key, int(uff[0]), uff[1]),
                  file=timeuse)
