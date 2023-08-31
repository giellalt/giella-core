#!/usr/bin/env python3
"""Turn arabic numbers into text on sami input.

Usage:
    * ccat -a -l XXX $GTFREE/converted/XXX $GTBOUND/converted/XXX | ./num2letters.py -l XXX
    * cat textfile | ./num2letters.py
    * echo string | ./num2letters.py

To run this script you need
    * hfst (apt install hfst)
    * corpustools (apt install python3-corpustools)
    * giella-XXX (apt install giella-XXX)
    * and a compiled lang-sXX

where XXX is one of sma, sme, smj, smn, sms

"""
import argparse
import os
import re
import sys
from subprocess import run

from corpustools import analyser

NUMBER_RE = re.compile('"<(?P<number>\d+.*)>"')


def digit_as_text(number, lang):
    digit_hfstol = os.path.join(
        os.getenv("GTLANGS"),
        f"lang-{lang}/src/transcriptions/transcriptor-numbers-digit2text.filtered.lookup.hfstol",
    )
    if not os.path.exists(digit_hfstol):
        raise SystemExit(f"{digit_hfstol} does not exist.\nPlease compile lang-{lang}")

    result = run(
        f"hfst-lookup -q {digit_hfstol}".split(),
        input=number,
        encoding="utf8",
        capture_output=True,
    )
    return result.stdout.split("\t")[1].replace("komma", "rihkku")


def generate_inflected_number(line, lang):
    generator = f"/usr/share/giella/{lang}/generator-gt-norm.hfstol"
    result = run(
        f"hfst-lookup -q {generator}".split(),
        input="+".join(make_generation_parts(line, lang)),
        encoding="utf8",
        capture_output=True,
    )
    return result.stdout.split()[1]


def parse_analysed_text(analysed_text, lang):
    interesting = False
    for line in analysed_text.split("\n"):
        if line.startswith(":"):
            if line.endswith("\\n"):
                yield "\n"
            else:
                yield line[1:]
        elif line.startswith('"'):
            match = NUMBER_RE.search(line)
            if match:
                number = match.groupdict()["number"]
                if number.endswith(".") or any(key in number for key in [".", ","]):
                    yield digit_as_text(number, lang)
                else:
                    interesting = True
            else:
                yield line[2:-2]
        else:
            if interesting:
                interesting = False

                yield generate_inflected_number(line, lang)


def make_generation_parts(line, lang):
    _, number, analysis = line.strip().split('"')
    parts = [
        part
        for part in analysis.strip().split()
        if not any(key in part for key in ["<", "@", "#", "Arab", "Sem"])
    ]

    parts.insert(
        0,
        digit_as_text(number.replace(" ", ""), lang),
    )

    return parts


def parse_arguments():
    parser = argparse.ArgumentParser(
        description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter
    )
    parser.add_argument(
        "-l", "--lang", required=True, choices=["sma", "sme", "smj", "sms", "smn"]
    )

    return parser.parse_args()


def main():
    args = parse_arguments()
    analysed_text = analyser.do_dependency_analysis(sys.stdin.read(), "hfst", args.lang)
    print("".join(parse_analysed_text(analysed_text, args.lang)))


if __name__ == "__main__":
    main()
