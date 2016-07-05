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
import collections
import fileinput
import re
import sys


headers = re.compile('''^(!{1,3})\s*([^!]+)''')
ordered = re.compile('''^(#{1,3})\s*[^#]+''')
unordered =  re.compile('''^(\*{1,3})\s*[^*]+''')
horisontal = re.compile('''^(-{4,})$''')


Entry = collections.namedtuple('Entry', ['name', 'data'])


def test_match():
    for c in [(headers, '!'), (ordered, '#'), (unordered, '*')]:
        if not c[0].match('{} '.format(c[1])):
            print('{} did not pass'.format(c[1]))
        if not c[0].match('{} '.format(c[1] * 2)):
            print('{} did not pass'.format(c[1] * 2))
        if not c[0].match('{} '.format(c[1] * 3)):
            print('{} did not pass'.format(c[1] * 3))
        if c[0].match('{} '.format(c[1] * 4)):
            print('{} did not pass'.format(c[1] * 4))
    assert horisontal.match('a') is None
    assert horisontal.match('---') is None
    assert horisontal.match('----') is not None
    assert horisontal.match('-----') is not None
    assert horisontal.match('-------a;dskjfaf') is None


class DocMaker(object):
    def __init__(self):
        self.document = []
        self.tjoff = {
            '!': self.make_header,
            '*': self.make_unordered,
            '#': self.make_ordered,
            '-': self.make_horisontal,
            '|': self.make_table,
        }
        self.header_level = 0
        self.unordered_level = 0
        self.ordered_level = 0

    def make_ordered(self, b):
        print('ordered', b)

    def make_header(self, b):
        if headers.match(b):
            this_level = 4 - len(headers.match(b).group(1))
            if self.header_level == 0 and this_level != 1:
                raise ValueError(
                    'Error! Your first header must start with «!!!», but '
                    'starts with {}\n. This is the erroneous header '
                    '\n{}\nPlease fix this ' 'error'.format(headers.match(b).group(1), b))
            elif self.header_level == 1 and this_level == 3:
                raise ValueError(
                    'Error! This header starts with {}, but can only '
                    'start with «{}» or «{}». This is the erroneous '
                    'header\n{}\nPlease fix this error'.format(
                        headers.match(b).group(1), '!' * 3,
                        '!' * 2, b))
            else:
                self.header_level = this_level
                self.document.append(Entry(name='h{}'.format(this_level),
                                           data=[headers.match(b).group(2)]))
        else:
            raise ValueError('Fake header! {}'.format(b))

    def make_unordered(self, b):
        print('unordered', b)

    def make_horisontal(self, b):
        print('horisontal', b)

    def make_table(self, b):
        print('table', b)

    def handle_line(self, b):
        print('handle_line', b)

    def close_block(self):
        print('close_block\n')

    def parse_block(self, block):
        for b in block:
            if b[0] in self.tjoff.keys():
                self.tjoff[b[0]](b)
            else:
                self.handle_line(b)
        self.close_block()

    def parse_blocks(self):
        for block in self.make_blocks():
            self.parse_block(block)

    def make_blocks(self):
        block = []
        blocks = []
        for line in fileinput.FileInput(sys.argv[1]):
            if line.strip():
                block.append(line.strip())
            else:
                if block:
                    blocks.append(block)
                block = []

        return blocks


def main():
    dm = DocMaker()
    dm.parse_blocks()
    print(dm.document)

if __name__ == '__main__':
    main()
    test_match()
