#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Test sort | uniq -c | sort -nr'd gold analysis data for faithfulness
"""


import sys
from argparse import ArgumentParser, FileType
from time import perf_counter, process_time

import libhfst


def load_hfst(filename: str):
    """Load an HFST model from file with error handling."""
    try:
        his = libhfst.HfstInputStream(filename)
        return his.read()
    except libhfst.NotTransducerStreamException:
        raise IOError(2, filename) from None


def fsa_analyse(fsa: libhfst.HfstTransducer, surf: str):
    """Analyse wordform with FSA, with optional recasing."""
    res = fsa.lookup(surf)
    if not res:
        if len(surf) > 1 and surf[0].islower():
            res = fsa.lookup(surf[0].upper() + surf[1:])
    return res


def main():
    """Command-line interface for omorfi's sort | uniq -c tester."""
    a = ArgumentParser()
    a.add_argument("-a", "--analyser", metavar="FSAFILE", required=True,
                   help="load analyser from FSAFILE")
    a.add_argument("-i", "--input", metavar="INFILE", type=open,
                   dest="infile", help="source of analysis data")
    a.add_argument("-m", "--missing", metavar="MISSFILE",
                   type=FileType("w"),
                   dest="missfile", help="write missing list to MISSFILE")
    a.add_argument("-n", "--near-misses", metavar="NMFILE",
                   type=FileType("w"),
                   dest="nearmissfile", help="write deriv comp only to NMFILE")
    a.add_argument("-o", "--output", metavar="OUTFILE",
                   type=FileType("w"),
                   dest="outfile", help="write output to OUTFILE")
    a.add_argument("-X", "--statistics", metavar="STATFILE",
                   type=FileType("w"),
                   dest="statfile", help="statistics")
    a.add_argument("-v", "--verbose", action="store_true", default=False,
                   help="Print verbosely while processing")
    a.add_argument("-c", "--count", metavar="FREQ", default=0,
                   help="test only word-forms with frequency higher than FREQ")
    a.add_argument("-t", "--threshold", metavar="THOLD", default=99, type=int,
                   help="if coverage is less than THOLD exit with error")
    a.add_argument("-Q", "--no-hacks", action="store_true", default=False,
                   help="Some ccat and giellalt specific corpus hacks")
    a.add_argument("-q", "--quiet", action="store_true", default=False,
                   help="be more quiet")
    options = a.parse_args()
    try:
        if not options.outfile:
            options.outfile = sys.stdout
            if options.verbose:
                print("writing output to stdout verbosely",
                      file=options.outfile)
        if options.verbose:
            print(f"reading analyser from {options.analyser}",
                  file=options.outfile)
        fsa = load_hfst(options.analyser)
        if not options.infile:
            options.infile = sys.stdin
            print("reading from <stdin>", file=options.outfile)
        else:
            if options.verbose:
                print(f"reading corpus from {options.infile.name}",
                      file=options.outfile)
        if not options.statfile:
            options.statfile = sys.stdout
        else:
            if options.verbose:
                print(f"writing statistics to {options.statfile.name}",
                      file=options.outfile)
        if not options.missfile:
            options.missfile = sys.stdout
    except IOError:
        print(f"Could not process file{options.analyser}",
              file=sys.stderr)
        sys.exit(2)
    # basic statistics
    covered = 0
    no_results = 0
    tokens = 0
    # types
    types_covered = 0
    types_no_results = 0
    types = 0
    # for make check target
    threshold = options.threshold
    realstart = perf_counter()
    cpustart = process_time()
    for line in options.infile:
        fields = line.strip().replace(" ", "\t", 1).split("\t")
        if len(fields) < 2:
            print("ERROR: Skipping line", fields, file=sys.stderr)
            continue
        freq = int(fields[0])
        if freq < int(options.count):
            break
        surf = fields[1]
        if not options.no_hacks:
            if surf == "¶":
                if not options.quiet:
                    print(f"WARN: skipping paragraph marker {fields}",
                          file=sys.stderr)
                continue
            elif len(surf) > 120:
                if not options.quiet:
                    print(f"WARN: Skipping overlong token {fields}",
                          file=sys.stderr)
                continue
        tokens += freq
        types += 1
        if options.verbose:
            print(f"{tokens} ({freq})...", end="\r")
        analyses = fsa_analyse(fsa, surf)
        if analyses:
            covered += freq
            types_covered += 1
            all_comps = True
            all_derivs = True
            all_comps_or_derivs = True
            for analysis in analyses:
                if "+Der" not in analysis[0]:
                    all_derivs = False
                if "+Cmp" not in analysis[0]:
                    all_comps = False
                if "+Cmp" not in analysis[0] and "+Der" not in analysis[0]:
                    all_comps_or_derivs = False
            if all_comps:
                print("C", freq, surf, sep="\t", file=options.nearmissfile)
            elif all_derivs:
                print("D", freq, surf, sep="\t", file=options.nearmissfile)
            elif all_comps_or_derivs:
                print("CD", freq, surf, sep="\t", file=options.nearmissfile)
        else:
            no_results += freq
            types_no_results += 1
            print(freq, surf, sep="\t", file=options.missfile)
    realend = perf_counter()
    cpuend = process_time()
    print("CPU time:", cpuend - cpustart, "real time:", realend - realstart)
    if tokens == 0:
        print("Needs more than 0 tokens to determine something",
              file=sys.stderr)
        sys.exit(2)
    print("Tokens", "Covered", "OOV", sep="\t", file=options.statfile)
    print(tokens, covered, tokens - covered, sep="\t", file=options.statfile)
    coverage = covered / tokens * 100
    print(tokens / tokens * 100 if tokens != 0 else 0,
          covered / tokens * 100 if tokens != 0 else 0,
          (tokens - covered) / tokens * 100 if tokens != 0 else 0,
          sep="\t", file=options.statfile)
    print("Types", "Covered", "OOV", sep="\t", file=options.statfile)
    print(types, types_covered, types - types_covered, sep="\t",
          file=options.statfile)
    print(types / types * 100 if types != 0 else 0,
          types_covered / types * 100 if types != 0 else 0,
          (types - types_covered) / types * 100 if types != 0 else 0,
          sep="\t", file=options.statfile)
    if coverage < threshold:
        sys.exit(1)
    else:
        sys.exit(0)


if __name__ == "__main__":
    main()
