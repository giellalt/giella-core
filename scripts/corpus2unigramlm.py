#!/usr/bin/env python3
"""Generate unigram LM data files from raw corpus files."""

import json
import re
from argparse import ArgumentParser
from collections import Counter
from math import log10

from termcolor import colored, cprint


def main():
    """CLI for GiellaLT lemma generation tests."""
    argp = ArgumentParser()
    argp.add_argument("-i", "--input", type=open, metavar="FILE",
                      help="read data from input FILE", required=True)
    argp.add_argument("-c", "--config", type=open, metavar="CONFFILE",
                      help="read config.json from CONFFILE", required=True)
    argp.add_argument("-d", "--debug", action="store_true", default=False,
                      help="prints debugging outputs")
    argp.add_argument("-v", "--verbose", action="store_true", default=False,
                      help="prints some outputs")
    options = argp.parse_args()
    configuration = json.load(options.config)
    alpha = configuration["alpha"]
    freqs = Counter()
    for line in options.input:
        tokens = re.split(r"\W+", line)
        freqs.update(tokens)
    corpussize = freqs.total()
    vocabsize = len(freqs)
    unkprob = alpha / (corpussize + vocabsize * alpha)
    coeff = configuration["maxweight"] / -log10(unkprob)
    for wordform in freqs:
        hatprob = (freqs[wordform] + alpha) / (corpussize + vocabsize * alpha)
        print(wordform, -log10(hatprob) * coeff, sep="\t")
    print("<unk>", -log10(unkprob) * coeff, sep="\t")


if __name__ == "__main__":
    main()
