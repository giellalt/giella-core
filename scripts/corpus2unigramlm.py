#!/usr/bin/env python3
"""Generate unigram LM data files from raw corpus files."""

import json
import re
from argparse import ArgumentParser, FileType
from collections import Counter
from math import log10

try:
    from termcolor import colored
except ImportError:
    def colored(s, _):
        """just give uncoloured strings if package is missing."""
        return s

def main():
    """CLI for GiellaLT lemma generation tests."""
    argp = ArgumentParser()
    argp.add_argument("-i", "--input", type=open, metavar="FILE",
                      help="read data from input FILE", required=True)
    argp.add_argument("-c", "--config", type=open, metavar="CONFFILE",
                      help="read config.json from CONFFILE", required=True)
    argp.add_argument("-d", "--debug", action="store_true", default=False,
                      help="prints debugging outputs")
    argp.add_argument("-w", "--weights", type=FileType("w"), required=True,
                      help="print weights in AT&T format in WFILE",
                      metavar="WFILE")
    argp.add_argument("-m", "--max-weight", type=FileType("w"), required=True,
                      help="print max weight in MWFILE", metavar="MWFILE")
    argp.add_argument("-v", "--verbose", action="store_true", default=False,
                      help="prints some outputs")
    options = argp.parse_args()
    configuration = json.load(options.config)
    if configuration["alpha"]:
        alpha = configuration["alpha"]
    else:
        alpha = 1
    freqs = Counter()
    for line in options.input:
        tokens = re.split(r"[0-9.?!*/\"“”’':,(){}¶]*\s+[0-9.(){}*\"’'/“”¶]*",
                          line)
        tokens = list(filter(None, tokens))
        freqs.update(tokens)
    corpussize = freqs.total()
    vocabsize = len(freqs)
    unkprob = alpha / (corpussize + vocabsize * alpha)
    if configuration["maxweight"]:
        coeff = configuration["maxweight"] / -log10(unkprob)
    else:
        coeff = 1
    for wordform in freqs:
        hatprob = (freqs[wordform] + alpha) / (corpussize + vocabsize * alpha)
        print(wordform.replace(":", "\\:"), -log10(hatprob) * coeff, sep="\t",
              file=options.weights)
    print(-log10(unkprob) * coeff, sep="\t", file=options.max_weight)
    topword = freqs.most_common(1)[0][0]
    topfreq = freqs.most_common(1)[0][1]
    tophatprob = (topfreq + alpha) / (corpussize + vocabsize * alpha)
    topweight = -log10(tophatprob) * coeff
    bottomword = freqs.most_common()[-1][0]
    bottomfreq = freqs.most_common()[-1][1]
    bottomhatprob = (bottomfreq + alpha) / (corpussize + vocabsize * alpha)
    bottomweight = -log10(bottomhatprob) * coeff
    oovweight = -log10(unkprob) * coeff
    print(colored("***", "cyan"), "Weighting statistics:")
    print(colored("***", "cyan"),
          colored(f"High: {topweight} (={topword} {topfreq}),", "green"))
    print(colored("***", "cyan"),
          colored(f"low: {bottomweight} (={bottomword} {bottomfreq}),",
                  "yellow"))
    print(colored("***", "cyan"),
          colored(f"OOV: {oovweight} (=<unk> 0)", "red"))
    print(colored("***", "cyan"),
          f"corpus: {corpussize}, vocab: {vocabsize}, coeff: {coeff}")


if __name__ == "__main__":
    main()
