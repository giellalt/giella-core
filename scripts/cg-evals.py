#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Calculate useful statistics from VISL CG 3 stream for further development.
"""


from argparse import ArgumentParser
import sys
from sys import stdin, stderr

# Skip errors in all pos and lemma too:
#    different POS: N ≠ Err/Orth-a-á

# skip tags:
# <mv>
# Err/
# Ex/
# v1 v2 G3
# §

# add # to dynamic compounds
# ... check if equal

# switch to skip gen - nom with same lemma

# fuzzy matching over the similar lemmas:
# mirkoávnnasgeavaheddjiiguin
# 	different lemmas: mirkoávnnasgeavaheaddji	≠ mirkuávnnasgeavaheaddji  #o<u
#

# collapse similar semtags:
# 	different tags: Sem/Plc_Pos	 ~Sem/Plc
#

# ignore some " etc. punct

# count statistics of collapsings `^^
def print_ambiguity(readings, surf, count=0, verbose=False):
    lemmas = set()
    mainposes = set()
    tagsets = set()
    reallyambig = False
    printbuffer = ""
    ambiglemma = False
    ambigpos = False
    ambigtags = False
    printbuffer = str(count) + "\t" + surf + ":\n"
    for reading in readings:
        filteredtags = list()
        skippers = list()
        for tag in reading['tags']:
            if 'Err/' in tag or '<spelled>' in tag or '&typo' in tag:
                skippers.append(tag)
                continue
            elif tag in ['v1', 'v2', 'v3', 'G3', '<mv>']:
                continue
            elif 'MAP' in tag or 'SUBSTITUTE' in tag or 'ADD' in tag or \
                    'Ex/' in tag or '<W' in tag or '§' in tag or \
                    'REMOVE' in tag or 'COPY' in tag or '&' in tag or \
                    '"S' in tag or 'SETCHILD' in tag or 'SETPARENT' in tag:
                continue
            elif tag.startswith('#'):
                continue
            else:
                filteredtags.append(tag)
        if skippers:
            # print("Skipped:", " ".join(skippers))
            continue
        lemmas.add(reading['lemma'])
        tagsets.add(' '.join(filteredtags))
        for tag in filteredtags:
            if tag in ['V', 'N', 'A', 'Adv', 'Num', 'CC', 'CS', 'Po', 'Pr',
                       'Interj', 'Pron']:
                mainposes.add(tag)
                break
    if len(lemmas) > 1:
        reallyambig = True
        ambiglemma = True
        printbuffer += "\tdifferent lemmas:\t" + " ≠\t".join(lemmas) + "\n"
    else:
        printbuffer += "\tunambiguous lemma:\t" + "".join(lemmas) + "\n"
    if len(mainposes) > 1:
        reallyambig = True
        ambigpos = True
        printbuffer += "\tdifferent POS:\t" + " ≠\t".join(mainposes) + "\n"
    else:
        printbuffer += "\tunambiguous POS:\t" + "".join(mainposes) + "\n"
    if len(tagsets) > 1:
        reallyambig = True
        tagdiffs = list()
        for tagset in tagsets:
            for qtagset in tagsets:
                if qtagset == tagset:
                    continue
                if set(tagset.split()) - set(qtagset.split()):
                    tagdiffs += [" ".join(set(tagset.split())
                                          - set(qtagset.split()))]
        if tagdiffs:
            ambigtags = True
            printbuffer += "\tdifferent tags:\t" + "\t- ".join(tagdiffs) + "\n"
    else:
        printbuffer += "\tunambiguous tags:\t" + "".join(tagsets) + "\n"
    if not reallyambig:
        printbuffer += "\tno real ambiguities??" + "".join(lemmas) + \
                       "".join(tagsets) + "\n"
    if ambigpos or ambiglemma:
        print(printbuffer)
    elif verbose and ambigtags:
        print(printbuffer)


def main():
    """Command-line interface for omorfi's sort | uniq -c tester."""
    a = ArgumentParser()
    a.add_argument('-i', '--input', metavar="INFILE", type=open,
                   dest="infile", help="source of analysis data")
    a.add_argument('-x', '--include-removed', action="store_true",
                   default=False, help="include disambiguated readings")
    a.add_argument('-v', '--verbose', action="store_true", default=False,
                   help="Print verbosely while processing")
    options = a.parse_args()
    if not options.infile:
        options.infile = stdin
        print("reading from <stdin>")
    surf = None
    removeds = list()
    selecteds = list()
    ambiguitypotential = dict()
    ambiguityleft = dict()
    ambiguous = dict()
    ambicount = dict()
    ambiguity = 0
    selections = 0
    cohorts = 0
    unresolveds = 0
    selecting = dict()
    removing = dict()
    for line in options.infile:
        if line.startswith('"<'):
            if surf:
                if cohorts % 10000 == 0:
                    print(cohorts, "... ")
                if selecting:
                    selecteds += [selecting]
                    selecting = dict()
                elif removing:
                    removeds += [removing]
                    removing = dict()
                # calc stats for cohort
                cohortsize = len(selecteds) + len(removeds)
                cohorts += 1
                ambiguity += cohortsize
                selections += len(selecteds)
                if len(selecteds) > 1:
                    unresolveds += 1
                if surf not in ambiguitypotential:
                    ambiguitypotential[surf] = cohortsize
                    ambiguityleft[surf] = len(selecteds)
                    if options.include_removed and len(selecteds) +\
                            len(removeds) > 1:
                        ambicount[surf] = 1
                        ambiguous[surf] = selecteds.copy + removeds.copy()
                    elif len(selecteds) > 1:
                        ambiguous[surf] = selecteds.copy()
                        ambicount[surf] = 1
                elif surf in ambicount:
                    ambicount[surf] += 1

            surf = line.strip()[2:-2]
            selecteds.clear()
            removeds.clear()
        elif line.startswith("\t"):
            fields = line.strip().split()
            if "\t\t" in line:
                selecting['lemma'] = fields[0][1:-1] + selecting['lemma']
            else:
                if selecting:
                    selecteds += [selecting]
                    selecting = dict()
                elif removing:
                    removeds += [removing]
                    removing = dict()
                selecting['lemma'] = fields[0][1:-1]
                selecting['tags'] = fields[1:]
        elif line.startswith(";"):
            fields = line.lstrip(";").strip().split()
            if "\t\t" in line:
                removing['lemma'] = fields[0][1:-1] + removing['lemma']
            else:
                if selecting:
                    selecteds += [selecting]
                    selecting = dict()
                elif removing:
                    removeds += [removing]
                    removing = dict()
                removing['lemma'] = fields[0][1:-1]
                removing['tags'] = fields[1:]
        elif line.startswith(":"):
            # ??? used in sme-tracegram
            continue
        elif line.startswith("\\n"):
            # ??? used in sme-tracegram
            continue
        elif line.strip() == "":
            continue
        else:
            # olggonjuovilvuohta
            print("ERROR: Skipping line", line, file=stderr)
            continue
    print("...Done!")
    if cohorts == 0:
        print("Needs more than 0 lines to determine something",
              file=stderr)
        sys.exit(2)
    print("Tokens", "Analyses", "Selected", sep="\t")
    print(cohorts, ambiguity, selections, sep="\t")
    print("Ambiguity rate:", ambiguity / cohorts)
    print("Unresolved rate:", unresolveds / cohorts)
    # for surf, readings in ambiguous.items():
    for surf, count in sorted(ambicount.items(), key=lambda x: x[1]):
        print_ambiguity(ambiguous[surf], surf, count)
    sys.exit(0)


if __name__ == "__main__":
    main()
