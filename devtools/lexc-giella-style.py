#!/usr/bin/env python
# -*- coding: utf-8 -*-

#
#   This program is free software: you can redistribute it and/or modify
#   it under the terms of the GNU General Public License as published by
#   the Free Software Foundation, either version 3 of the License, or
#   (at your option) any later version.
#
#   This program is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU General Public License for more details.
#
#   You should have received a copy of the GNU General Public License
#   along with this file. If not, see <http://www.gnu.org/licenses/>.
#
#   Copyright © 2016 The University of Tromsø & the Norwegian Sámi Parliament
#   http://giellatekno.uit.no & http://divvun.no
#


from __future__ import absolute_import, print_function
import codecs
import unittest
import sys
from collections import defaultdict
from io import open

class TestLines(unittest.TestCase):

    def test_longest(self):
        input = u''' +N+Sg:             N_ODD_SG       ;
 +N+Pl:             N_ODD_PL       ;
 +N:             N_ODD_ESS      ;
 +N+SgNomCmp:e%^DISIMP    R              ;
 +N+SgGenCmp:e%>%^DISIMPn R              ;
 +N+PlGenCmp:%>%^DISIMPi  R              ;
 +N+Der1+Der/Dimin+N:%»adtj       GIERIEHTSADTJE ;
   +A:%>X7 NomVadj "good A" ;
'''

        l = Lines()
        l.parse_lines(input.split(u'\n'))

        longest = {}
        longest[u'comment'] = 0
        longest[u'upper'] = 19
        longest[u'lower'] = 12
        longest[u'contlex'] = 14
        longest[u'translation'] = 8

        self.assertEqual(longest, l.longest)

    def test_output_with_empty_upper_lower(self):
        input = [u' FINAL1         ;\n',
           u' +N+Sg:             N_ODD_SG       ;\n']
        expected_result = [u'        FINAL1   ;\n',
                    u' +N+Sg: N_ODD_SG ;\n']

        l = Lines()
        l.parse_lines(input)

        self.assertEqual(expected_result, l.adjust_lines())

    def test_output_with_lexicon_and_semicolon(self):
        input = [u'LEXICON GOAHTI-NE  !!= * __@CODE@__ Bisyll. V-Nouns; Nominative Sg. and Essive\n',
            u' NomV ;\n',
            u' EssV ;\n']

        expected_result = [u'LEXICON GOAHTI-NE  !!= * __@CODE@__ Bisyll. V-Nouns; Nominative Sg. and Essive\n',
            u'   NomV ;\n',
            u'   EssV ;\n']

        l = Lines()
        l.parse_lines(input)
        self.assertEqual(expected_result, l.adjust_lines())

    def test_output_with_lines_starting_with_chars(self):
        input = u'''LEXICON Conjunction

!dovne Cc ; ! dovne A jïh B , cf. "Det er sikkert A og B", dovne=Adv.
jïh Cc ;
jah Cc ;
'''.split(u'\n')
        expected_result = u'''LEXICON Conjunction

!dovne Cc ; ! dovne A jïh B , cf. "Det er sikkert A og B", dovne=Adv.
jïh Cc ;
jah Cc ;
'''.split('\n')
        l = Lines()
        l.parse_lines(input)
        self.assertEqual(expected_result, l.adjust_lines())

    def test_output_with_lines_with_leading_non_w(self):
        input = u'''LEXICON Cc
+CC:0 # ;
'''.split(u'\n')
        expected_result = u'''LEXICON Cc
+CC:0 # ;
'''.split(u'\n')
        l = Lines()
        l.parse_lines(input)
        self.assertEqual(expected_result, l.adjust_lines())

    def test_output_with_lines_with_leading_non_w(self):
        input = u'''LEXICON Cc
+CC:0 # ;
'''.split(u'\n')
        expected_result = u'''LEXICON Cc
+CC:0 # ;
'''.split(u'\n')
        l = Lines()
        l.parse_lines(input)
        self.assertEqual(expected_result, l.adjust_lines())

    def test_output(self):
        input = [u'LEXICON DAKTERE\n',
           u' +N+Sg:             N_ODD_SG       ;\n',
           u' +N+Pl:             N_ODD_PL       ;\n',
           u' +N:             N_ODD_ESS      ;\n',
           u' +N+SgNomCmp:e%^DISIMP    R              ;\n',
           u' +N+SgGenCmp:e%>%^DISIMPn R              ;\n',
           u' +N+PlGenCmp:%>%^DISIMPi  R              ;\n',
           u' +N+Der1+Der/Dimin+N:%»adtj       GIERIEHTSADTJE ;\n',
           u' +A+Comp+Attr:%>abpa      ATTRCONT    ;  ! båajasabpa,   *båajoesabpa\n',
           u'   +A:%>X7 NomVadj "good A" ;',
           u'  ! Test data:\n',
           u'!!€gt-norm: daktere # Odd-syllable test\n']
        l = Lines()
        l.parse_lines(input)

        expected_result = [u'LEXICON DAKTERE\n',
                    u'               +N+Sg:             N_ODD_SG                ;\n',
                    u'               +N+Pl:             N_ODD_PL                ;\n',
                    u'                  +N:             N_ODD_ESS               ;\n',
                    u'         +N+SgNomCmp:e%^DISIMP    R                       ;\n',
                    u'         +N+SgGenCmp:e%>%^DISIMPn R                       ;\n',
                    u'         +N+PlGenCmp:%>%^DISIMPi  R                       ;\n',
                    u' +N+Der1+Der/Dimin+N:%»adtj       GIERIEHTSADTJE          ;\n',
                    u'        +A+Comp+Attr:%>abpa       ATTRCONT                ; ! båajasabpa,   *båajoesabpa\n',
                    u'                  +A:%>X7         NomVadj        "good A" ;\n',
                    u'! Test data:\n',
                    u'!!€gt-norm: daktere # Odd-syllable test\n']
        self.maxDiff = None

        self.assertEqual(expected_result, l.adjust_lines())

