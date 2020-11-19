#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
"""


from argparse import ArgumentParser, FileType
from sys import stderr, stdout, stdin


# Skip errors in all pos and lemma too:
#	different POS: N	≠ Err/Orth-a-á

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
#	different tags: Sem/Plc_Pos	 ~Sem/Plc
#

# ignore some " etc. punct

## count statistics of collapsings `^^


def main():
    """Command-line interface for omorfi's sort | uniq -c tester."""
    a = ArgumentParser()
    a.add_argument('-i', '--input', metavar="INFILE", type=open,
                   dest="infile", help="source of analysis data")
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
                if not surf in ambiguitypotential:
                    ambiguitypotential[surf] = cohortsize
                    ambiguityleft[surf] = len(selecteds)
                    if len(selecteds) > 1:
                        ambiguous[surf] = selecteds.copy()

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
            print("ERROR: Skipping line", line, file=stderr)
            continue
    if cohorts == 0:
        print("Needs more than 0 lines to determine something",
              file=stderr)
        exit(2)
    print("Tokens", "Analyses", "Selected", sep="\t")
    print(cohorts, ambiguity, selections, sep="\t")
    print("Ambiguity rate:", ambiguity / cohorts)
    print("Unresolved rate:", unresolveds / cohorts)
    for surf, readings in ambiguous.items():
        print(surf)
        print_ambiguity(readings)
    exit(0)


def print_ambiguity(readings):
    lemmas = set()
    mainposes = set()
    tagsets = set()
    reallyambig = False
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
                    '"S' in tag or 'SETCHILD' in tag:
                continue
            else:
                filteredtags.append(tag)
        if skippers:
            print("Skipped:", " ".join(skippers))
            continue
        lemmas.add(reading['lemma'])
        tagsets.add(' '.join(filteredtags))
        for tag in filteredtags:
            if tag in ['V', 'N', 'A', 'Adv', 'Num', 'CC', 'CS', 'Po', 'Pr',
                       'Interj']:
                mainposes.add(tag)
                break
    if len(lemmas) > 1:
        reallyambig = True
        print("\tdifferent lemmas:", "\t≠ ".join(lemmas))
    else:
        print("\tunambiguous lemma:", "".join(lemmas))
    if len(mainposes) > 1:
        reallymbig = True
        print("\tdifferent POS:", "\t≠ ".join(mainposes))
    else:
        print("\tunambiguous POS:", "".join(mainposes))
    if len(tagsets) > 1:
        reallyambig = True
        tagdiffs = list()
        for tagset in tagsets:
            for qtagset in tagsets:
                if qtagset == tagset:
                    continue
                if set(tagset.split()) - set(qtagset.split()):
                    tagdiffs += [" ".join(set(tagset.split()) - set(qtagset.split()))]
        if tagdiffs:
            print("\tdifferent tags:", "\t ~".join(tagdiffs))
    else:
        print("\tunambiguous tags:", "".join(tagsets)
    if not reallyambig:
        print("\tno real ambiguities??", lemmas, tagsets)

if __name__ == "__main__":
    main()
