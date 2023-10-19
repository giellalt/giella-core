#!/bin/env python3
"""Convert giellalt dict to apertium bidix."""

import sys
import xml.etree.ElementTree
from argparse import ArgumentParser, FileType
from typing import TextIO


def giella2apes(giella: str) -> str:
    """Convert pos tag from giellalt dict to apertium."""
    if giella == "Adv":
        return "adv"
    elif giella == "A":
        return "adj"
    elif giella == "CC":
        return "cnjcoo"
    elif giella == "CS":
        return "cnjsub"
    elif giella == "Interj":
        return "ij"
    elif giella == "N":
        return "n"
    elif giella == "Num":
        return "num"
    elif giella == "Pcle":
        return "pcle"
    elif giella == "Po":
        return "post"
    elif giella == "Pr":
        return "pr"
    elif giella == "Pron":
        return "prn"
    elif giella == "Det":
        return "det"
    elif giella == "Prop":
        return "np"
    elif giella == "V":
        return "vblex"
    else:
        print(f"missing giella tag conversion for {giella}!")
        return "x"
    return "x"


def handle_mg(mg: xml.etree.ElementTree.Element, apes: dict,
              translations: list, transposes: list, examples: list,
              tranxamples: list):
    """Convert mg."""
    for morph in mg:
        if morph.tag == "tg":
            for trans in morph:
                if trans.tag == "t":
                    translations.append(trans.text)
                    transposes.append(giella2apes(trans.attrib["pos"]))
                elif trans.tag == "xg":
                    for example in trans:
                        if example.tag == "x":
                            examples.append(example.text)
                        elif example.tag == "xt":
                            tranxamples.append(example.text)
                        else:
                            print(f"Unrecognised {example.tag} under {trans.tag}")
                elif trans.tag == "re":
                    print(f"  context restriction? {trans.text}")
                else:
                    print(f"Unrecognised {trans.tag} under {morph.tag}")
        else:
            print(f"Unrecognised {morph.tag} under {mg.tag}")


def handle_e(e: xml.etree.ElementTree.Element, apes: dict, output: TextIO):
    """Convert and print dictionary entry e."""
    lemma = None
    pos = None
    translations = []
    transposes = []
    examples = []
    tranxamples = []
    for child in e:
        if child.tag == "lg":
            for lex in child:
                lemma = lex.text
                pos = giella2apes(lex.attrib["pos"])
        elif child.tag == "mg":
            handle_mg(child, apes, translations, transposes,
                      examples, tranxamples)
        else:
            print(f"Unrecognised {child.tag} under {e.tag}")
            sys.exit(1)
    if not lemma:
        print("Couldn't find source lemma in this <e>:", e)
        return
    if not pos:
        print("Couldnt't  find source pos in this <e>:", e)
        return
    src_in_bidix = False
    if lemma + "\t" + pos in apes:
        src_in_bidix = True
        print(f"    {lemma}.{pos} (already in dix)")
    else:
        print(f"    {lemma}.{pos}")
    for i, trans in enumerate(translations):
        print(f"        {trans}.{transposes[i]}")
        default = "y"
        if " " in trans:
            print("      (lemmas with spaces get extra weight by default)")
            default = "3"
        elif "xxx" in trans:
            print("     (lemmas with todo symbols get ignored")
            default = "n"
        if src_in_bidix:
            if apes[lemma + "\t" + pos] == trans + "\t" + transposes[i]:
                print("(already in bidix skipping...)")
                continue
            else:
                print("     (existing in bidix as: " +
                      apes[lemma + "\t" + pos] + "; adding default weight)")
                default = "2"
        if i in examples:
            print(f"\t\"{examples[i]}\" ~ \"{tranxamples[i]}\"")
        answer = input("yes, no, quit, or integer weight? default: " +
                       default + ". ")
        if answer == "":
            answer = default
        if answer in ["y", "yes"]:
            print(f"    <e><p><l>{lemma}<s n=\"{pos}\"/></l>"
                  f"<r>{trans}<s n=\"{transposes[i]}\"/></r></p></e>",
                  file=output)
        elif answer in ["n", "no"]:
            pass
        elif answer in ["q", "quit"]:
            sys.exit(0)
        elif answer.isdigit():
            print(f"    <e w=\"{answer}\"><p><l>{lemma}<s n=\"{pos}\"/></l>"
                  f"<r>{trans}<s n=\"{transposes[i]}\"/></r></p></e>",
                  file=output)
        else:
            print(f"Wrong answer {answer}! Skippings to next...")


