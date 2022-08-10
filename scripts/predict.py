#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Generate a prediction XRE."""

from argparse import ArgumentParser, FileType

import sys


def main():
    """Invoke CLI for predictor generator."""
    a = ArgumentParser()
    a.add_argument("-i", "--input", metavar="INFILE", type=open, dest="infile",
                   help="read alphabet from textfile INFILE")
    a.add_argument("-o", "--output", metavar="OUTFILE", type=FileType("w"),
                   dest="outfile", help="write predictore into OUTFILE")
    a.add_argument("-e", "--epsilon", metavar="EPS", default="0",
                   help="use EPS as epsilon symbol")
    a.add_argument("-w", "--default-weight", metavar="W", default=1.0,
                   type=float, help="use W prediction weight per character")
    a.add_argument("-r", "--regex", default=True)
    a.add_argument("-v", "--verbose", action="store_true",
                   help="print verbosely while processing")
    a.add_argument("-p", "--prefix-length", default=2, type=int,
                   help="how many characters to keep in beginning")
    a.add_argument("-P", "--predict-length", default=4, type=int,
                   help="how many characters to predict in end")
    options = a.parse_args()
    if options.verbose:
        print("being verbose...")
    if not options.infile:
        options.infile = sys.stdin
    if not options.outfile:
        options.outfile = sys.stdout
    if options.verbose:
        print(f"reading from {options.infile.name}...")
        print(f"writing to   {options.outfile.name}...")
    pairs = ["0:?::100.0"]
    for line in options.infile:
        if not line or line.strip() == "":
            continue
        if line.startswith("#"):
            continue
        fields = line.strip().split()
        if fields[0] in [":", "-", "0", "."]:
            fields[0] = "%" + fields[0]
        if len(fields) == 1 and fields[0] == "@@":
            break
        if len(fields) == 2:
            pairs += [f"0:{fields[0]}::{fields[1]}"]
        elif len(fields) == 1:
            pairs += [f"0:{fields[0]}::{options.default_weight}"]
        else:
            print(fields, "unrecognised", file=sys.stderr)
            sys.exit(1)
    print(" ".join(["?"]*options.prefix_length) + " ?* " +
          " ".join(["(" + "|".join(pairs) + ")"]*options.predict_length) +
          " ;", file=options.outfile)


if __name__ == "__main__":
    main()
