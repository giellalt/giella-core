#!/usr/bin/env python3
# -*- coding:utf-8 -*-
# Copyright © 2021 UiT The Arctic University of Norway
# License: GPL3
'''Convert VISL CG3 to various simple to process things and stuff.'''

from argparse import ArgumentParser, FileType
import sys
from math import inf

def main():
    '''CLI for VISL CG conversion script.'''
    a = ArgumentParser()
    a.add_argument('-i', '--input', metavar='INFILE', type=open,
                   dest='infile', help='source of analysis data')
    a.add_argument('-v', '--verbose', action='store_true',
                   help='print verbosely while processing')
    a.add_argument('-o', '--output', metavar='OUTFILE', dest='outfile',
                   help='print output into OUTFILE', type=FileType('w'))
    a.add_argument('-t', '--target', metavar='TARGET',
                   help='extract named tag (defaults to lemma)',
                   default='lemma', choices=['lemma', 'phon'])
    a.add_argument('-F', '--format', metavar='OFORMAT',
                   help='output in OFORMAT',
                   default='tsv', choices=['tsv'])
    a.add_argument('-1', '--1-best', action='store_true', dest='onebest',
                   help='print 1-best of ambiguous cohort')

    options = a.parse_args()
    if not options.infile:
        options.infile = sys.stdin
    if not options.outfile:
        options.outfile = sys.stdout
    for line in options.infile:
        if not line or line.strip() == '':
            print(file=options.outfile)
        elif line.startswith('"<') and line.strip().endswith('>"'):
            surf = line.strip()[2:-2]
            nth = 0
        elif line.startswith('\t'):
            nth += 1
            if options.onebest and nth > 1:
                continue
            fields = line.split()
            stuff = None
            if options.target == 'lemma':
                mwestart = inf
                mweend = inf
                for i, tag in enumerate(fields):
                    if i < mwestart and tag.startswith('"'):
                        mwestart = i
                    if i < mweend and tag.endswith('"'):
                        mweend = i
                    if mweend < inf and mwestart < inf:
                        break
                    # XXX: all mwe's are joined with simple space
                stuff = ' '.join(fields[mwestart:mweend+1])[1:-1]
            elif options.target == 'phon':
                phonstart = inf
                phonend = inf
                for i, tag in enumerate(fields):
                    if phonend == inf and tag.startswith('"'):
                        phonstart = i
                    if phonend == inf and tag.endswith('"phon'):
                        phonend = i
                    if phonend < inf and phonstart < inf:
                        break
                if phonend < inf and phonstart < inf:
                    stuff = ' '.join(fields[phonstart:phonend+1])[1:-5]
                else:
                    # phonetics is surface when not given
                    stuff = surf
            print(surf, stuff, '# ' + line.strip(), sep='\t',
                  file=options.outfile)
        elif line.startswith(';'):
            pass
        else:
            print(line.strip('\n'), file=options.outfile)
    sys.exit(0)


if __name__ == '__main__':
    main()
