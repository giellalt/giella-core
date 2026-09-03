#!/usr/bin/env python3
"""Find corpus sentences containing the error forms of a speller typos list.

Given a typos list (`error <TAB> correction`) and one or more GiellaLT corpus
repositories, emit every sentence in the running text that contains one of the
error forms, as

    error <TAB> correction <TAB> sentence <TAB> source

Two things come out of this: error/correction pairs that are attested in real
text rather than only derivable from the lexicon, and the sentence context a
context-sensitive filter (CG) needs in order to be tuned.

ONLY `converted/` IS READ. `goldstandard/` and `correct-no-gs/` are siblings of
it in every corpus repository, so restricting the walk to `converted` excludes
the error-marked corpus structurally rather than by a name filter that could be
got wrong. That corpus is for evaluation and must never be mined for
development data.

The XML handling mirrors `corpus2rawtext.py`, which in turn mirrors
`ccat -a -l LANG`: only `<p>` elements with no `type` or `type="text"` are
visited, language is inherited down the tree so foreign-language paragraphs
contribute nothing, and `<hyph/>` is removed with the surrounding text joined.

Usage:
    corpus-match-typos.py -l sme -t typos.tsv -o out.tsv CORPUSDIR [CORPUSDIR ...]
"""

import argparse
import os
import re
import subprocess
import sys
import xml.etree.ElementTree as ET

XML_LANG = "{http://www.w3.org/XML/1998/namespace}lang"

# A token is a maximal run of letters plus the marks and joiners that occur
# inside Sámi words. Unicode categories are used rather than a literal alphabet
# so this needs no per-language configuration.
TOKEN_RE = re.compile(r"[^\W\d_]+(?:[-'’­][^\W\d_]+)*", re.UNICODE)

# Sentence boundary: terminal punctuation, then space, then something that can
# open a sentence. Deliberately conservative -- an ordinal like "1. čuoŋománu"
# or an abbreviation must not split, so a boundary is refused when the token
# before it is a single character or a known abbreviation.
BOUNDARY_RE = re.compile(r"(?<=[.!?…])[\"'”’)\]]*\s+")

ABBREVIATIONS = {
    "jna", "ee", "dm", "ovd", "sh", "gč", "nr", "s", "m", "mr", "b", "d",
    "bl", "ca", "cca", "dhr", "e", "ev", "f", "ex", "fr", "gc", "j", "jhk",
    "km", "kr", "l", "lg", "mgs", "n", "o", "od", "os", "p", "pst", "r",
    "st", "t", "tj", "v", "vg", "ám", "áv",
}


def element_language(element, parent_language):
    return element.get(XML_LANG, parent_language)


def strip_hyphenation(paragraph):
    """Remove `<hyph/>`, joining the text it interrupts."""
    for parent in paragraph.iter():
        children = list(parent)
        for child in children:
            if child.tag != "hyph":
                continue
            tail = child.tail or ""
            index = children.index(child)
            if index == 0:
                parent.text = (parent.text or "") + tail
            else:
                previous = children[index - 1]
                previous.tail = (previous.tail or "") + tail
            parent.remove(child)


def paragraph_text(element, language, wanted):
    """Concatenate the text of `element`, keeping only `wanted` language."""
    if element_language(element, language) != wanted:
        return ""
    parts = [element.text or ""]
    for child in element:
        if child.tag == "correct":
            # ccat with no error options keeps the erroneous surface form and
            # discards the correction. The regular corpus carries no error
            # markup today, but mirror the semantics rather than rely on that.
            parts.append(child.tail or "")
            continue
        parts.append(paragraph_text(child, element_language(element, language), wanted))
        parts.append(child.tail or "")
    return "".join(parts)


def document_paragraphs(path, wanted):
    """Yield the running-text paragraphs of one converted document."""
    try:
        tree = ET.parse(path)
    except ET.ParseError as error:
        print(f"skipping unparseable {path}: {error}", file=sys.stderr)
        return
    root = tree.getroot()
    language = root.get(XML_LANG, wanted)
    body = root.find("body")
    if body is None:
        return
    for paragraph in body.iter("p"):
        kind = paragraph.get("type")
        if kind not in (None, "text"):
            continue
        strip_hyphenation(paragraph)
        text = paragraph_text(paragraph, language, wanted)
        text = " ".join(text.split())
        if text:
            yield text


