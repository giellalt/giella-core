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
import os
import re
import sys


headers = re.compile('''^(!{1,3})\s*([^!]+)''')
ordered = re.compile('''^(#{1,3})\s*([^#]+)''')
unordered =  re.compile('''^(\*{1,3})\s*([^*]+)''')
horisontal = re.compile('''^(-{4,})$''')
complete_pre_inline = re.compile('''^(.*){{{(.+)}}}([^}]*)$''')
start_of_pre = re.compile('''^(.*){{{([^}]*)$''')
end_of_pre = re.compile('''^(.*)}}}([^}]*)$''')

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
    def __init__(self, filename):
        self.filename = filename
        self.document = [Entry(name='empty', data=[])]
        self.tjoff = {
            '!': self.make_header,
            '*': self.make_unordered,
            '#': self.make_ordered,
            '|': self.make_table,
        }
        self.header_level = 0
        self.unordered_level = 0
        self.ordered_level = 0
        self.inside_pre = False

    def make_ordered(self, b):
        if ordered.match(b):
            this_level = len(ordered.match(b).group(1))
            if self.ordered_level == 0 and this_level != 1:
                raise ValueError(
                    'Error! This ordered entry must start with «#», but '
                    'starts with {}\n. This is the erroneous entry '
                    '\n{}\nPlease fix this ' 'error'.format(ordered.match(b).group(1), b))
            elif self.ordered_level == 1 and this_level == 3:
                raise ValueError(
                    'Error! This entry starts with {}, but can only '
                    'start with «{}» or «{}». This is the erroneous '
                    'entry\n{}\nPlease fix this error'.format(
                        ordered.match(b).group(1), '#',
                        '#' * 2, b))
            else:
                self.ordered_level = this_level
                self.document.append(Entry(name='o{}'.format(this_level),
                                           data=[ordered.match(b).group(2)]))
        else:
            raise ValueError('Fake ordered entry! {}'.format(b))

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
        if unordered.match(b):
            this_level = len(unordered.match(b).group(1))
            if self.unordered_level == 0 and this_level != 1:
                raise ValueError(
                    'Error! This unordered entry must start with «#», but '
                    'starts with {}\n. This is the erroneous entry '
                    '\n{}\nPlease fix this ' 'error'.format(unordered.match(b).group(1), b))
            elif self.unordered_level == 1 and this_level == 3:
                raise ValueError(
                    'Error! This entry starts with {}, but can only '
                    'start with «{}» or «{}». This is the erroneous '
                    'entry\n{}\nPlease fix this error'.format(
                        unordered.match(b).group(1), '#',
                        '#' * 2, b))
            else:
                self.unordered_level = this_level
                self.document.append(Entry(name='u{}'.format(this_level),
                                           data=[unordered.match(b).group(2)]))
        else:
            raise ValueError('Fake unordered entry! {}'.format(b))

    def make_horisontal(self, b):
        #if len(b) == 4:
        self.document.append(Entry(name='hr', data=[]))
        #else:
            #raise ValueError(
                #'Please shorten the hr line to four hyphens.\n'
                #'This is the erroneous line:\n{}\n'.format(b))

    def make_table(self, b):
        if b.startswith('||'):
            self.document.append(Entry(name='th', data=[b]))
        elif b.startswith('|'):
            self.document.append(Entry(name='tr', data=[b]))

    def handle_line(self, b):
        if self.document[-1].name in ['empty', 'h1', 'h2', 'h3', 'th', 'tr']:
            self.document.append(Entry(name='p', data=[b]))
        else:
            self.document[-1].data.append(b)

    def make_inline_pre(self, b):
        m = complete_pre_inline.match(b)
        if m.group(1):
            self.handle_line(m.group(1))
        self.close_block()
        self.document.append(Entry(name='pre', data=[m.group(2)]))
        self.close_block()
        if m.group(3):
            self.handle_line(m.group(3))

    def start_inline(self, b):
        m = start_of_pre.match(b)
        if m.group(1):
            self.handle_line(m.group(1))
        self.close_block()
        self.document.append(Entry(name='pre', data=[m.group(2)]))

    def close_inline(self, b):
        m = end_of_pre.match(b)
        if m.group(1):
            self.handle_line(m.group(1))
        self.close_block()
        if m.group(2):
            self.handle_line(m.group(2))

    def close_block(self):
        self.document.append(Entry(name='empty', data=[]))

    def parse_block(self, block):
        for b in block:
            if horisontal.match(b):
                self.make_horisontal(b)
            elif complete_pre_inline.match(b):
                self.make_inline_pre(b)
            elif start_of_pre.match(b):
                if self.inside_pre:
                    raise ValueError(
                        'Error! Unbalanced pre\n'
                        'Found start of pre inside pre')
                else:
                    self.start_inline(b)
                    self.inside_pre = True
            elif end_of_pre.match(b):
                if not self.inside_pre:
                    raise ValueError(
                        'Error! Unbalanced pre\n'
                        'Found end of pre without start of pre')
                else:
                    self.close_inline(b)
                    self.inside_pre = False
            elif b[0] in self.tjoff.keys() and not self.inside_pre:
                self.tjoff[b[0]](b)
            else:
                self.handle_line(b)
        self.close_block()

    def parse_blocks(self):
        for block in self.make_blocks():
            self.parse_block(block)

        if self.inside_pre:
            raise ValueError(
                'Error! Unbalanced pre\n'
                'Reached end of document without finding closing }}}')

    def make_blocks(self):
        block = []
        blocks = []
        for line in fileinput.FileInput(self.filename):
            if line.strip():
                block.append(line.strip())
            else:
                if block:
                    blocks.append(block)
                block = []

        if block:
            blocks.append(block)

        return blocks


def main():
    for root, dirs, files in os.walk(sys.argv[1]):
        for f in files:
            if f.endswith('.jspwiki'):
                path = os.path.join(root, f)
                dm = DocMaker(path)
                try:
                    dm.parse_blocks()
                except ValueError as e:
                    print(path)
                    print(e)


    #for entry in dm.document:
        #if entry.name == 'empty':
            #print()
        #elif entry.name == 'hr':
            #print('<hr/>')
        #else:
            #print('<{tag}>{text}</{tag}>'.format(tag=entry.name,
                                                 #text='\n'.join(entry.data)))

if __name__ == '__main__':
    main()
    test_match()
