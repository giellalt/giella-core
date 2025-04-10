#!/usr/bin/env python3

# /// script
# dependencies = [
#     "lxml",
#     "pyhfst",
# ]
# ///
# anders: ^ this is called "inline script metadata", and is used by a tool
# called "uv" to run the script without having to manually manage dependencies.
# with this, if you have uv, you can just run "uv run SCRIPT ...SCRIPT-ARGS",
# without having to think about dependencies

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


def find_analyser_hfstol(input_lang: str, overridden_analyser: Path = None):
    if overridden_analyser is not None:
        if overridden_analyser.exists():
            return overridden_analyser
        else:
            sys.exit(
                "specific analyser given in --analyser was not found\n"
                f"{overridden_analyser}"
            )

    GTLANGS = os.environ["GTLANGS"]
    if GTLANGS:
        self_compiled_path = (
            Path(GTLANGS)
            / f"lang-{input_lang}"
            / "src"
            / "fst"
            / "analyser-gt-desc.hfstol"
        )
        if self_compiled_path.exists():
            return self_compiled_path

    nightly = Path(f"/usr/share/giella/{input_lang}/analyser-gt-desc.hfstol")
    if nightly.exists():
        return nightly


def parse_args():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "-v",
        "--verbose",
        action="store_true",
        help="Use verbose output (will be written to stderr)",
    )
    parser.add_argument(
        "-l",
        "--lang",
        required=True,
        help="input language (in 3-letter iso-639-3 format",
    )
    parser.add_argument(
        "-i",
        "--input",
        required=True,
        type=Path,
        help=(
            "dictionary xml file, or src/ directory in dict-xxx-yyy directory "
            "to extract lemmas from"
        ),
    )
    parser.add_argument(
        "--analyser",
        type=Path,
        help=(
            "Path to analyser hfstol file. If unspecified, will try to find "
            "it on the system. Tries to find self-compiled in $GTLANGS, or "
        ),
    )
    parser.add_argument(
        "-o",
        "--output",
        type=argparse.FileType("w"),
        default="-",
        help="file name to write output to. If not set, STDOUT is used.",
    )

    return parser.parse_args()


def main(args):
    desc_analyzer_path = find_analyser_hfstol(
        args.lang,
        overridden_analyser=args.analyser,
    )
    if desc_analyzer_path is None:
        sys.exit("cannot find analyser")

    if args.input.is_dir():
        files = args.input.glob("*.xml")
    elif args.input.is_file():
        files = [args.input]
    else:
        sys.exit(f"error: cannot find input file(s): {args.input}")

    if args.verbose:
        print(f"Loading analyser {desc_analyzer_path}...", file=sys.stderr)
    desc_analyzer = Analyzer(desc_analyzer_path)

    n = 0

    for file in files:
        if args.verbose:
            print(f"Processing file {file}...", file=sys.stderr)
        tree = ET.parse(file)
        root = tree.getroot()
        for lemma in root.findall("./e/lg/l"):
            is_compound = desc_analyzer.is_compound(lemma.text)
            is_lexc_lemma = desc_analyzer.is_lexc_lemma(lemma.text)
            if is_compound and not is_lexc_lemma:
                args.output.write(f"{lemma.text}\n")
                n += 1

    if args.verbose:
        print(f"Found {n} possible unlexicalized compounds", file=sys.stderr)


if __name__ == "__main__":
    raise SystemExit(main(parse_args()))
