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

from nose_parameterized import parameterized
import unittest

from corpustools import util


headers = re.compile('''^\s*(!{1,3})\s*(.+)''')
ordered = re.compile('''^\s*(#{1,3})\s*(.+)''')
unordered = re.compile('''^\s*(\*{1,3})\s*(.+)''')
horisontal = re.compile('''^\s*(-{4,})$''')
complete_pre_inline = re.compile('''^(.*){{{(.+)}}}([^}]*)$''')
start_of_pre = re.compile('''^\s*(.*){{{([^}]*)$''')
end_of_pre = re.compile('''^\s*(.*)}}}([^}]*)$''')
erroneous_bold = re.compile(u'''[^_].* _([^_]+)_[^_]*$''')
possible_links = re.compile(u'''^([^[].*)(\[[^[]*\])([^]]*)$''')
possible_twolc_rule = re.compile(u'''(^[^[].+\[[^[]*\][^]]+;\s*.*)|([^(]+\([^(]+\|[^)]*\).+;.*)''')


Entry = collections.namedtuple('Entry', ['name', 'data'])


Line = collections.namedtuple('Line', ['number', 'content'])


class LineError(Exception):
    pass


def test_match():
    print('testing')
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
    assert erroneous_bold.match('assuming stem _kååʹmmerd_') is not None
    assert possible_links.match('a [b]') is not None
    assert possible_links.match('a [[b]') is not None
    m = possible_twolc_rule.match('''  Vow:i (%^1VOW:) (%{%ʹØ%}:ʹ) _ [[Cns:+ (%{XC%}:)|Cns:+ (ˈ:|:ˈ) Cns:+] BetweenStemAndHeight %^VOWRaise:  %^VYY2XYY: ;''')
    if m:
        util.print_frame('YEY1!')
    m = possible_twolc_rule.match('''Cns: (ˈ:|:ˈ) _ Vow: Cns:* PenBetweenStemAndVowelLoss (%^RmVow:) %^PALNo: (%^DeVC:) RBound ;''')
    if m:
        util.print_frame('YEY2!')
    m = possible_twolc_rule.match('''define uwChange [ u -> w || _ %> a ] ;''')
    if m:
        util.print_frame('YEY3!')
class OutlineError(Exception):
    pass


def make_misc_test():
    return [
        ('too long hr','-----'),
    ]


def make_link_tests():
    return [
        ('no link one part', 'abc [abc] abc'),
        ('no link two parts', 'abc [abc|abc] abc'),
        ('contains hex pattern', 'abc [^%Xabc] abc'),
    ]


def make_endswith(markups):
    return [('ends with {}'.format(name), 'abc{}'.format(chars[1]))
            for name, chars in markups.items()]


def make_single_starts(markups):
    return [('single {} start'.format(name), 'abc {}abc abc'.format(2 * chars[0]))
            for name, chars in markups.items()]


def make_single_ends(markups):
    return [('single {} end'.format(name), 'abc abc{} abc'.format(2 * chars[1]))
            for name, chars in markups.items()]


def make_markup_within_markup(markups):
    test_cases = []
    for name1, markups1 in markups.items():
        inner_markup = '{}{}{}'.format(markups1[0] * 2, name1, markups1[1] * 2)
        for name2, markups2 in markups.items():
            if name1 != name2:
                outer_markup = 'a {}{}{} b'.format(markups2[0] * 2,
                                                   inner_markup,
                                                   markups2[1] * 2)
                test_cases.append(
                    ('{} within {}'.format(name1, name2), outer_markup))

    return test_cases


def make_colliding_markup_within_markup(markups):
    test_cases = []
    for name1, markups1 in markups.items():
        inner_markup = 'half {}{}'.format(name1, markups1[1])
        for name2, markups2 in markups.items():
            if name1 != name2:
                outer_markup = 'a {}{}{} '.format(markups2[0] * 2,
                                                   inner_markup,
                                                   markups2[1] * 2)
                test_cases.append(
                    ('half {} within {}'.format(name1, name2), outer_markup))

    return test_cases


