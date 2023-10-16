#!/usr/bin/env python3
"""Command-line tool to calculate errors per paragraph in giellalt corpus."""

import os
import xml.etree.ElementTree
from argparse import ArgumentParser


def handle_p(element: xml.etree.ElementTree, verbose: bool) -> dict:
    """count errors in paragraph."""
    errors = {"all": 0}
    for child in element:
        if child.tag.startswith("error"):
            errors["all"] += 1
            if child.tag in errors:
                errors[child.tag] += 1
            else:
                errors[child.tag] = 1
        elif child.tag == "em":
            pass
        else:
            print(f"Unrecognised {child.tag} in {element.tag}")
    if verbose:
        print(errors)
    return errors


def handle_body(element: xml.etree.ElementTree, verbose: bool) -> dict:
    """get paragraphs in body."""
    errorcount = {}
    for child in element:
        if child.tag == "p":
            errors = handle_p(child, verbose)
            for key, count in errors.items():
                if key in errorcount:
                    errorcount[key] += count
                else:
                    errorcount[key] = count
        else:
            print(f"skipping over {child.tag}")
    if verbose:
        print(errorcount)
    return errorcount


def count_errors_in_file(f: str, verbose: bool) -> dict:
    """Parse XML and count error stsatistsc."""
    tree = xml.etree.ElementTree.parse(f)
    root = tree.getroot()
    errorcount = {}
    for child in root:
        if child.tag == "header":
            pass
        elif child.tag == "body":
            errorcount = handle_body(child, verbose)
        else:
            print(f"skipping over {child.tag} in {root.tag}")
    if verbose:
        print(errorcount)
    return errorcount


def count_errors(path: str, verbose: bool) -> dict:
    """recursively check path for corpora."""
    errorcount = {}
    try:
        paths = os.listdir(path)
        for entry in paths:
            newpath = path + os.sep + entry
            if verbose:
                print(f"recursing to {newpath}")
            errors = count_errors(newpath, verbose)
            for key, count in errors.items():
                if key in errorcount:
                    errorcount[key] += count
                else:
                    errorcount[key] = count
    except NotADirectoryError:
        with open(path, encoding="UTF-8") as f:
            errors = count_errors_in_file(f, verbose)
            for key, count in errors.items():
                if key in errorcount:
                    errorcount[key] += count
                else:
                    errorcount[key] = count
    return errorcount


def main():
    """CLI for counting errors in corpus directories."""
    argp = ArgumentParser(description="Count errors in giellalt corpus")
    argp.add_argument("-i", "--input", metavar="INPATH", dest="inpath",
                      help="read giellalt corpora from INPATH recursively",
                      required=True)
    argp.add_argument("-v", "--verbose", action="store_true",
                      help="print verbosely while counting")
    options = argp.parse_args()
    if options.verbose:
        print(f"Reading corpora from {options.inpath}")
    stats = count_errors(options.inpath, options.verbose)
    print(stats)


if __name__ == "__main__":
    main()