def split_sentences(paragraph):
    """Split a paragraph into sentences, refusing boundaries after
    abbreviations and single characters."""
    pieces = BOUNDARY_RE.split(paragraph)
    sentences = []
    for piece in pieces:
        if not piece:
            continue
        if sentences:
            previous = sentences[-1]
            tokens = TOKEN_RE.findall(previous)
            last = tokens[-1].lower() if tokens else ""
            if last in ABBREVIATIONS or (len(last) == 1 and previous.rstrip().endswith(".")):
                sentences[-1] = previous + " " + piece
                continue
        sentences.append(piece)
    return [s.strip() for s in sentences if s.strip()]


def load_typos(path):
    """Read `error <TAB> correction`, ignoring comments and blank lines.

    Returns a mapping from the error form to the list of its corrections, and
    a lowercase index so a sentence-initial capitalised occurrence is found."""
    corrections = {}
    with open(path, encoding="utf-8") as handle:
        for line in handle:
            line = line.rstrip("\n")
            if not line.strip() or line.lstrip().startswith("#"):
                continue
            fields = line.split("\t")
            if len(fields) < 2:
                continue
            error, correction = fields[0].strip(), fields[1].strip()
            if not error or not correction:
                continue
            corrections.setdefault(error, [])
            if correction not in corrections[error]:
                corrections[error].append(correction)
    lowered = {}
    for error in corrections:
        lowered.setdefault(error.lower(), []).append(error)
    return corrections, lowered


def match_sentence(sentence, corrections, lowered):
    """Return (error, correction, how) for each error form in `sentence`.

    A match is refused when the surface token is itself one of the corrections
    for that error. Without this the capitalisation entries invert: a list
    saying `divtasvuona -> Divtasvuona` means writing the name in lower case is
    the error, so finding the properly capitalised `Divtasvuona` in running
    text and reporting it as an error is exactly backwards."""
    hits = []
    for index, token in enumerate(TOKEN_RE.findall(sentence)):
        if token in corrections:
            for correction in corrections[token]:
                if correction != token:
                    hits.append((token, correction, "exact"))
            continue
        # A lowercase error form is written capitalised when it opens a
        # sentence. Only accept that in first position -- accepting it anywhere
        # makes every capitalised proper noun match its lowercase entry.
        if index != 0:
            continue
        if token[:1].isupper() and token[1:].islower():
            for error in lowered.get(token.lower(), []):
                if error == token or not error.islower():
                    continue
                for correction in corrections[error]:
                    if correction in (token, error):
                        continue
                    hits.append((token, correction, "sentence-initial"))
    return hits


def classify_error_forms(forms, analyser, lookup="hfst"):
    """Split the error forms by whether the NORMATIVE analyser accepts them.

    Use `analyser-gt-norm`, not `analyser-gt-desc`. The descriptive analyser
    deliberately accepts misspellings so it can tag them `+Err/Orth`, which
    makes it useless as a test of whether a form is a real word. The normative
    analyser accepts correct forms only, which is exactly the question here.

    * `invalid` -- rejected, so the form is not a word of the language and an
                   occurrence in running text is a genuine error.
    * `valid`   -- accepted, so the form is also a legitimate word and a corpus
                   hit proves nothing. `sámi` is a real word whose typos entry
                   asks for the genitive `sámij`; matching it would collect
                   sentences where the spelling is correct.
    """
    ordered = sorted(forms)
    try:
        finished = subprocess.run(
            [lookup, "lookup", "-q", analyser],
            input="\n".join(ordered) + "\n",
            capture_output=True, text=True, check=True,
        )
    except (OSError, subprocess.CalledProcessError) as error:
        print(f"analyser lookup failed ({error}); skipping classification",
              file=sys.stderr)
        return {}

    analyses = {}
    for line in finished.stdout.splitlines():
        fields = line.split("\t")
        if len(fields) < 2:
            continue
        surface, analysis = fields[0], fields[1]
        analyses.setdefault(surface, []).append(analysis)

    classes = {}
    for form in ordered:
        found = analyses.get(form, [])
        accepted = [a for a in found if not a.endswith("+?")]
        classes[form] = "valid" if accepted else "invalid"
    return classes