def make_inline_error_tests():
    test_cases = []
    markups = {
        'italic': ("'", "'"),
        'monospaced': ('{', '}'),
        'bold': ('_', '_'),
    }

    for name in [make_misc_test, make_link_tests]:
        test_cases.extend(name())

    for name in [make_single_ends, make_single_starts, make_endswith,
                 make_markup_within_markup,
                 make_colliding_markup_within_markup]:
        test_cases.extend(name(markups))

    return test_cases


class TestDocMaker(unittest.TestCase):
    def setUp(self):
        self.dm = DocMaker('bogus')

    @parameterized.expand(make_inline_error_tests())
    def test_inline_errors(self, name, content):
        with self.assertRaises(LineError):
            self.dm.parse_block(Line(number=1, content=content))


#def test_match():


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

    def error(self, error_message, block):
        raise LineError(
            '{} :#{b.number}:\n\t'
            '{e}\n\t'
            '{b.content}'.format(self.filename, b=block, e=error_message))

    def critical(self, error_message, block):
        raise OutlineError(
            '{} :#{b.number}:\n\t'
            '{e}\n\t'
            '{b.content}'.format(self.filename, b=block, e=error_message))

    def check_for_wrong_char(self, match, b):
        for possible_wrong_char in '!#*':
            if match.group(2).startswith(possible_wrong_char):
                self.error(
                    'Lines starting with «{}» can not have '
                    '«{}» as the first char.'.format(match.group(1),
                                                     possible_wrong_char),
                    b)

    def check_header_level(self, header_intro, this_level, b):
        if this_level < self.first_level:
            self.critical(
                'This header is {}\n'
                'Because the first header was «{}», only '
                'headers at this or lower levels are allowed.\n'
                'If you want to use this level, increase the level '
                'of the first header to at least this level'.format(
                    header_intro,
                    '!' * self.first_level),
                b
            )
        if self.header_level == 1 and this_level == 3:
            self.critical(
                'This header starts with {}, but can only '
                'start with «{}» or «{}».'.format(
                    header_intro, '!' * 3,
                    '!' * 2),
                b
            )

        self.header_level = this_level

    def make_header(self, b):
        #util.print_frame(b)
        m = headers.match(b.content)
        this_level = 4 - len(m.group(1))
        if self.first_level == 0:
            self.first_level = this_level

        self.check_for_wrong_char(m, b)
        self.check_outline_ending(m.group(2), b)
        self.check_inline(b)

        self.check_header_level(m.group(1), this_level, b)

        self.document.append(Entry(
            name='h{}'.format(this_level),
            data=[m.group(2)]))

    def check_unordered_level(self, unordered_intro, this_level, b):
        if self.unordered_level == 0 and this_level != 1:
            self.critical(
                'This unordered entry must start with «*», but '
                'starts with {}.'.format(unordered_intro),
                b
            )
        elif self.unordered_level == 1 and this_level == 3:
            self.critical(
                'This entry starts with {}, but can only '
                'start with «{}» or «{}».'.format(
                    unordered_intro, '*',
                    '*' * 2),
                b
            )
        self.unordered_level = this_level

    def check_outline_ending(self, outline_content, b):
        if not outline_content.strip():
            self.error('Empty list entries are not allowed.', b)

    def make_unordered(self, b):
        m = unordered.match(b.content)
        this_level = len(m.group(1))

        self.check_for_wrong_char(m, b)
        self.check_outline_ending(m.group(2), b)
        self.check_inline(b)

        self.check_unordered_level(m.group(1), this_level, b)

        self.document.append(Entry(
            name='u{}'.format(this_level),
            data=[m.group(2)]))

    def check_ordered_level(self, ordered_intro, this_level, b):
        if self.ordered_level == 0 and this_level != 1:
            self.critical(
                'This unordered entry must start with «#», but '
                'starts with {}.'.format(ordered_intro),
                b
            )
        elif self.ordered_level == 1 and this_level == 3:
            self.critical(
                'This entry starts with {}, but can only '
                'start with «{}» or «{}».'.format(
                    ordered_intro, '#',
                    '#' * 2),
                b
            )
        self.ordered_level = this_level

    def make_ordered(self, b):
        m = ordered.match(b.content)
        this_level = len(m.group(1))

        self.check_for_wrong_char(m, b)
        self.check_outline_ending(m.group(2), b)
        self.check_inline(b)

        self.check_ordered_level(m.group(1), this_level, b)

        self.document.append(Entry(
            name='o{}'.format(this_level),
            data=[m.group(2)]))

    def make_horisontal(self, b):
        if not self.inside_pre:
            if len(b.content.strip()) == 4:
                self.document.append(Entry(name='hr', data=[]))
            else:
                self.error(
                    'Please shorten the hr line to four hyphens.',
                    b)

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
            if not self.inside_pre:
                self.check_inline(Line(b.number, m.group(1)))
            self.handle_line(m.group(1))
        self.close_block()
        self.document.append(Entry(name='pre', data=[m.group(2)]))
        self.close_block()
        if m.group(3):
            if not self.inside_pre:
                self.check_inline(Line(b.number, m.group(3)))
            self.handle_line(m.group(3))

    def start_pre(self, b):
        m = start_of_pre.match(b.content)
        if m.group(1):
            if not self.inside_pre:
                self.check_inline(Line(b.number, m.group(1)))
            self.handle_line(m.group(1))
        self.close_block()
        self.document.append(Entry(name='pre', data=[m.group(2)]))

    def close_inline(self, b):
        m = end_of_pre.match(b.content)
        if m.group(1):
            self.handle_line(m.group(1))
        self.close_block()
        if m.group(2):
            if not self.inside_pre:
                self.check_inline(Line(b.number, m.group(2)))
            self.handle_line(m.group(2))

    def close_block(self):
        if self.document[-1].name != 'empty':
            self.document.append(Entry(name='empty', data=[]))

    def check_wrong_endchar(self, b):
        markup = {
            "'": 'italic',
            '}': 'monospaced',
            '_': 'bold',
        }

        if not b.content[:-1].endswith('{}'):
            for wrong_endchar1 in markup.keys():
                regex = '''^.+[^{wc}]{wc}$'''.format(wc=wrong_endchar1)
                if re.match(regex, b.content):
                    self.error(
                        'Line ends with {wc}.\n\t'
                        'Either add a space character at the line ending, '
                        'mark it up as {name} (two {wc}\'s at each side) or '
                        'place the entire line inside a pre '
                        'block.'.format(name=markup[wrong_endchar1],
                                        wc=wrong_endchar1),
                        b)

                for wrong_endchar2 in markup.keys():
                    if wrong_endchar1 != wrong_endchar2:
                        exp = '''{first}{second}{second}'''.format(
                            first=wrong_endchar1, second=wrong_endchar2)
                        if exp in b.content:
                            self.error(
                                'Erroneous {wc} markup.\n\t'
                                'Either add a space character between «{first}» '
                                'and «{second}» or place the entire line inside '
                                'a pre block.'.format(
                                    wc=markup[wrong_endchar2],
                                    first=wrong_endchar1,
                                    second=wrong_endchar2),
                                b)

    def check_unbalanced_markup(self, b):
        markups = {
            'italic': ("'", "'"),
            'monospaced': ('{', '}'),
            'bold': ('_', '_'),
        }
        for name, markup in markups.items():
            start = b.content.find(''.join(2 * markup[0]))
            end = b.content.rfind(''.join(2 * markup[1]))

            #if start > -1 or end > -1:
                #print(start, end, b)
            if (start > 0 and end == -1) or \
                (start == -1 and end > 0 ) or \
                    (start > -1 and end > -1 and start == end):
                self.error(
                    'Line contains a single {name} markup.\n\t'
                    'Either remove the single {name} markup or remove the '
                    'newline in the {name} markup.'.format(name=name),
                    b)

    def check_markup_within_markup(self, b):
        markups = {
            'italic': ("'", "'"),
            'monospaced': ('{', '}'),
            'bold': ('_', '_'),
        }

        for name1, markup1 in markups.items():
            re_text1 = '''.*{first}{first}([^{second}]+){second}{second}.*'''.format(first=markup1[0], second=markup1[1])
            markup1_re = re.compile(re_text1)
            m = markup1_re.search(b.content)

            if m:
                for group in m.groups():
                    for name2, markup2 in markups.items():
                        if name1 != name2:
                            re_text2 = '''.*{first}{first}([^{second}]+){second}{second}.*'''.format(first=markup2[0], second=markup2[1])
                            markup2_re = re.compile(re_text2)
                            m = markup2_re.search(group)
                            if m:
                                for group2 in m.groups():
                                    self.error(
                                        'Line contains {name2} '
                                        'within {name1}.\n\t'
                                        'Remove one of the markups.'.format(
                                            name1=name1, name2=name2),
                                        b)

    def check_inline(self, b):
        if not self.inside_pre:
            m = possible_twolc_rule.match(b.content)
            if m:
                self.error(
                    'Possible twolc rule.\n\t'
                    'Please either remove it from the documentation or '
                    'place it in a pre-block.',
                    b)

            elif possible_links.match(b.content):
                m = possible_links.match(b.content)
                if not m.group(1).endswith('['):
                    self.handle_link_content(m, b)

            self.check_wrong_endchar(b)
            self.check_unbalanced_markup(b)
            self.check_markup_within_markup(b)

    def handle_link_content(self, link_match, block):
        parts = link_match.group(2).split('|')
        #if len(parts) > 2:
            #self.error(
                #':#{}:\n\tLink content has to many parts.\n\t'
                #'If this is a link, fix the content. If it is not a '
                #'link prepend {} with «[»: {}'.format(block.number,
                                                      #link_match.group(2),
                                                      #block.content))
        #el
        if len(parts) == 2:
            #if not parts[1][1:-1].strip():
                #self.error(
                    #':#{}:\n\tLink content «{}» is empty.\n\t'
                    #'If this is a link, fix the content. If it is not a '
                    #'link prepend «{}» with «[»: {}'.format(block.number,
                                                            #parts[0][:-1],
                                                            #link_match.group(2),
                                                            #block.content))
            #elif re.match('^\d+$', parts[1][1:-1].strip()):
                #self.error(
                    #':#{}:\n\tLink content «{}» contains only numbers.\n\t'
                    #'If this is a link, fix the content. If it is not a '
                    #'link prepend «{}» with «[»: {}'.format(block.number,
                                                            #parts[1][:-1],
                                                            #link_match.group(2),
                                                            #block.content))
            #el
            if '%^' in parts[1]:
                self.error(
                    'Link content «{}» contains a '
                    'URI-hex pattern.\n\t'
                    'If this is a link, fix the content. If it is not a '
                    'link prepend «{}» with «[».'.format(parts[1][:-1],
                                                         link_match.group(2)),
                    block)
            elif not self.is_correct_link(parts[1][:-1].strip()) and  'langs/' not in os.path.abspath(self.filename):
                self.error(
                    'Link content «{}» does not point to a valid document.\n\t'
                    'If this is a link, fix the content. If it is not a '
                    'link prepend «{}» with «[».'.format(parts[1][:-1],
                                                         link_match.group(2)),
                    block)
        elif len(parts) == 1:
            #if not parts[0][1:-1].strip():
                #self.error(
                    #':#{}:\n\tLink content «{}» is empty.\n\t'
                    #'If this is a link, fix the content. If it is not a '
                    #'link prepend «{}» with «[»: {}'.format(block.number,
                                                            #parts[0][:-1],
                                                            #link_match.group(2),
                                                            #block.content))
            #elif re.match('^\d+$', parts[0][1:-1].strip()):
                #self.error(
                    #':#{}:\n\tLink content «{}» contains only numbers.\n\t'
                    #'If this is a link, fix the content. If it is not a '
                    #'link prepend «{}» with «[»: {}'.format(block.number,
                                                            #parts[0][:-1],
                                                            #link_match.group(2),
                                                            #block.content))
            #el
            if '%^' in parts[0]:
                self.error(
                    'Link content «{}» contains a '
                    'URI-hex pattern.\n\t'
                    'If this is a link, fix the content. If it is not a '
                    'link prepend «{}» with «[».'.format(parts[0][:-1],
                                                        link_match.group(2)),
                    block)
            elif not self.is_correct_link(parts[0][1:-1].strip()) and  'langs/' not in os.path.abspath(self.filename):
                self.error(
                    'Link content «{}» does not point to a '
                    'valid document.\n\t'
                    'If this is a link, fix the content. If it is not a '
                    'link prepend «{}» with «[».'.format(parts[0][:-1],
                                                         link_match.group(2)),
                    block)

    def is_correct_link(self, link_content):
        return (
            link_content.startswith('http://') or
            link_content.startswith('https://') or
            link_content.startswith('mailto:') or
            link_content.startswith('news:') or
            self.jspwiki_file_exists(link_content) or
            self.lexc_file_exists(link_content)
        )

    def jspwiki_file_exists(self, link_content):
        basename = os.path.dirname(os.path.abspath(self.filename))
        normpath = os.path.normpath(os.path.join(basename, link_content))
        jspwiki = normpath.replace('.html', '.jspwiki')
        added_jspwiki = normpath + '.jspwiki'
        xml = normpath.replace('.html', '.xml')

        return (
            self.filename.endswith('.jspwiki') and (
                os.path.exists(normpath) or
                os.path.exists(jspwiki) or
                os.path.exists(added_jspwiki) or
                os.path.exists(xml)
            )
        )

    def lexc_file_exists(self, link_content):
        return (
            self.filename.endswith('.lexc') and (
                os.path.exists(
                    os.path.join(
                        self.filename[:self.filename.find('langs/') + len('langs/') + 4],
                        'doc', link_content.replace('.html', '.jspwiki')
                    )
                )
            )
        )

    def parse_blocks(self):
        get_blocks = {
            '.jspwiki': self.jspwiki_blocks,
            '.lexc': self.lexc_blocks,
            '.twolc': self.lexc_blocks,
            '.xfscript': self.lexc_blocks,
        }

        get_blocks[os.path.splitext(self.filename)[1]]()

        if self.inside_pre:
            raise ValueError(
                'Error! Unbalanced pre\n'
                'Reached end of document without finding closing }}}\n')

    def parse_block(self, b):
        if horisontal.match(b.content) and not self.inside_pre:
            self.check_inline(b)
            self.make_horisontal(b)
        elif complete_pre_inline.match(b.content) and not self.inside_pre:
            self.make_inline_pre(b)
        elif start_of_pre.match(b.content):
            if self.inside_pre:
                raise ValueError(
                    'Error!Unbalanced pre\n'
                    'Found start of pre inside pre\n'
                    'Erroneous line is {}\n'.format(b))
            else:
                self.start_pre(b)
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
        elif re.match('''\s*([{}])'''.format(''.join(self.tjoff.keys())), b.content) and not self.inside_pre:
            self.check_inline(b)
            key = re.match('''\s*([{}])'''.format(''.join(self.tjoff.keys())), b.content).group(1)
            self.tjoff[key](b)
        elif not self.inside_pre:
            self.check_inline(b)
            self.handle_line(b.content)

    def jspwiki_blocks(self):
        for x, line in enumerate(fileinput.FileInput(self.filename)):
            if line.strip():
                try:
                    self.parse_block(Line(number=x + 1, content=line))
                except LineError as e:
                    print(e, file=sys.stderr)
            else:
                self.close_block()

    def lexc_blocks(self):
        rulename_re = re.compile('''^"([^"]+)"''')
        rulename = ''

        for x, line in enumerate(fileinput.FileInput(self.filename)):
            try:
                if rulename_re.match(line):
                    rulename = rulename_re.match(line).group(1)

                if re.match('^[^!]+!! ', line):
                    lexc_doc = re.compile('.*!! (.+)')
                    m = lexc_doc.match(line)
                    if m:
                        if '@RULENAME@' in m.group(1):
                            if not rulename:
                                raise ValueError(
                                    'rulename is empty!: {}'.format(x + 1, line))

                            parts = m.group(1).split('@RULENAME@')
                            if (rulename.endswith('-') and parts[1].startswith('__') ):
                                self.error(
                                    '@RULENAME@ is surrounded with «_» and the string that '
                                    'will replace it ({}) ends with «-».\n\t'
                                    'Either remove «_» from @RULENAME@ or insert a space '
                                    'between @RULENAME@ and _: {}'.format(rulename),
                                    Line(number=x + 1, content=line))
                            else:
                                self.parse_block(Line(number=x + 1,
                                                content=m.group(1).replace(
                                                    '@RULENAME@', rulename)))
                        else:
                            self.parse_block(Line(number=x + 1,
                                            content=m.group(1)))
                elif line.startswith('!!€ '):
                    parts = line[len('!!€ '):].split()
                    c = ['*']
                    if parts:
                        c.append('__%s __' % parts[0])
                        if len(parts) > 1:
                            c.append('{{%s}}' % parts[1])
                        if len(parts) > 2:
                            c.append('(Eng.')
                            c.extend(parts[2:])
                    else:
                        c.append('???')
                    c.append(' ')
                    self.parse_block(Line(number=x + 1, content=' '.join(c)))

                elif line.startswith('!!€'):
                    a = re.compile('(!!€.+:\s+)(.+)')
                    m = a.match(line)
                    if m:
                        self.parse_block(Line(number=x + 1,
                                        content='__{} examples:__'.format(
                                            m.group(1))))
                elif re.match('^[^!]+!![=≈]', line):

                    def check_validity(lineno, origline, line, code):
                        parts = line.split('@CODE@')
                        if parts[1].startswith('__') and (code.endswith('}') or code.endswith('-')):
                            self.error(
                                '@CODE@ is surrounded with «_» and the string '
                                'that will replace it ends with «}».\n\t'
                                'Either remove «_» from @CODE@ or insert a space between '
                                '@CODE@ and _.',
                                Line(number=lineno, content=origline))
                        if re.match('^\s*!', code) and re.match('^\s*\*\s+$', parts[0]):
                            self.error(
                                '@CODE@ contains «!».\n\t'
                                'Either remove «!» or @CODE@.',
                                Line(number=lineno, content=origline))
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

                    self.parse_block(Line(number=x + 1, content=c))

                else:
                    self.close_block()
            except LineError as e:
                print(e, file=sys.stderr)


def handle_file(path):

    dm = DocMaker(path)
    #if path.endswith('.lexc') or path.endswith('.xfscript') or path.endswith('.twolc'):
        #dm.first_level = 1
    if not ('errors/' in path or
            'generated_files' in path or
            'lexicon.' in path or
            '/kal/' in path):
        try:
            dm.parse_blocks()
        except ValueError as e:
            util.print_frame(path)
            util.print_frame(str(e))

def main():
    x = 1

    for uff in sys.argv[1:]:
        if os.path.isfile(uff):
            if uff.endswith('.lexc') or uff.endswith('.twolc') or uff.endswith('.xfscript') or uff.endswith('.jspwiki'):
                handle_file(uff)
        elif os.path.exists(uff):
            for root, dirs, files in os.walk(uff, followlinks=True):
                if 'doc/lang' not in root:
                    for f in files:
                        if f.endswith('.lexc') or f.endswith('.twolc') or f.endswith('.twolc') or f.endswith('.jspwiki'):
                            handle_file(os.path.join(root, f))
        else:
            print(uff, 'does not exist', file=sys.stderr)


if __name__ == '__main__':
    main()
    #test_match()
