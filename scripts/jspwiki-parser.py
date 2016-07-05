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

from corpustools import util


headers = re.compile('''^\s*(!{1,3})\s*([^!]+)''')
ordered = re.compile('''^\s*(#{1,3})\s*([^#]+)''')
unordered = re.compile('''^\s*(\*{1,3})\s*([^*]+)''')
horisontal = re.compile('''^\s*(-{4,})$''')
complete_pre_inline = re.compile('''^(.*){{{(.+)}}}([^}]*)$''')
start_of_pre = re.compile('''^\s*(.*){{{([^}]*)$''')
end_of_pre = re.compile('''^\s*(.*)}}}([^}]*)$''')
erroneous_bold = re.compile(u'''[^_].* _([^_]+)_[^_]*$''')


Entry = collections.namedtuple('Entry', ['name', 'data'])


Line = collections.namedtuple('Line', ['number', 'content'])


def test_match():
    for c in [(headers, '!'), (ordered, '#'), (unordered, '*')]:
        if not c[0].match('  {} '.format(c[1])):
            print('{} did not pass'.format(c[1]))
        if not c[0].match('  {} '.format(c[1] * 2)):
            print('{} did not pass'.format(c[1] * 2))
        if not c[0].match('  {} '.format(c[1] * 3)):
            print('{} did not pass'.format(c[1] * 3))
        if c[0].match('  {} '.format(c[1] * 4)):
            print('{} did not pass'.format(c[1] * 4))
    assert horisontal.match(' a') is None
    assert horisontal.match(' ---') is None
    assert horisontal.match(' ----') is not None
    assert horisontal.match(' -----') is not None
    assert horisontal.match(' -------a;dskjfaf') is None
    m = erroneous_bold.match('assuming stem _kååʹmmerd_')
    if m:
        util.print_frame('hurra!')
    else:
        util.print_frame('å nei!!!!')

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
        self.first_level = 0
        self.header_level = 0
        self.unordered_level = 0
        self.ordered_level = 0
        self.inside_pre = False

    def make_ordered(self, b):
        ordered_endings = re.compile('''\s*\#+\s*$''')
        if ordered_endings.match(b.content):
            raise ValueError(
                'Error!\n'
                'Empty list entries are not allowed.'
                'Erroneous line is {}\n'.format(b))

        if ordered.match(b.content):
            this_level = len(ordered.match(b.content).group(1))
            if self.ordered_level == 0 and this_level != 1:
                raise ValueError(
                    'Error! This ordered entry must start with «#», but '
                    'starts with {}\n. This is the erroneous entry '
                    '\n{}\n'.format(ordered.match(b.content).group(1), b))
            elif self.ordered_level == 1 and this_level == 3:
                raise ValueError(
                    'Error! This entry starts with {}, but can only '
                    'start with «{}» or «{}». This is the erroneous '
                    'entry\n{}\n'.format(
                        ordered.match(b.content).group(1), '#',
                        '#' * 2, b))
            else:
                self.ordered_level = this_level
                self.document.append(Entry(
                    name='o{}'.format(this_level),
                    data=[ordered.match(b.content).group(2)]))
        else:
            raise ValueError('Error!\nFake ordered entry! {}'.format(b))

    def make_header(self, b):
        if headers.match(b.content):
            this_level = 4 - len(headers.match(b.content).group(1))
            if self.first_level == 0:
                self.first_level = this_level

            if this_level < self.first_level:
                raise ValueError(
                    'Error!\n'
                    'This header is {}\n'
                    'Because the first header was «{}», only '
                    'headers at this or lower levels are allowed.\n'
                    'If you want to use this level, increase the level '
                    'of the first header to at least this level.\n'
                    'Erroneous line is {}\n'.format(
                        headers.match(b.content).group(1),
                        '!' * self.first_level,
                        b))
            if self.header_level == 1 and this_level == 3:
                raise ValueError(
                    'Error!\nThis header starts with {}, but can only '
                    'start with «{}» or «{}». This is the erroneous '
                    'header\n{}\n'.format(
                        headers.match(b.content).group(1), '!' * 3,
                        '!' * 2, b))
            else:
                self.header_level = this_level
                self.document.append(Entry(
                    name='h{}'.format(this_level),
                    data=[headers.match(b.content).group(2)]))
        else:
            raise ValueError('Error!\nFake header! {}\n'.format(b))

    def make_unordered(self, b):
        unordered_endings = re.compile('''\s*\*+\s*$''')
        if unordered_endings.match(b.content):
            raise ValueError(
                'Error!\n'
                'Empty list entries are not allowed.'
                'Erroneous line is {}\n'.format(b))

        if unordered.match(b.content):
            this_level = len(unordered.match(b.content).group(1))
            if self.unordered_level == 0 and this_level != 1:
                raise ValueError(
                    'Error! This unordered entry must start with «*», but '
                    'starts with {}\n. This is the erroneous entry '
                    '\n{}\n'.format(unordered.match(b.content).group(1), b))
            elif self.unordered_level == 1 and this_level == 3:
                raise ValueError(
                    'Error! This entry starts with {}, but can only '
                    'start with «{}» or «{}». This is the erroneous '
                    'entry\n{}\n'.format(
                        unordered.match(b.content).group(1), '*',
                        '*' * 2, b))
            else:
                self.unordered_level = this_level
                self.document.append(Entry(
                    name='u{}'.format(this_level),
                    data=[unordered.match(b.content).group(2)]))
        else:
            raise ValueError('Error!\nFake unordered entry! {}'.format(b))

    def make_horisontal(self, b):
        if not self.inside_pre:
            if len(b.content.strip()) == 4:
                self.document.append(Entry(name='hr', data=[]))
            else:
                raise ValueError(
                    'Please shorten the hr line to four hyphens.\n'
                    'This is the erroneous line:\n{}\n'.format(b))

    def make_table(self, b):
        links_removed = '='.join(re.split('\[.+\]', b.content))
        only_space = re.compile('''^[ \t]+$''')

        table_endings = re.compile('''.+\|$''')

        if table_endings.match(links_removed):
            raise ValueError(
                'Error!\nTables can not end with | chars\n'
                'Erroneous line is {}\n'.format(b))
        elif b.content.startswith('||'):
            parts = links_removed.split('||')
            for part in parts:
                if '|' in part:
                    raise ValueError(
                        'Error!\n'
                        'Table headers entries must be divided by '
                        '«||», not «|»\n'
                        'Erroneous line is {}\n'.format(b))
                elif only_space.match(part):
                    raise ValueError(
                        'Error!\n'
                        'Table entries contain only space or tabs.\n'
                        'Table entries must contain some other chars.\n'
                        'Erroneous line is {}\n'.format(b))
            self.document.append(Entry(name='th', data=[b.content]))
        elif b.content.startswith('|'):
            if re.search('^\|.+\|[^\s]', links_removed):
                raise ValueError(
                    'Error!\n'
                    'Table entries must start with a space character.\n'
                    'Erroneous line is {}\n'.format(b))
            parts = links_removed.split('|')
            for part in parts:
                if only_space.match(part):
                    raise ValueError(
                        'Error!\n'
                        'Table entries contain only space or tabs.\n'
                        'Table entries must contain some other chars.\n'
                        'Erroneous line is {}\n'.format(b))
            self.document.append(Entry(name='tr', data=[b.content]))

    def handle_line(self, b):
        if self.document[-1].name in ['empty', 'h1', 'h2', 'h3', 'th', 'tr']:
            self.document.append(Entry(name='p', data=[b]))
        else:
            self.document[-1].data.append(b)

    def make_inline_pre(self, b):
        m = complete_pre_inline.match(b.content)
        if m.group(1):
            self.handle_line(m.group(1))
        self.close_block()
        self.document.append(Entry(name='pre', data=[m.group(2)]))
        self.close_block()
        if m.group(3):
            self.handle_line(m.group(3))

    def start_inline(self, b):
        m = start_of_pre.match(b.content)
        if m.group(1):
            self.handle_line(m.group(1))
        self.close_block()
        self.document.append(Entry(name='pre', data=[m.group(2)]))

    def close_inline(self, b):
        m = end_of_pre.match(b.content)
        if m.group(1):
            self.handle_line(m.group(1))
        self.close_block()
        if m.group(2):
            self.handle_line(m.group(2))

    def close_block(self):
        self.document.append(Entry(name='empty', data=[]))

    def parse_block(self, block):
        for b in block:
            if horisontal.match(b.content):
                self.make_horisontal(b)
            elif complete_pre_inline.match(b.content):
                self.make_inline_pre(b)
            elif start_of_pre.match(b.content):
                if self.inside_pre:
                    raise ValueError(
                        'Error!Unbalanced pre\n'
                        'Found start of pre inside pre\n'
                        'Erroneous line is {}\n'.format(b))
                else:
                    self.start_inline(b)
                    self.inside_pre = True
            elif end_of_pre.match(b.content):
                if not self.inside_pre:
                    raise ValueError(
                        'Error! Unbalanced pre\n'
                        'Found end of pre without start of pre\n'
                        'Erroneous line is {}\n'.format(b))
                else:
                    self.close_inline(b)
                    self.inside_pre = False
            elif b.content[0] in self.tjoff.keys() and not self.inside_pre:
                self.tjoff[b.content[0]](b)
            elif erroneous_bold.match(b.content):
                m = erroneous_bold.match(b.content)
                raise ValueError(
                    'Error!\n'
                    'Erroneous bold markup\n'
                    'Either remove «_» chars around {} or add another '
                    '«_» on either side\n'
                    'Erroneous line is {}\n'.format(m.group(1), b))
            else:
                self.handle_line(b.content)
        self.close_block()

    def parse_blocks(self):
        get_blocks = {
            '.jspwiki': self.jspwiki_blocks,
            '.lexc': self.lexc_blocks,
        }

        for block in get_blocks[os.path.splitext(self.filename)[1]]():
            self.parse_block(block)

        if self.inside_pre:
            raise ValueError(
                'Error! Unbalanced pre\n'
                'Reached end of document without finding closing }}}\n')

    def jspwiki_blocks(self):
        block = []
        blocks = []
        for x, line in enumerate(fileinput.FileInput(self.filename)):
            if line.strip():
                block.append(Line(number=x + 1, content=line))
            else:
                if block:
                    blocks.append(block)
                block = []

        if block:
            blocks.append(block)

        return blocks

    def lexc_blocks(self):
        block = []
        blocks = []

        for x, line in enumerate(fileinput.FileInput(self.filename)):
            if '!! ' in line:
                lexc_doc = re.compile('.*!! (.+)')
                m = lexc_doc.match(line)
                if m:
                    block.append(Line(number=x + 1,
                                      content=m.group(1)))
            elif line.startswith('!!€ '):
                parts = line[len('!!€ '):].split()
                c = ['*']
                if parts:
                    c.append('__%s__' % parts[0])
                    if len(parts) > 1:
                        c.append('{{%s}}' % parts[1])
                    if len(parts) > 2:
                        c.append('(Eng.')
                        c.extend(parts[2:])
                else:
                    c.append('???')

                block.append(Line(number=x + 1, content=' '.join(c)))

            elif line.startswith('!!€'):
                a = re.compile('(!!€.+:\s+)(.+)')
                m = a.match(line)
                if m:
                    block.append(Line(number=x + 1,
                                      content='__{} examples:__'.format(
                                          m.group(1))))
            elif re.match('.+!![=≈]', line):

                def check_validity(lineno, origline, line, code):
                    parts = line.split('@CODE@')
                    if parts[1].startswith('__') and code.endswith('}'):
                        raise ValueError(
                            'Error!\n'
                            '@CODE@ is surrounded with «__» and the string that '
                            'will replace it ends with «}». Either remove «__» '
                            'from @CODE@ or insert a space between @CODE@ '
                            'and __.\n'
                            'Erroneous line is %s %s' % (lineno, origline))

                def get_replacement(s1, s2):
                    return s1 if s2 == '!!=' else s1.strip()

                m = re.match('(.+)(!![=≈])(.*)', line)

                if '@CODE@' in m.group(3):
                    replacement = get_replacement(m.group(1), m.group(2))
                    check_validity(x + 1, line, m.group(3), replacement)
                    c = m.group(3).replace('@CODE@', m.group(1))
                    if m.group(2) == '!!≈':
                        c = re.sub(' +', ' ', c)
                else:
                    c = line.replace(m.group(2), '')

                block.append(Line(number=x + 1, content=c))
                
                if block[-1].content.endswith('}'):
                    error_line = (
                        'Error!\n'
                        'Line endswith «}». To fix this, add at least a '
                        'space at the end of the line.\n'
                        'Erroneous line is %s %s')
                    raise ValueError(error_line % (x + 1, line))

            else:
                if block:
                    for b in block:
                        print(b.content)
                    print()
                    blocks.append(block)
                block = []

        if block:
            for b in block:
                print(b.content)
            print()
            blocks.append(block)

        return blocks