def corpus_files(directory, excluded=frozenset()):
    """Yield every converted XML file under one corpus repository."""
    root = directory
    if os.path.isdir(os.path.join(directory, "converted")):
        root = os.path.join(directory, "converted")
    elif os.path.basename(os.path.normpath(directory)) != "converted":
        print(
            f"warning: {directory} has no converted/ subdirectory; "
            "reading it directly",
            file=sys.stderr,
        )
    for base, subdirs, names in os.walk(root):
        if base == root:
            subdirs[:] = [d for d in subdirs if d not in excluded]
        for name in sorted(names):
            if name.endswith(".xml"):
                yield os.path.join(base, name)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("-l", "--language", required=True,
                        help="three-letter code, e.g. sme")
    parser.add_argument("-t", "--typos", required=True,
                        help="typos list: error <TAB> correction")
    parser.add_argument("-o", "--output", required=True)
    parser.add_argument("--min-tokens", type=int, default=3,
                        help="drop sentences shorter than this (default 3)")
    parser.add_argument("--max-per-error", type=int, default=0,
                        help="cap sentences kept per error form, 0 = no cap")
    parser.add_argument("-a", "--analyser",
                        help="NORMATIVE analyser (analyser-gt-norm.hfstol), "
                             "used to drop error forms that are also real "
                             "words. Do not pass the descriptive analyser: it "
                             "accepts misspellings on purpose so it can tag "
                             "them +Err/Orth, and cannot answer this question.")
    parser.add_argument("--keep", default="invalid",
                        choices=["invalid", "all"],
                        help="which classes to match on. Default keeps only "
                             "forms the normative analyser rejects, which are "
                             "the ones that cannot be correct in any context.")
    parser.add_argument("--lookup", default="hfst",
                        help="hfst binary to run lookup with (default: hfst)")
    parser.add_argument("--exclude", action="append", default=None,
                        metavar="GENRE",
                        help="skip a converted/ subdirectory. Defaults to "
                             "'hist': historical documents predate the "
                             "orthographic standard, so matching a modern "
                             "typos list against them reports period-correct "
                             "spelling as error. In sme that genre is 5%% of "
                             "the files and produced 74%% of all matches. "
                             "Pass --exclude '' to disable.")
    parser.add_argument("directories", nargs="+")
    options = parser.parse_args()

    corrections, lowered = load_typos(options.typos)
    print(f"{len(corrections)} error forms loaded from {options.typos}",
          file=sys.stderr)

    classes = {}
    if options.analyser:
        classes = classify_error_forms(set(corrections), options.analyser,
                                       options.lookup)
        if classes:
            counts = {}
            for value in classes.values():
                counts[value] = counts.get(value, 0) + 1
            print("  classified: " + ", ".join(
                f"{k}={v}" for k, v in sorted(counts.items())), file=sys.stderr)
            wanted = {"invalid": {"invalid"},
                      "all": {"invalid", "valid"}}[options.keep]
            dropped = [f for f, c in classes.items() if c not in wanted]
            for form in dropped:
                del corrections[form]
            lowered = {}
            for error in corrections:
                lowered.setdefault(error.lower(), []).append(error)
            print(f"  keeping {options.keep}: {len(corrections)} error forms "
                  f"({len(dropped)} dropped)", file=sys.stderr)

    excluded = frozenset(
        g for g in (options.exclude if options.exclude is not None else ["hist"])
        if g
    )
    if excluded:
        print(f"  excluding genres: {', '.join(sorted(excluded))}",
              file=sys.stderr)

    kept = {}
    rows = []
    documents = 0
    sentences_seen = 0
    for directory in options.directories:
        if not os.path.isdir(directory):
            print(f"warning: no such directory {directory}, skipping",
                  file=sys.stderr)
            continue
        for path in corpus_files(directory, excluded):
            documents += 1
            for paragraph in document_paragraphs(path, options.language):
                for sentence in split_sentences(paragraph):
                    sentences_seen += 1
                    tokens = TOKEN_RE.findall(sentence)
                    if len(tokens) < options.min_tokens:
                        continue
                    for error, correction, how in match_sentence(
                            sentence, corrections, lowered):
                        if options.max_per_error:
                            seen = kept.get(error, 0)
                            if seen >= options.max_per_error:
                                continue
                            kept[error] = seen + 1
                        rows.append((error, correction, sentence, how,
                                     classes.get(error, "unclassified"),
                                     os.path.relpath(path, directory)))

    with open(options.output, "w", encoding="utf-8") as handle:
        handle.write("# error\tcorrection\tsentence\tmatch\tclass\tsource\n")
        for row in rows:
            handle.write("\t".join(row) + "\n")

    distinct = len({row[0] for row in rows})
    initial = sum(1 for row in rows if row[3] == "sentence-initial")
    print(
        f"{documents} documents, {sentences_seen} sentences scanned\n"
        f"{len(rows)} matches on {distinct} distinct error forms "
        f"({initial} sentence-initial) -> {options.output}",
        file=sys.stderr,
    )


if __name__ == "__main__":
    main()