class TestLine(unittest.TestCase):

    def test_line_parser_upper_lower(self):
        input = u'''        +N+SgNomCmp:e%^DISIMP    R              ;'''
        expected_result = {u'upper': u'+N+SgNomCmp', u'lower': u'e%^DISIMP', u'contlex': u'R', u'comment': u''}

        self.assertEqual(parse_line(input), expected_result)

    def test_line_parser_no_lower(self):
        input = u'''               +N+Sg:             N_ODD_SG       ;'''
        expected_result = {u'upper': u'+N+Sg', u'lower': u'', u'contlex': u'N_ODD_SG', u'comment': u''}

        self.assertEqual(parse_line(input), expected_result)

    def test_line_parser_no_upper_no_lower(self):
        input = u''' N_ODD_ESS;''';
        expected_result = {u'contlex': u'N_ODD_ESS', u'comment': u''}

        self.assertEqual(parse_line(input), expected_result)

    def test_line_parser_empty_upper_lower(self):
        input = u''' : N_ODD_E;''';
        expected_result = {u'upper': u'', u'lower': u'', u'contlex': u'N_ODD_E', u'comment': u''}

        self.assertEqual(parse_line(input), expected_result)

    def test_line_parser_with_comment(self):
        input = u''' +A+Comp+Attr:%>abpa      ATTRCONT    ;  ! båajasabpa,   *båajoesabpa'''
        expected_result = {u'upper': u'+A+Comp+Attr', u'lower': u'%>abpa', u'contlex': u'ATTRCONT', u'comment': u'! båajasabpa,   *båajoesabpa'}

        self.assertEqual(parse_line(input), expected_result)

    def test_line_parser_withComment(self):
        input = u'''  +A:%>X7 NomVadj "good A" ;'''
        expected_result = {u'upper': u'+A', u'lower': u'%>X7', u'contlex': u'NomVadj', u'translation': u'"good A"', u'comment': u''}

        self.assertEqual(parse_line(input), expected_result)


