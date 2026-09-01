#!/usr/bin/env python3
"""Extract raw running text from GiellaLT converted corpus XML.

Reads every `converted/**/*.xml` under one or more corpus repository
directories and writes one paragraph per line, in the shape the speller
weighting expects (`corpus2unigramlm.py` input): text followed by a `¶`
paragraph marker.

This is a dependency-free reimplementation of the default behaviour of
`ccat -a -l LANG` (CorpusTools) restricted to what the weighting needs, so
that a language build can use the corpus repos without acquiring a
CorpusTools/lxml dependency. Semantics deliberately mirrored from
corpustools/ccat.py:

* only `<p>` elements are visited, and only those whose `type` attribute is
  absent or `text` -- titles, list items and table cells are excluded;
* language is inherited down the tree from the document's `xml:lang`, and any
  element whose effective language is not the requested one contributes no
  text, so the Swedish/Norwegian/Finnish paragraphs and inline spans that are
  common in these documents do not end up in a Sámi language model;
* `<hyph/>` is removed and the text around it joined, so soft-hyphenated forms
  come out whole;
* `<correct>` children of error markup are skipped and the erroneous surface
  form kept, which is what ccat does with no error options.

Usage:
    corpus2rawtext.py -l sme -o out.txt DIR [DIR ...]

Each DIR may be either a corpus repository root (a `converted` subdirectory is
then used) or a directory of XML files. Missing directories are skipped with a
warning rather than treated as an error: the caller decides whether having no
corpus at all is fatal.
"""

import argparse
import os
import sys
import xml.etree.ElementTree as ET

XML_LANG = "{http://www.w3.org/XML/1998/namespace}lang"


def element_language(element, parent_language):
    """Return the effective language of `element`, inherited if not set."""
    return element.get(XML_LANG, parent_language)


def strip_hyphenation(paragraph):
    """Remove `<hyph/>` elements, joining the text they interrupt."""
    for parent in paragraph.iter():
        children = list(parent)
        for child in children:
            if child.tag != "hyph":
                continue
            tail = child.tail or ""
            index = list(parent).index(child)
            if index == 0:
                parent.text = (parent.text or "") + tail
            else:
                previous = list(parent)[index - 1]
                previous.tail = (previous.tail or "") + tail
            parent.remove(child)


def collect(element, language, wanted, out):
    """Append the text of `element` and its descendants to `out`."""
    own_language = element_language(element, language)
    if element.text and own_language == wanted:
        out.append(element.text)
    for child in element:
        if child.tag == "correct":
            continue
        collect(child, own_language, wanted, out)
        if child.tail and own_language == wanted:
            out.append(child.tail)


def paragraph_text(paragraph, document_language, wanted):
    """Return the one-line text of a paragraph, or None if it has none."""
    strip_hyphenation(paragraph)
    parts = []
    collect(paragraph, document_language, wanted, parts)
    text = " ".join("".join(parts).split())
    return text or None


def xml_files(directories, verbose):
    """Yield every .xml file under the converted/ part of each directory."""
    for directory in directories:
        root = directory
        if os.path.isdir(os.path.join(directory, "converted")):
            root = os.path.join(directory, "converted")
        if not os.path.isdir(root):
            print(f"corpus2rawtext: skipping missing {directory}", file=sys.stderr)
            continue
        if verbose:
            print(f"corpus2rawtext: reading {root}", file=sys.stderr)
        for dirpath, dirnames, filenames in os.walk(root):
            dirnames.sort()
            for filename in sorted(filenames):
                if filename.endswith(".xml"):
                    yield os.path.join(dirpath, filename)


def main():
    argp = argparse.ArgumentParser(description=__doc__)
    argp.add_argument("-l", "--lang", required=True,
                      help="ISO 639-3 code of the language to extract")
    argp.add_argument("-o", "--output", required=True,
                      help="write the extracted text to this file")
    argp.add_argument("-v", "--verbose", action="store_true", default=False)
    argp.add_argument("directories", nargs="+",
                      help="corpus repo roots, or directories of XML files")
    options = argp.parse_args()

    paragraphs = 0
    tokens = 0
    documents = 0
    unreadable = 0
    with open(options.output, "w", encoding="utf-8") as output:
        for path in xml_files(options.directories, options.verbose):
            try:
                tree = ET.parse(path)
            except ET.ParseError as error:
                unreadable += 1
                print(f"corpus2rawtext: cannot parse {path}: {error}",
                      file=sys.stderr)
                continue
            documents += 1
            document_language = tree.getroot().get(XML_LANG, options.lang)
            for paragraph in tree.iter("p"):
                kind = paragraph.get("type")
                if kind is not None and kind != "text":
                    continue
                if element_language(paragraph, document_language) != options.lang:
                    continue
                text = paragraph_text(paragraph, document_language, options.lang)
                if text is None:
                    continue
                print(text, "¶", file=output)
                paragraphs += 1
                tokens += text.count(" ") + 1

    print(f"corpus2rawtext: {documents} documents, {paragraphs} paragraphs, "
          f"{tokens} tokens", file=sys.stderr)
    if unreadable:
        print(f"corpus2rawtext: {unreadable} unparseable files skipped",
              file=sys.stderr)
    if not paragraphs:
        print("corpus2rawtext: no text extracted", file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
