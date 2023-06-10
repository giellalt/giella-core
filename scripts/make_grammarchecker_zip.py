#!/usr/bin/env python3
# -*- coding:utf-8 -*-

# Copyright © 2023 UiT The Arctic University of Norway
# License: GPL3
# Author: Børre Gaup <borre.gaup@uit.no>
"""Make a grammarchecker zip archive without '-dev' variants"""
from lxml import etree
from zipfile import ZipFile
import sys


def get_pipespec(spec_file):
    """Remove all '-dev' pipelines."""
    pipespec = etree.parse(spec_file)
    for pipeline in pipespec.iter("pipeline"):
        if pipeline.xpath(".//*[contains(@n, './')]"):
            pipeline.getparent().remove(pipeline)

    return pipespec


def make_archive(specfile, archive_name):
    """Make grammarchecker archive without '-dev' variants."""
    pipespec = get_pipespec(specfile)
    with ZipFile(archive_name, "w") as archive_zip:
        archive_zip.writestr("pipespec.xml", etree.tostring(pipespec))

        for filename in {
            element.attrib.get("n") for element in pipespec.xpath(".//*[@n]")
        }:
            archive_zip.write(filename)


if __name__ == "__main__":
    try:
        make_archive(specfile=sys.argv[1], archive_name=sys.argv[2])
    except FileNotFoundError as error:
        raise SystemExit(error)
