#!/usr/bin/env python3
"""
Find compound lemmas which are not lexicalized. 
They should be for Neahttadigisánit lemma sorting to function properly.
The output list may be read by missing.py to create possible lexc entries.
"""
import sys
import os
import argparse
from pathlib import Path

MISSING_DEP_HELP = """
cannot run due to missing dependencies. hint, run:
/usr/bin/env python3 -m pip install pyhfst lxml
...and then try again.
"""

try:
    import pyhfst
    import lxml.etree as ET
except ImportError:
    exit(MISSING_DEP_HELP)


class Analyzer:
    def __init__(self, path):
        self.tr = pyhfst.HfstInputStream(path).read()

    def is_compound(self, word):
        """
        Returns True if at least one of the analyzes of the word includes
        the +Cmp tag, False otherwise
        """
        anls = self.tr.lookup(word)
        for anl in anls:
            if "+Cmp" in anl[0]:
                return True
        return False

    def is_lexc_lemma(self, word):
        """
        Returns True if at least one lemma analysis of the word is the word 
        itself (not a compound/derivation), False otherwise.
        """
        anls = self.tr.lookup(word)
        for anl in anls:
            lemma = anl[0].split("+")[0]
            if word == lemma:
                return True
        return False


def get_language_parent():
    lang_parent = os.getenv("GTLANGS")
    if not lang_parent:
        raise SystemExit("GTLANGS environment variable not set")

    lang_path = Path(lang_parent)
    if not lang_path.exists():
        raise SystemExit(f"Could not find the language directory {lang_path}")

    return lang_path

def parse_args():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("-l", "--lang", required=True, help="three-letter iso code of the input language")
    parser.add_argument("-i", "--input", required=True, type=Path, help="dictionary xml file to extract lemmas from")
    parser.add_argument("-o", "--output", type=Path, help="file name to write output to. If not set, STDOUT is used.")

    return parser.parse_args()


def main(args):
    lang_parent = get_language_parent()
    lang_directory = lang_parent / f"lang-{args.lang}"
    desc_analyzer_path = lang_directory / "src/fst/analyser-gt-desc.hfstol"
    desc_analyzer = Analyzer(desc_analyzer_path)

    unlex_comp = []

    tree = ET.parse(args.input)
    root = tree.getroot()
    for lemma in root.findall("./e/lg/l"):
        if desc_analyzer.is_compound(lemma.text) and not desc_analyzer.is_lexc_lemma(lemma.text):
            unlex_comp.append(lemma.text)
    
    print(f"Found {len(unlex_comp)} possible unlexicalized compounds")

    if args.output is None:
        sys.stdout.write("\n".join(l for l in unlex_comp))
    else:
        with open(args.output, "w") as f:
            f.write("\n".join(l for l in unlex_comp))


if __name__ == "__main__":
    raise SystemExit(main(parse_args()))