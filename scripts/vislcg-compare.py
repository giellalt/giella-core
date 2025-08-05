#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Compare two vislcg3 text format files for matches on each field.
"""


import sys
from argparse import ArgumentParser, FileType
from typing import TextIO


def read_cohorts(f: TextIO) -> list[dict]:
    """Read a VISLCG3 text cohort into a struct.

       Returns a list of all the dicts containing the cohorts in vislcg3 text
       or None if f contains no full cohorts.
    """
    cohorts = []
    cohort = {}
    for line in f:
        line = line.rstrip()
        if not line or line == "" or \
                line.startswith("#") or line.startswith(":"):
            if "surf" in cohort and "readings" in cohort:
                cohorts.append(cohort)
                cohort = {}
            else:
                continue
        elif line.startswith("\"<") and line.endswith(">\""):
            if "surf" in cohort and "readings" in cohort:
                cohorts.append(cohort)
                cohort = {}
            cohort["surf"] = line[2:-2]
            continue
        elif line.startswith(";"):
            continue
        elif line.startswith("\t") and line.lstrip().startswith("\""):
            refs = line.strip().split()
            reading = {}
            reading["tabs"] = line.count("\t")
            reading["lemma"] = refs[0][1:-1]
            reading["alltags"] = refs[1:]
            angletags = []
            tags = []
            suffixedtags = []
            deparrow = None
            deptag = None
            for tag in reading["alltags"]:
                if tag.startswith("#") and ("->" in tag or "→" in tag):
                    deparrow = tag
                elif tag.startswith("<") and tag.endswith(">"):
                    angletags.append(tag)
                elif tag.startswith("@"):
                    deptag = tag
                elif tag.startswith("\""):
                    suffixedtags.append(tag)
                else:
                    tags.append(tag)
            reading["tags"] = tags
            if angletags:
                reading["angletags"] = angletags
            if suffixedtags:
                reading["suffixed"] = suffixedtags
            if deparrow:
                reading["deparrow"] = deparrow
            if deptag:
                reading["deptag"] = deptag
            if "readings" not in cohort:
                cohort["readings"] = [reading]
            else:
                cohort["readings"].append(reading)
        else:
            print("Unparsable in VISLCG3 line:\n", line, file=sys.stderr)
            sys.exit(2)
    return cohorts


def main():
    """CLI for vislcg3 comparison."""
    a = ArgumentParser()
    a.add_argument("-H", "--hypothesis", metavar="HYPFILE", type=open,
                   required=True,
                   dest="hypfile", help="analysis results")
    a.add_argument("-r", "--reference", metavar="REFFILE", type=open,
                   required=True,
                   dest="reffile", help="reference data")
    a.add_argument("-l", "--log", metavar="LOGFILE",
                   type=FileType("w"),
                   dest="logfile", help="result file")
    a.add_argument("-X", "--realign", action="store_true", default=False,
                   help="Allow fuzzy matches if tokenisation differs")
    a.add_argument("-L", "--level", choices=["lemma", "tags", "deps", "all",
                                             "suffixed", "alltags"],
                   help="apply threshold to given fields only",
                   default="tags")
    a.add_argument("-v", "--verbose", action="store_true", default=False,
                   help="Print verbosely while processing")
    a.add_argument("-t", "--threshold", metavar="THOLD", default=99,
                   type=int,
                   help="require THOLD % for LEVEL or exit 1 (for testing)")
    options = a.parse_args()
    if not options.logfile:
        options.logfile = sys.stdout
    # count this
    cohort_matches = 0
    cohort_misses = 0
    tokenisation_errors = 0
    reading_matches = 0
    reading_misses = 0
    lemma_matches = 0
    lemma_misses = 0
    alltag_matches = 0
    alltag_misses = 0
    tag_matches = 0
    tag_misses = 0
    suffixed_matches = 0
    suffixed_misses = 0
    refcohorts = read_cohorts(options.reffile)
    hypcohorts = read_cohorts(options.hypfile)
    cohorts = max(len(refcohorts), len(hypcohorts))
    readings = 0  # cohorts != readings if more than 1 ambiguous gold
    if len(refcohorts) != len(hypcohorts):
        print(f"There's {len(refcohorts)} tokens in gold standard but "
              f"{len(hypcohorts)} in hypothesis file")
        print(f"Will only consider {min(len(refcohorts), len(hypcohorts))}")
    for gold, hyp in zip(refcohorts, hypcohorts):
        if gold == hyp:
            cohort_matches += 1
        else:
            cohort_misses += 1
            # don't log full miss
        if gold["surf"] != hyp["surf"]:
            tokenisation_errors += 1
            print(f"TOKENISATION\t{gold["surf"]}\t{hyp["surf"]}",
                  file=options.logfile)
        for goldreading in gold["readings"]:
            readings += 1
            matched = False
            found_lemma = False
            found_alltags = False
            found_alltags_subset = found_alltags
            found_tags = "tags" not in goldreading
            found_tags_subset = found_tags
            found_suffixed = "suffixed" not in goldreading
            for hypreading in hyp["readings"]:
                if hypreading == goldreading:
                    matched = True
                if hypreading["lemma"] == goldreading["lemma"]:
                    found_lemma = True
                if hypreading["alltags"] == goldreading["alltags"]:
                    found_alltags = True
                elif set(goldreading["alltags"]).issubset(set(hypreading["alltags"])):
                    found_alltags_subset = True
                if hypreading["tags"] == goldreading["tags"]:
                    found_tags = True
                elif set(goldreading["tags"]).issubset(set(hypreading["tags"])):
                    found_tags_subset = True
                if hypreading["suffixed"] == goldreading["suffixed"]:
                    found_suffixed = True
            if matched:
                reading_matches += 1
            else:
                reading_misses += 1
                # don't log full miss
            if found_lemma:
                lemma_matches += 1
            else:
                lemma_misses += 1
                print(f"LEMMA\t{goldreading["lemma"]}\t",
                      file=options.logfile)
                for hypothesis in hyp["readings"]:
                    print(f"\t\t{hypothesis["lemma"]}", file=options.logfile)
            if found_alltags:
                alltag_matches += 1
            elif found_alltags_subset:
                alltag_matches += 1
                print(f"ALLTAGS~\t{goldreading["alltags"]}", file=options.log)
            else:
                alltag_misses += 1
                print(f"ALLTAGS\t{goldreading["alltags"]}",
                      file=options.logfile)
                for hypothesis in hyp["readings"]:
                    print(f"\t!=\t{hypothesis["alltags"]}", file=options.logfile)
            if found_tags:
                tag_matches += 1
            elif found_tags_subset:
                tag_matches += 1
                print(f"TAGS~\t{goldreading["tags"]}", file=options.logfile)
            else:
                tag_misses += 1
                print(f"TAGS\t{goldreading["tags"]}", file=options.logfile)
                for hypothesis in hyp["readings"]:
                    print(f"\t!=\t{hypothesis["tags"]}", file=options.logfile)
            if found_suffixed:
                suffixed_matches += 1
            else:
                suffixed_misses += 1
                print("SUFFIX", ",".join(goldreading["suffixed"]), sep="\t",
                      file=options.logfile)
                for hypothesis in hyp["readings"]:
                    print(f"\t!=\t{hypothesis["suffixed"]}",
                          file=options.logfile)
    # stats
    if max(len(refcohorts), len(hypcohorts)) <= 0:
        print("could not read gold and/or hypothesis data")
        sys.exit(1)
    recall = cohort_matches / cohorts * 100
    reading_recall = reading_matches / readings * 100
    lemma_recall = lemma_matches / readings * 100
    alltag_recall = alltag_matches / readings * 100
    tag_recall = tag_matches / readings * 100
    suffixed_recall = suffixed_matches / readings * 100
    print(f"Total recall: {recall} % ({cohort_matches} of {cohorts})")
    print(f"Reading recall: {reading_recall} % "
          f"({reading_matches} of {readings})")
    print(f"Lemma recall: {lemma_recall} % "
          f"({lemma_matches} of {readings})")
    print(f"Tags recall: {tag_recall} % "
          f"({tag_matches} of {readings})")
    print(f"All tags recall: {alltag_recall} % "
          f"({alltag_matches} of {readings})")
    print(f"Suffixed tags recall: {suffixed_recall} % "
          f"({suffixed_matches} of {readings})")
    if options.level == "tags" and tag_recall < options.threshold:
        print("FAIL: too many missing tags "
              f"{tag_recall} < {options.threshold}")
        sys.exit(1)
    elif options.level == "lemma":
        print("FAIL: too many missing lemmas "
              f"{lemma_recall} < {options.threshold}")
        sys.exit(1)
    elif options.level == "suffixed" and suffixed_recall < options.threshold:
        print("FAIL: too many missing suffixed tags "
              f"{suffixed_recall} < {options.threshold}")
        sys.exit(1)
    elif options.level == "alltags" and alltag_recall < options.threshold:
        print("FAIL: too many missing tags overall "
              f"{alltag_recall} < {options.threshold}")
        sys.exit(1)
    else:
        print(f"PASS: see {options.logfile.name} for details")


if __name__ == "__main__":
    main()