def handle_file(path):

    if path.endswith('.lexc') or path.endswith('.jspwiki'):
        dm = DocMaker(path)
        if path.endswith('.lexc'):
            dm.first_level = 1
        if not ('errors/' in path or
                'generated_files' in path or
                'lexicon.' in path or
                '/kal/' in path):
            try:
                dm.parse_blocks()
            except ValueError as e:
                    try:
                        os.symlink(path, os.path.join(
                            '/home/boerre/repos/langtech/xtdoc/gtuit/src/'
                            'documentation/content/xdocs/errors',
                            os.path.basename(path)))
                    except OSError:
                        pass
                    util.print_frame(path)
                    if path.endswith('.jspwiki'):
                        print('http://localhost:8888/errors/{}'.format(
                            os.path.basename(path.replace('.jspwiki',
                                                        '.html'))))
                    util.print_frame(str(e))

def main():
    x = 1
    uff = sys.argv[1]

    if os.path.isfile(uff):
        if uff.endswith('.lexc'): # or f.endswith('.jspwiki'):
            handle_file(uff)
    else:
        for root, dirs, files in os.walk(uff):
            for f in files:
                if f.endswith('.lexc'): # or f.endswith('.jspwiki'):
                    handle_file(os.path.join(root, f))



if __name__ == '__main__':
    main()
    #test_match()