def read_apes(apefile: TextIO):
    """Extract bidix data from apertium dictionary."""
    apes = read_xml(apefile)
    root = apes.getroot()
    bidix = {}
    for child in root:
        if child.tag == "section":
            for entry in child:
                if entry.tag == "e":
                    srclemma = None
                    trglemma = None
                    srcpos = None
                    trgpos = None
                    for part in entry:
                        if part.tag == "i":
                            srclemma = part.text
                            trglemma = part.text
                            for tags in part:
                                if tags.tag == "s":
                                    srcpos = tags.attrib["n"]
                                    trgpos = tags.attrib["n"]
                                    break
                        elif part.tag == "p":
                            for side in part:
                                if side.tag == "l":
                                    srclemma = side.text
                                    for tags in side:
                                        if tags.tag == "s":
                                            srcpos = tags.attrib["n"]
                                            break
                                elif side.tag == "r":
                                    trglemma = side.text
                                    for tags in side:
                                        if tags.tag == "s":
                                            trgpos = tags.attrib["n"]
                                            break
                        elif part.tag == "re":
                            srclemma = "__regexp__"
                            trglemma = "__regexp__"
                    if not srclemma:
                        print("missing source lemma in: ", entry)
                        continue
                    if not srcpos:
                        print("missing source pos in: ", entry)
                        continue
                    if not trglemma:
                        print("missing target lemma in: ", entry)
                        continue
                    if not trgpos:
                        print("missing target pos in: ", entry)
                        continue
                    bidix[srclemma + "\t" + srcpos] = trglemma + "\t" + trgpos
    return bidix


def main():
    """Command-line interface to convertion."""
    arp = ArgumentParser(description="Merge giellalt dics with apertiums")
    arp.add_argument("-i", "--input", metavar="INFILE", type=open,
                     dest="infile", help="read giellalt dict from INFILE",
                     required=True)
    arp.add_argument("-o", "--output", metavar="OUTFILE", type=FileType("w"),
                     dest="outfile", help="write bidix fragment to OUTFILE",
                     required=True)
    arp.add_argument("-r", "--reference", metavar="APEFILE", type=open,
                     dest="apefile", help="read reference bidix from APEFILE")
    arp.add_argument("-y", "--accept-default", action="store_true",
                     help="non-interactive mode that selects default always")
    arp.add_argument("-v", "--verbose", action="store_true",
                     help="print verbosely while opeartioning")
    options = arp.parse_args()
    if options.verbose:
        print(f"Reading apertium bidix from {options.apefile.name}...")
    apes = read_apes(options.apefile)
    if options.verbose:
        print(f"Reading giellaLT dictionary from {options.infile.name}...")
    giellalt = read_xml(options.infile)
    root = giellalt.getroot()
    for child in root:
        if child.tag == "lics":
            print("<!-- licences of original dictionary: ",
                  file=options.outfile)
            for lic in child:
                print(lic.text, file=options.outfile)
            print("-->", file=options.outfile)
        elif child.tag == "e":
            handle_e(child, apes, options.outfile)


def read_xml(xmlfile: TextIO):
    """Read a GiellaLT dictionary file."""
    xmldict = xml.etree.ElementTree.parse(xmlfile)
    return xmldict


if __name__ == "__main__":
    main()