import re
import io
import argparse

class Lines(object):
    def __init__(self):
        self.longest = defaultdict(int)
        self.lines = []

    def parse_lines(self, lines):
        commentre = re.compile(ur'^\s*!')
        for line in lines:

            commentmatch = commentre.match(line)
            if commentmatch:
                self.lines.append(commentre.sub(u'!', line))
                continue

            contlexre = re.compile(ur'(?P<contlex>\S+)\s*;')
            contlexmatch = contlexre.search(line)
            if contlexmatch and not re.match(u'^\S', line):
                l = parse_line(line)
                self.lines.append(l)
                self.find_longest(l)
            else:
                self.lines.append(line)

    def find_longest(self, l):
        for name in l:
            if self.longest[name] < len(l[name]):
                self.longest[name] = len(l[name])

    def adjust_lines(self):
        newlines = []

        for l in self.lines:
            if isinstance(l, dict):
                s = io.StringIO()

                s.write(u' ' *
                        (self.longest[u'upper'] - len(l[u'upper']) + 1))
                s.write(l[u'upper'])

                if not (l[u'upper'] == u'' and l[u'lower'] == u''):
                    s.write(u':')
                else:
                    s.write(u' ')

                s.write(l[u'lower'])
                s.write(u' ' *
                        (self.longest[u'lower'] - len(l[u'lower']) + 1))

                s.write(l[u'contlex'])

                s.write(u' ' *
                        (self.longest[u'contlex'] -
                         len(l[u'contlex']) + 1))

                s.write(l[u'translation'])

                if self.longest[u'translation'] > 0:
                    s.write(u' ' *
                            (self.longest[u'translation'] -
                             len(l[u'translation']) + 1))

                s.write (u';')

                if l[u'comment'] != u'':
                    s.write(u' ')
                    s.write(l[u'comment'])

                s.write(u'\n')
                newlines.append(s.getvalue())
            else:
                newlines.append(l)

        return newlines

def parse_line(line):
    line_dict = defaultdict(unicode)

    contlexre = re.compile(ur'(?P<contlex>\S+)(?P<translation>\s+".+")*\s*;\s*(?P<comment>.*)')
    m = contlexre.search(line)

    line_dict[u'contlex'] = contlexre.search(line).group(u'contlex')
    if m.group(u'translation'):
        line_dict[u'translation'] = contlexre.search(line).group(u'translation').strip()
    line_dict[u'comment'] = contlexre.search(line).group(u'comment').strip()

    line = contlexre.sub(u'', line)

    m = line.find(u":")

    if m != -1:
        line_dict[u'upper'] = line[:m].strip()
        line_dict[u'lower'] = line[m + 1:].strip()

    return line_dict

def parse_options():
    parser = argparse.ArgumentParser(description = u'Align rules given in lexc files')
    parser.add_argument(u'lexcfile', help = u'Lexc file where rules should be aligned\nIf filename is -, then the file is read from stdin and written to stdout.')

    args = parser.parse_args()
    return args

if __name__ == u'__main__':
    UTF8Reader = codecs.getreader('utf8')
    sys.stdin = UTF8Reader(sys.stdin)
    UTF8Writer = codecs.getwriter('utf8')
    sys.stdout = UTF8Writer(sys.stdout)

    args = parse_options()

    with open(args.lexcfile) if args.lexcfile is not "-" \
            else sys.stdin as f:
        newlines = []
        readlines = []
        for l in f.readlines():
            if l.startswith(u'LEXICON '):
                lines = Lines()
                lines.parse_lines(readlines)
                newlines += lines.adjust_lines()
                readlines = []

            readlines.append(l)

        lines = Lines()
        lines.parse_lines(readlines)
        newlines += lines.adjust_lines()

    with open(args.lexcfile, u'w') if args.lexcfile is not "-" \
            else sys.stdout as f:
        f.writelines(newlines)
