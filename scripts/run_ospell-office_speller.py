#!/usr/bin/env python3

import subprocess
import sys
import time
import timeit
import resource

import pexpect

if len(sys.argv) < 4:
    print(
        '''
Runs the command line speller 'voikkospell' with input from INFILE,
writing the result to OUTFILE for the language given by LANGCODE,
optionally using the zhfst file found in DICTDIR.

Usage: $0 INFILE OUTFILE TIMEUSE LANGCODE [DICTDIR]

INFILE   = list of potential misspellings, one word pr line
OUTFILE  = output from speller
TIMEUSE  = filename for storing the elapsed time for the speller run
LANGCODE = ISO 639-1, -2 or -3 language code for the language to test
           Please use the 639-1 code if there is one.
DICTDIR  = directory containing a subdir 3/ containin a zhfst file.
           Optional. If not specified, speller files from the default
           directories will be used.


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


def test():
    INFILE = sys.argv[1]
    OUTFILE = sys.argv[2]
    LANGCODE = sys.argv[4]
    DICTDIR = sys.argv[5]

    COMMAND = 'hfst-ospell-office {}/{}.zhfst'.format(DICTDIR, LANGCODE)
    try:
        subp = subprocess.Popen(
            COMMAND.split(),
            stdin=open(INFILE, 'rb'),
            stdout=open(OUTFILE, 'wb')
        )
    except OSError:
        print('Please install {}'.format(COMMAND.split()[0]))
        sys.exit(2)

    subp.communicate()
    print(resource.getrusage(resource.RUSAGE_CHILDREN))

if __name__ == '__main__':
    TIMEUSE = sys.argv[3]
    with open(TIMEUSE, 'w') as timeuse:
        seconds = timeit.timeit(test, number=1)
        print("user\t%02dm%02.03fs" % divmod(seconds, 60), file=timeuse)
