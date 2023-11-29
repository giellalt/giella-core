#!/bin/env python3
"""Convert giellalt dict to apertium bidix."""

import sys
import xml.etree.ElementTree
from argparse import ArgumentParser, FileType
from typing import TextIO


def handle_mg(mg: xml.etree.ElementTree.Element,
              translations: list, transposes: list, extras: list):
    """Convert mg."""
    for morph in mg:
        if morph.tag == "tg":
            for trans in morph:
                if trans.tag == "t":
                    translations.append(trans.text)
                    if "pos" not in trans.attrib:
                        print(f"Missing POS in {trans.text}...")
                        transposes.append("???")
                    else:
                        transposes.append(trans.attrib["pos"])
                    if "l_par" in trans.attrib:
                        extras.append("@l_par: " + trans.attrib["l_par"])
                    if "attr" in trans.attrib:
                        extras.append("@attr: " + trans.attrib["attr"])
                    if "wf" in trans.attrib:
                        extras.append("@wf: " + trans.attrib["wf"])
                    if "t_tld" in trans.attrib:
                        extras.append("@t_tld: " + trans.attrib["t_tld"])
                    if "tt_auto" in trans.attrib:
                        extras.append("@tt_auto: " + trans.attrib["tt_auto"])
                elif trans.tag == "xg":
                    for example in trans:
                        if example.tag == "x":
                            extras.append("x: " + example.text)
                        elif example.tag == "xt":
                            extras.append("xt: " + example.text)
                        else:
                            print(f"Unrecognised {example.tag} under {trans.tag}")
                elif trans.tag == "re":
                    extras.append("<re>" + trans.text + "</re>")
                elif trans.tag == "l_ref":
                    extras.append("<l_ref>" + trans.text + "</l_ref>")
                else:
                    print(f"Unrecognised {trans.tag} under {morph.tag}")
        elif morph.tag == "re":
            extras.append("<re>" + morph.text + "</re>")
        elif morph.tag == "l_ref":
            extras.append("<l_ref>" + morph.text + "</l_ref>")
        else:
            print(f"Unrecognised {morph.tag} under {mg.tag}")


def handle_e(e: xml.etree.ElementTree.Element, output: TextIO):
    """Convert and print dictionary entry e."""
    lemma = None
    pos = None
    translations = []
    transposes = []
    extras = []
    for child in e:
        if child.tag == "lg":
            for lex in child:
                lemma = lex.text
                pos = lex.attrib["pos"]
        elif child.tag == "mg":
            handle_mg(child, translations, transposes, extras)
        else:
            print(f"Unrecognised {child.tag} under {e.tag}")
            sys.exit(1)
    if not lemma:
        print("Couldn't find source lemma in this <e>:", e.tag, e.attrib,
              e.text)
        return
    if not pos:
        print("Couldnt't  find source pos in this <e>:", e.tag, e.attrib,
              e.text)
        return
    if len(translations) <= 1:
        return
    for i, trans in enumerate(translations):
        if i == 0:
            print("  {", file=output)
            print(f"    \"source\": \"{trans}+{transposes[i]}\",", file=output)
            print("    \"targets\": [", file=output)
        else:
            print("     {", file=output)
            print(f"      \"target\": \"{trans}+{transposes[i]}\"", file=output)
            if i < len(translations)-1:
                print("     },", file=output)
            else:
                print("     }", file=output)
    print("    ],", file=output)
    extras = [x.replace("\"", "”") for x in extras]
    print(f"    \"__extracomments\": \"{extras}\"", file=output)
    print("    },", file=output)


def main():
    """Command-line interface to convertion."""
    arp = ArgumentParser(description="Gather potential synonyms from dicts")
    arp.add_argument("-i", "--input", metavar="INFILE", type=open,
                     dest="infile", help="read giellalt dict from INFILE",
                     required=True)
    arp.add_argument("-o", "--output", metavar="OUTFILE", type=FileType("w"),
                     dest="outfile", help="write synonyms.json to OUTFILE",
                     required=True)
    arp.add_argument("-y", "--accept-default", action="store_true",
                     help="non-interactive mode that selects default always")
    arp.add_argument("-v", "--verbose", action="store_true",
                     help="print verbosely while opeartioning")
    options = arp.parse_args()
    if options.verbose:
        print(f"Reading giellaLT dictionary from {options.infile.name}...")
    print("{ \"Synonyms\": [", file=options.outfile)
    giellalt = read_xml(options.infile)
    root = giellalt.getroot()
    for child in root:
        if child.tag == "e":
            handle_e(child, options.outfile)
    print("] }", file=options.outfile)


def read_xml(xmlfile: TextIO):
    """Read a GiellaLT dictionary file."""
    xmldict = xml.etree.ElementTree.parse(xmlfile)
    return xmldict


if __name__ == "__main__":
    main()
