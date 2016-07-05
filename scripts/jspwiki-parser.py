#!/usr/bin/env python3
# -*- coding: utf-8 -*-

'''Parse a jspwiki document

!!!Main tags
section1, 2, 3

Må starte med 1, kan ikke hoppe fra 1 til 3

section kan inneholde
p, ol, ul, dl, pre, hl, br

!!!Inline tags

bold, italic, monospace, link
'''
import fileinput
import re
import sys


jspwiki = re.compile('^([!#*]|-{4,}$)')


def parse_block(block):
    for b in block:
        if jspwiki.match(b):
            print(b)
    else:
        pass


def parse_blocks(blocks):
    for block in blocks:
        parse_block(block)


def main():
    block = []
    blocks = []
    for line in fileinput.FileInput(sys.argv[1]):
        if line.strip():
            block.append(line.strip())
        else:
            if block:
                blocks.append(block)
            block = []

    parse_blocks(blocks)


if __name__ == '__main__':
    main()
