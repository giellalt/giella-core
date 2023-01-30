#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Count some nice numbers from log and the gold data of unimorph.
"""


from argparse import ArgumentParser, FileType
from sys import stderr, stdout, stdin
from time import perf_counter, process_time

import sys


def optionalised_match(hyp, gold):
    optionals = ['TR', 'INTR']
    for opt in optionals:
        if opt in hyp['unimorph']:
            opted = hyp.copy()
            opted['unimorph'] = opted['unimorph'].replace(opt, '')
            if opted['unimorph'] == gold['unimorph']:
                return True
            elif permutate_match(opted, gold):
                return True
    return False


def permutate_match(hyp, gold):
    if hyp['lemma'] != gold['lemma']:
        return False
    if set(hyp['unimorph'].split(';')) == set(gold['unimorph'].split(';')):
        return True
    else:
        return False
    return False

def analyseoov(failline, logfile, oovstats):
    faillemma = failline.split()[-2]
    failtag = failline.split()[-1]
    if failtag not in oovstats:
        oovstats[failtag] = {}
    for line in logfile:
        if not line or line.strip() == "":
            return
        fields = line.rstrip().split()
        lemma = fields[0]
        giella = fields[1]
        giellatags = giella[giella.find('+'):]
        if giellatags not in oovstats[failtag]:
            oovstats[failtag][giellatags] = 0
        oovstats[failtag][giellatags] += 1
    return

def readwordsetloglog(file, oovstats):
    wordset = list()
    for line in file:
        if 'CPU time:' in line:
            continue
        elif 'reading from' in line:
            continue
        elif 'FAILED TO GENERATE' in line:
            oovstats['currentoov'] = True
            analyseoov(line, file, oovstats)
            return None
        fields = line.rstrip().split()
        if len(fields) == 0:
            return wordset
        elif len(fields) == 1 and '+' in line:
            continue
        elif len(fields) == 3:
            word = {}
            word['lemma'] = fields[0]
            word['surf'] = fields[1]
            word['unimorph'] = fields[2]
            wordset += [word]
        else:
            print('dataoissa wirhe: ', file, line)
            sys.exit(2)
    # after EOF
    return wordset


def readwordsetgold(file):
    wordset = list()
    for line in file:
        fields = line.rstrip().split()
        if len(fields) == 0:
            return wordset
        elif len(fields) == 3:
            word = {}
            word['lemma'] = fields[0]
            word['surf'] = fields[1]
            word['unimorph'] = fields[2]
            wordset += [word]
        else:
            print('datoissa virhe: ', file, line)
            sys.exit(2)
    # after EOF
    return wordset

def main():
    """Command-line interface for omorfi's sort | uniq -c tester."""
    a = ArgumentParser()
    a.add_argument('-l', '--logfile', metavar='LOGFILE', required=True,
                   help='Read logs in LOGFILE', type=open)
    a.add_argument('-g', '--goldfile', metavar='GOLDFILE', type=open,
                   help='Compare to gold in GOLDFILE', required=True)
    a.add_argument('-o', '--output', metavar='OUTFILE',
                   type=FileType('w'),
                   dest='outfile', help='log outputs to OUTFILE')
    a.add_argument('-X', '--statistics', metavar='STATFILE',
                   type=FileType('w'),
                   dest="statfile", help='statistics')
    a.add_argument('-v', '--verbose', action='store_true', default=False,
                   help='Print verbosely while processing')
    a.add_argument('-C', '--no-casing', action='store_true', default=False,
                   help='Do not try to recase input and output when matching')
    options = a.parse_args()
    if not options.statfile:
        options.statfile = stdout
    if not options.outfile:
        options.outfile = stdout
    # basic statistics
    oovs = 0
    full_matches = 0
    permutation_matches = 0
    fuzzy_matches = 0
    lgspec_misses = 0
    lines = 0
    oovstats = {'currentoov': False}
    # hacks
    # for make check target
    realstart = perf_counter()
    cpustart = process_time()
    finished = False
    while not finished:
        golds = readwordsetgold(options.goldfile)
        hyps = readwordsetloglog(options.logfile, oovstats)
        lines += len(golds)
        if oovstats['currentoov']:
            oovs += len(golds)
            oovstats['currentoov'] = False
            continue
        if not golds and not hyps:
            finished = True
            break
        elif not hyps:
            print('missing hyps!', golds)
            continue
        elif not golds:
            print('Skipped rest hyps!', hyps)
            finished = True
            break
        for gold in golds:
            full_matched = False
            fuzzy_matched = False
            permutation_matched = False
            for hyp in hyps:
                if hyp == gold:
                    full_matched = True
                elif permutate_match(hyp, gold):
                    permutation_matched = True
                elif optionalised_match(hyp, gold):
                    fuzzy_matched = True
            if full_matched:
                full_matches += 1
            elif permutation_matched:
                permutation_matches += 1
            elif fuzzy_matched:
                fuzzy_matches += 1
            elif 'LGSPEC' in gold['unimorph']:
                lgspec_misses += 1
            else:
                print('no match for', gold)
    realend = perf_counter()
    cpuend = process_time()
    print('CPU time:', cpuend - cpustart, 'real time:', realend - realstart)
    if lines == 0:
        print('Needs more than 0 lines to determine something',
              file=stderr)
        sys.exit(2)
    print('Lines', 'matches', 'fuzzy', 'skips', 'OOV', sep='\t',
          file=options.statfile)
    print(lines, full_matches, fuzzy_matches + permutation_matches,
          lgspec_misses, oovs, sep='\t',
          file=options.statfile)
    print(lines / lines * 100 if lines != 0 else 0,
          full_matches / lines * 100 if lines != 0 else 0,
          (fuzzy_matches + permutation_matches) / lines * 100
          if lines != 0 else 0,
          lgspec_misses / lines * 100 if lines != 0 else 0,
          oovs / lines * 100 if lines != 0 else 0,
          sep='\t', file=options.statfile)


if __name__ == '__main__':
    main()
