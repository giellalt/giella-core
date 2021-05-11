#!/usr/bin/env python3
# -*- coding:utf-8 -*-
# Copyright © 2021 UiT The Arctic University of Norway
# License: GPL3
'''Convert VISL CG3 to various simple to process things and stuff.'''

from argparse import ArgumentParser, FileType
import sys


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
        elif line.startswith('\t'):
            fields = line.split()
            stuff = fields[0][1:-1]
            if options.target == 'lemma':
                stuff = fields[0][1:-1]
            elif options.target == 'phon':
                for tag in fields:
                    if 'phon' in tag:
                        stuff = tag[1:-5]
                        break
            print(surf, stuff, '# ' + line.strip(), sep='\t',
                  file=options.outfile)
    sys.exit(0)


if __name__ == '__main__':
    main()
