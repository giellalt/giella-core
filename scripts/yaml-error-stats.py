#!/bin/env python3

import re
import sys
from argparse import ArgumentParser


def main():
    argp = ArgumentParser()
    argp.add_argument("-i", "--input", metavar="INFILE", dest="infile",
                      type=open, help="read error corpus from INFILE")
    argp.add_argument("-v", "--verbose", action="store_true",
                      help="print verbosely while doing")
    options = argp.parse_args()
    if not options.infile:
        print("reading from <stdin>")
        options.infile = sys.stdin
    else:
        if options.verbose:
            print(f"reading from {options.infile.name}")
    tagstringcounts = {}
    tagcounts = {}
    sigilcounts = {}
    fixcounts = {}
    errorcount = 0
    for line in options.infile:
        if "{" not in line:
            continue
        yamlets = re.finditer(r"{([^}]*)}([£$¥€¢]){([^}]*)}", line)
        for error in yamlets:
            orig = error.group(1)
            sigil = error.group(2)
            correction = error.group(3)
            if "|" in correction:
                tagstring = correction.split("|")[0]
                tags = tagstring.split(",")
                fixed = correction.split("|")[1]
            else:
                fixed = correction
                tagstring = "UNANNOTATED"
                tags = ["UNANNOTATED"]
            if sigil in sigilcounts:
                sigilcounts[sigil] += 1
            else:
                sigilcounts[sigil] = 1
            if tagstring in tagstringcounts:
                tagstringcounts[tagstring] += 1
            else:
                tagstringcounts[tagstring] = 1
            if f"{orig}\t{fixed}" in fixcounts:
                fixcounts[f"{orig}\t{fixed}"] += 1
            else:
                fixcounts[f"{orig}\t{fixed}"] = 1
            for tag in tags:
                if tag in tagcounts:
                    tagcounts[tag] += 1
                else:
                    tagcounts[tag] = 1
            errorcount += 1
    print(f"{errorcount} errors:")
    print("error types:")
    for sigil, count in sorted(sigilcounts.items(), key=lambda x: x[1]):
        print(f"\t{sigil}\t{count}")
    print("more error types:")
    for tagstring, count in sorted(tagstringcounts.items(), key=lambda x: x[1]):
        print(f"\t{tagstring}\t{count}")
    print("error types split:")
    for tag, count in sorted(tagcounts.items(), key=lambda x: x[1]):
        print(f"\t{tag}\t{count}")


if __name__ == "__main__":
    main()
