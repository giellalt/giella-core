#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""Make typos file from orig/corr file pair."""

import re
import sys


def split_orig_sentence(orig_sentence):
    """Remove everything but words from orig_sentence."""
    words_re = re.compile("""\w+([-:/.,]\w+)*""")

    return [word.group() for word in words_re.finditer(orig_sentence)]


founds = 0
typos = 0
with open(sys.argv[1]) as origfile, open(sys.argv[2]) as correctfile:
    for line_no, sents in enumerate(zip(origfile, correctfile), start=1):
        split_orig = split_orig_sentence(sents[0])
        split_corr = sents[1].split()
        if len(split_orig) == len(split_corr):
            found = False
            report = []
            report.append(str(line_no))
            #report.append('orig:\t\t' + sents[0][:-1])
            #report.append('cleaned:\t' + ' '.join(split_orig_sentence(sents[0])))
            #report.append('correct:\t' + sents[1][:-1])
            for word_no, pairs in enumerate(zip(split_orig, split_corr), start=1):
                if pairs[0] != pairs[1]:
                    typos += 1
                    found = True
                    report.append('{}: {}\t{}'.format(word_no, pairs[0], pairs[1]))
            if found:
                founds += 1
                print('\n'.join(report))
                print()

print(founds, typos)
