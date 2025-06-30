#!/usr/bin/env -S uv run --script
#
# /// script
# requires-python = "==3.12"
# dependencies = [
#     "hfst",]
# ///

import re
import sys
import tempfile
from argparse import ArgumentParser

import hfst


def load_hfst(filename: str):
    try:
        his = hfst.HfstInputStream(filename)
        return his.read()
    except hfst.exceptions.NotTransducerStreamException:
        raise IOError(2, filename) from None


def hidelexcescapes(s: str) -> str:
    s = s.replace("%!", "@EXCLAMATIONMARK@")
    s = s.replace("%:", "@COLON@")
    s = s.replace("%<", "@LESSTHAN@")
    s = s.replace("% ", "@SPACE@")
    if "<" in s and ">" in s:
        s = re.sub("<.*>", "@REGEX@", s)
    if "\"" in s:
        s = s.replace("%\"", "@QUOTATIONMARK@")
        if "\"" in s:
            # archaic translation comment
            s = re.sub("\".*\"", "", s)
    return s


def unhidelexcescapes(s: str, unescape=True) -> str:
    if unescape:
        s = s.replace("@EXCLAMATIONMARK@", "!")
        s = s.replace("@COLON@", ":")
        s = s.replace("@LESSTHAN@", "<")
        s = s.replace("@SPACE@", " ")
        s = s.replace("@QUOTATIONMARK@", "\"")
    else:
        s = s.replace("@EXCLAMATIONMARK@", "%!")
        s = s.replace("@COLON@", ":")
        s = s.replace("@LESSTHAN@", "<")
        s = s.replace("@SPACE@", " ")
        s = s.replace("@QUOTATIONMARK@", "%\"")
    return s


def killflagdiacritics(s: str) -> str:
    if "@" in s:
        s = re.sub("@[CRDPN].[^@]*@", "", s)
    return s


def main():
    argp = ArgumentParser()
    argp.add_argument("-l", "--lexc", type=open, dest="lexcfile",
                      help="read lemmas from the lexc file",
                      required=True)
    argp.add_argument("-a", "--analyser", type=str, dest="analyserfilename",
                      help="FST analyser for analysing missing lemmas",
                      required=True)
    argp.add_argument("-g", "--generator", type=str, dest="generatorfilename",
                      help="FST generator file for generating the forms",
                      required=True)
    argp.add_argument("-t", "--tags", action="append",
                      help="tags that lemma form should have in generator",
                      required=True)
    argp.add_argument("-T", "--threshold", type=int,
                      help="required % proportion of succesful generations",
                      default=99)
    argp.add_argument("-d", "--debug", action="store_true", default=False,
                      help="prints debugging outputs")
    argp.add_argument("-v", "--verbose", action="store_true", default=False,
                      help="prints some outputs")
    argp.add_argument("-Z", "--acceptable-forms", type=open,
                      help="do not count oov if analysis contained in file")
    argp.add_argument("-X", "--exclude", action="append",
                      help="exclude lines matching regex")
    argp.add_argument("-Q", "--oov-limit", type=int, default=1000,
                      help="stop trying after so many oovs")
    options = argp.parse_args()
    logfile = tempfile.NamedTemporaryFile(prefix="paradigm", suffix=".txt",
                                          delete=False, encoding="UTF-8",
                                          mode="w+")
    generator = load_hfst(options.generatorfilename)
    analyser = load_hfst(options.analyserfilename)
    skipforms = None
    if options.acceptable_forms:
        skipforms = [l.strip() for l in options.acceptable_forms.readlines()]
    lemmas = set()
    for lexcline in options.lexcfile:
        if not lexcline or lexcline.strip() == "":
            continue
        if options.exclude:
            excluded = False
            for exclusion in options.exclude:
                if re.search(exclusion, lexcline):
                    excluded = True
            if excluded:
                continue
        # preproc
        lexcline = hidelexcescapes(lexcline)
        if "!" in lexcline:
            lexcline = lexcline.split("!")[0]
        lexcline = lexcline.strip()
        lexcline = killflagdiacritics(lexcline)
        # see stuff
        if lexcline.startswith("LEXICON "):
            continue
        elif not lexcline or lexcline == "":
            continue
        if ";" not in lexcline:
            continue
        if "+Err" in lexcline:
            continue
        if ":" in lexcline:
            analysis = unhidelexcescapes(lexcline.split(":")[0])
            lemma = analysis.split("+")[0]
            lemmas.add(lemma)
        else:
            idstringy = unhidelexcescapes(lexcline.split()[0])
            lemma = idstringy.split("+")[0]
            lemmas.add(lemma)
    lines = 0
    oovs = 0
    for lemma in lemmas:
        if lemma in {"", "#", "#;"}:
            continue
        failed = True
        for tagstring in options.tags:
            generations = generator.lookup(lemma + tagstring,
                                           time_cutoff=0.1)
            if len(generations) == 0:
                if options.verbose:
                    print(f"{lemma}{tagstring} does not generate!")
            else:
                failed = False
        if skipforms and lemma in skipforms:
            continue
        lines += 1
        if failed:
            oovs += 1
            for tagstring in options.tags:
                print(f"{lemma}{tagstring}", file=logfile)
            analyses = analyser.lookup(lemma,
                                       time_cutoff=0.1)
            if len(analyses) > 0:
                print(f"\tN.B: {lemma} has following analyses", file=logfile)
                for analysis in analyses:
                    print(f"\t{analysis}", file=logfile)
            if oovs >= options.oov_limit:
                print("too many fails, bailing to save time...")
                break
    if lines == 0:
        print(f"SKIP: could not find lemmas in {options.lexcfile.name}")
        sys.exit(77)
    coverage = (1.0 - (float(oovs) / float(lines))) * 100.0
    if options.verbose:
        print("Lemma statistics:")
        print(f"\t{len(lemmas)} lemmas")
        print(f"\t{coverage} % success")
    if coverage < options.threshold:
        print("FAIL: too many lemmas weren't generating!",
              f"{coverage} < {options.threshold}")
        print(f"see {logfile.name} for details ({oovs} ungenerated strings)")
        sys.exit(1)


if __name__ == "__main__":
    main()
