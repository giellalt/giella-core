#!/bin/env python3
"""Generate VISL CG3 LISTS from lexc Multichar_Symbols."""

import sys
from argparse import ArgumentParser, FileType
from typing import TextIO


def main():
    """Command-line interface to convertion."""
    arp = ArgumentParser(description="Convert lexc multichars to VISL CG 3")
    arp.add_argument("-i", "--input", metavar="INFILE", type=open,
                     dest="infile", help="read lexc from INFILE",
                     required=True)
    arp.add_argument("-o", "--output", metavar="OUTFILE", type=FileType("w"),
                     dest="outfile", help="write VISL CG3 to OUTFILE",
                     required=True)
    arp.add_argument("-v", "--verbose", action="store_true",
                     help="print verbosely while opeartioning")
    options = arp.parse_args()
    if options.verbose:
        print(f"Reading lexc {options.infile.name}...")
    multichars = []
    in_multichar = False
    for line in options.infile:
        if "!" in line:
            line = line.split("!")[0]
        if "Multichar_Symbols" in line:
            in_multichar = True
            continue
        elif "LEXICON" in line:
            in_multichar = False
            break
        if in_multichar:
            mcs = line.split()
            for mc in mcs:
                multichars.append(mc)
    multichars = sorted(multichars)
    semtags = []
    for multichar in multichars:
        if multichar.startswith("+Sem/"):
            semtags.append(multichar[1:])
    semtags = sorted(semtags)
    for semtag in semtags:
        if "_" not in semtag:
            maincat = semtag.split("/")[1]
            cattags = []
            for tag in semtags:
                if maincat in tag.split("/")[1].split("_"):
                    cattags.append(tag)
            print(f"LIST {semtag} = " + " ".join(sorted(cattags)) + " ;",
                  file=options.outfile)
    print("\nLIST SEMTAGS = " + " ".join(semtags) + " ;", file=options.outfile)


if __name__ == "__main__":
    main()
