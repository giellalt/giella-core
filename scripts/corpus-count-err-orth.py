#!/usr/bin/env python3
import os
import re
import sys
from collections import Counter
from pathlib import Path

from lxml import etree

from corpustools import corpuspath


def get_paragraphs(analysed_file, parser):
    parsed = etree.parse(analysed_file, parser=parser)
    return parsed.find(".//dependency").text.split("<¶>")


def main():
    gtlangs = Path(os.getenv("GTLANGS"))
    parser = etree.XMLParser(huge_tree=True)
    sentence_enders = re.compile(r'[.!?]" CLB')

    for lang in sys.argv[1:]:
        analysed_directories = [
            gtlangs / corpus_directory / "analysed/"
            for corpus_directory in [
                f"corpus-{lang}",
                f"corpus-{lang}-x-closed",
            ]
        ]

        results = [
            "Err/Orth" in sentence
            for analysed_file in corpuspath.collect_files(
                analysed_directories,
                ".xml",
            )
            for paragraph in get_paragraphs(analysed_file, parser)
            for sentence in sentence_enders.split(paragraph)
        ]

        counts = Counter(results)
        print(
            f"{lang}: Error ratio: {counts[True] / len(results):.1%} of "
            f"{len(results)} sentences"
        )


if __name__ == "__main__":
    main()
