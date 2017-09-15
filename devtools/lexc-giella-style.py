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

import argparse
import codecs
import io
import re
import sys
import unittest
from collections import defaultdict
from io import open


LEXC_LINE_RE = re.compile(r'''
    (?P<contlex>\S+)            #  any nonspace
    (?P<translation>\s+".+")?   #  optional translation
    \s*;\s*                     #  skip space and semicolon
    (?P<comment>!.*)?           #  followed by an optional comment
    $
''', re.VERBOSE | re.UNICODE)


LEXC_CONTENT_RE = re.compile(r'''
    (?P<exclam>^\s*!\s*)?          #  optional comment
    (?P<content>(<.+>)|(.+))?      #  optional content
''', re.VERBOSE | re.UNICODE)


class TestLexcAligner(unittest.TestCase):

    def test_non_lexc_line(self):
        input = u'''
abb ; babb
'''
        expected_result = u'''
abb ; babb
'''
        l = LexcAligner()
        l.parse_lines(input.split(u'\n'))

        self.assertEqual(expected_result, '\n'.join(l.adjust_lines()))

    def test_longest(self):
        input = u'''
 +N+Sg:             N_ODD_SG       ;
 +N+Pl:             N_ODD_PL       ;
 +N:             N_ODD_ESS      ;
 +N+SgNomCmp:e%^DISIMP    R              ;
 +N+SgGenCmp:e%>%^DISIMPn R              ;
 +N+PlGenCmp:%>%^DISIMPi  R              ;
 +N+Der1+Der/Dimin+N:%»adtj       GIERIEHTSADTJE ;
   +A:%>X7 NomVadj "good A" ;
'''

        l = LexcAligner()
        l.parse_lines(input.split(u'\n'))

        longest = {}
        longest[u'upper'] = 19
        longest[u'lower'] = 12
        longest[u'contlex'] = 14
        longest[u'translation'] = 8
        longest[u'divisor'] = 1

        self.assertEqual(longest, l.longest)

    def test_output_with_empty_upper_lower(self):
        input = u'''
 FINAL1         ;
 +N+Sg:             N_ODD_SG       ;
'''
        expected_result = u'''
        FINAL1   ;
 +N+Sg: N_ODD_SG ;
'''

        l = LexcAligner()
        l.parse_lines(input.split(u'\n'))

        self.assertEqual(expected_result, '\n'.join(l.adjust_lines()))

    def test_output_with_lexicon_and_semicolon(self):
        input = u'''
LEXICON GOAHTI-NE  !!= * __@CODE@__ Bisyll. V-Nouns
 NomV ;
 EssV ;
'''

        expected_result = u'''
LEXICON GOAHTI-NE  !!= * __@CODE@__ Bisyll. V-Nouns
  NomV ;
  EssV ;
'''

        l = LexcAligner()
        l.parse_lines(input.split(u'\n'))
        self.assertEqual(expected_result, '\n'.join(l.adjust_lines()))

    def test_output_with_lines_starting_with_chars(self):
        input = u'''
LEXICON Conjunction
jïh Cc ;
jah Cc ;
'''
        expected_result = u'''
LEXICON Conjunction
 jïh Cc ;
 jah Cc ;
'''
        l = LexcAligner()
        l.parse_lines(input.split(u'\n'))
        self.assertEqual(expected_result, '\n'.join(l.adjust_lines()))

    def test_output_with_lines_starting_with_exclam(self):
        input = u'''
LEXICON Conjunction
!dovne Cc ; ! dovne A jïh B
jïh Cc ;
jah Cc ;
'''
        expected_result = u'''
LEXICON Conjunction
! dovne Cc ; ! dovne A jïh B
    jïh Cc ;
    jah Cc ;
'''
        l = LexcAligner()
        l.parse_lines(input.split(u'\n'))
        self.assertEqual(expected_result, '\n'.join(l.adjust_lines()))

    def test_output_with_lines_with_leading_non_w(self):
        input = u'''
LEXICON Cc
+CC:0 # ;
'''
        expected_result = u'''
LEXICON Cc
 +CC:0 # ;
'''
        l = LexcAligner()
        l.parse_lines(input.split(u'\n'))
        self.assertEqual(expected_result, '\n'.join(l.adjust_lines()))

    def test_output(self):
        input = u'''
LEXICON DAKTERE
 +N+Sg:             N_ODD_SG       ;
 +N+Pl:             N_ODD_PL       ;
 +N:             N_ODD_ESS      ;
 +N+SgNomCmp:e%^DISIMP    R              ;
 +N+SgGenCmp:e%>%^DISIMPn R              ;
 +N+PlGenCmp:%>%^DISIMPi  R              ;
 +N+Der1+Der/Dimin+N:%»adtj       GIERIEHTSADTJE ;
+A+Comp+Attr:%>abpa      ATTRCONT    ;  ! båajasabpa,   *båajoesabpa
   +A:%>X7 NomVadj "good A" ;
! Test data:
!!€gt-norm: daktere # Odd-syllable test
'''

        expected_result = u'''
LEXICON DAKTERE
               +N+Sg:             N_ODD_SG                ;
               +N+Pl:             N_ODD_PL                ;
                  +N:             N_ODD_ESS               ;
         +N+SgNomCmp:e%^DISIMP    R                       ;
         +N+SgGenCmp:e%>%^DISIMPn R                       ;
         +N+PlGenCmp:%>%^DISIMPi  R                       ;
 +N+Der1+Der/Dimin+N:%»adtj       GIERIEHTSADTJE          ;
        +A+Comp+Attr:%>abpa       ATTRCONT                ; ! båajasabpa,   *båajoesabpa
                  +A:%>X7         NomVadj        "good A" ;
! Test data:
!!€gt-norm: daktere # Odd-syllable test
'''  # nopep8
        self.maxDiff = None

        l = LexcAligner()
        l.parse_lines(input.split(u'\n'))
        self.assertEqual(expected_result, '\n'.join(l.adjust_lines()))

    def test_less_great(self):
        input = u'''
LEXICON test
+V+IV+Inf+Err/Orth-a/á:uvvát K ;
< "@P.Px.add@" 0:u 0:v 0:v "+V":a "+IV":%> "+Der4":» "+Der/NomAct":m > ContLex ;
+V+IV+Inf+Err/Orth-a/á:uvvát K ;
'''
        expected_result = u'''
LEXICON test
                                                 +V+IV+Inf+Err/Orth-a/á:uvvát K       ;
 < "@P.Px.add@" 0:u 0:v 0:v "+V":a "+IV":%> "+Der4":» "+Der/NomAct":m >       ContLex ;
                                                 +V+IV+Inf+Err/Orth-a/á:uvvát K       ;
'''
        self.maxDiff = None

        l = LexcAligner()
        l.parse_lines(input.split(u'\n'))

        self.assertEqual(expected_result, '\n'.join(l.adjust_lines()))

    def test_line_percent_space_ending(self):
        input = u'''
            abb:babb%    ContLex;
uff:puf Contlex;
'''

        expected_result = u'''
 abb:babb%  ContLex ;
 uff:puf    Contlex ;
'''

        l = LexcAligner()
        l.parse_lines(input.split(u'\n'))

        self.assertEqual(expected_result, '\n'.join(l.adjust_lines()))

    def test_line_multiple_percent_space(self):
        input = u'''
LEXICON GOAHTILONGSHORT !!= * __@CODE@__ Sometimes long nom-compound-forms, long gen
 +N:%> GOAHTILONGSHORTCMP ;
 +N+Sg+Nom: K ;
< "+N":0 "+Sg":0 "+Nom":%> "@R.Nom3Px.add@" > NPx3V ;
 +N+Der+Der/viđá+Adv+Use/-PLX:»X7% viđá%  K ;
 +N+Der+Der/viđi+Adv+Use/-PLX:»X7viđi K ;
'''

        expected_result = u'''
LEXICON GOAHTILONGSHORT !!= * __@CODE@__ Sometimes long nom-compound-forms, long gen
                                            +N:%>          GOAHTILONGSHORTCMP ;
                                     +N+Sg+Nom:            K                  ;
 < "+N":0 "+Sg":0 "+Nom":%> "@R.Nom3Px.add@" >             NPx3V              ;
                  +N+Der+Der/viđá+Adv+Use/-PLX:»X7% viđá%  K                  ;
                  +N+Der+Der/viđi+Adv+Use/-PLX:»X7viđi     K                  ;
'''
        self.maxDiff = None
        l = LexcAligner()
        l.parse_lines(input.split(u'\n'))

        self.assertEqual(expected_result, '\n'.join(l.adjust_lines()))

    def test_line_startswith_contlex(self):
        input = u'''
LEXICON NounRoot
N_NEWWORDS ;
 N_sms2x ;
! N-INCOMING ;

LEXICON nouns
!! This is a temporary solution until nouns are moved to xml
N_NEWWORDS ;
'''
        expected_result = u'''
LEXICON NounRoot
   N_NEWWORDS ;
   N_sms2x    ;
!  N-INCOMING ;

LEXICON nouns
!! This is a temporary solution until nouns are moved to xml
   N_NEWWORDS ;
'''

        self.maxDiff = None
        l = LexcAligner()
        l.parse_lines(input.split(u'\n'))

        self.assertEqual(expected_result, '\n'.join(l.adjust_lines()))


class TestLineParser(unittest.TestCase):

    def test_line_parser_upper_lower(self):
        l = LexcAligner()
        line = u'        +N+SgNomCmp:e%^DISIMP    R              ;'
        input = LEXC_LINE_RE.search(line).groupdict()
        input.update(LEXC_CONTENT_RE.match(
            LEXC_LINE_RE.sub('', line)).groupdict())
        expected_result = {
            u'upper': u'+N+SgNomCmp',
            u'lower': u'e%^DISIMP',
            u'contlex': u'R',
            u'divisor': u':'
        }

        self.assertDictEqual(parse_line(input), expected_result)

    def test_line_parser_no_lower(self):
        l = LexcAligner()
        line = (
            u'               +N+Sg:             N_ODD_SG   ;')
        input = LEXC_LINE_RE.search(line).groupdict()
        input.update(LEXC_CONTENT_RE.match(
            LEXC_LINE_RE.sub('', line)).groupdict())
        expected_result = {
            u'upper': u'+N+Sg',
            u'lower': u'',
            u'contlex': u'N_ODD_SG',
            u'divisor': u':'
        }

        self.assertDictEqual(parse_line(input), expected_result)

    def test_line_parser_no_upper_no_lower(self):
        l = LexcAligner()
        line = u' N_ODD_ESS;'
        input = LEXC_LINE_RE.search(line).groupdict()
        input.update(LEXC_CONTENT_RE.match(
            LEXC_LINE_RE.sub('', line)).groupdict())
        expected_result = {
            u'contlex': u'N_ODD_ESS',
        }

        self.assertDictEqual(parse_line(input), expected_result)

    def test_line_parser_empty_upper_lower(self):
        l = LexcAligner()
        line = u' : N_ODD_E;'
        input = LEXC_LINE_RE.search(line).groupdict()
        input.update(LEXC_CONTENT_RE.match(
            LEXC_LINE_RE.sub('', line)).groupdict())
        expected_result = {
            u'upper': u'', u'lower': u'',
            u'contlex': u'N_ODD_E',
            u'divisor': u':'
        }

        self.assertDictEqual(parse_line(input), expected_result)

    def test_line_parser_with_comment(self):
        l = LexcAligner()
        line = (
            u'+A+Comp+Attr:%>abpa ATTRCONT; '
            u'! båajasabpa, *båajoesabpa')
        input = LEXC_LINE_RE.search(line).groupdict()
        input.update(LEXC_CONTENT_RE.match(
            LEXC_LINE_RE.sub('', line)).groupdict())
        expected_result = {
            u'upper': u'+A+Comp+Attr',
            u'lower': u'%>abpa',
            u'contlex': u'ATTRCONT',
            u'comment': u'! båajasabpa, *båajoesabpa',
            u'divisor': u':'
        }

        self.assertDictEqual(parse_line(input), expected_result)

    def test_line_parser_with_translation(self):
        l = LexcAligner()
        line = u'  +A:%>X7 NomVadj "good A" ;'
        input = LEXC_LINE_RE.search(line).groupdict()
        input.update(LEXC_CONTENT_RE.match(
            LEXC_LINE_RE.sub('', line)).groupdict())
        expected_result = {
            u'upper': u'+A', u'lower': u'%>X7',
            u'contlex': u'NomVadj',
            u'translation': u'"good A"',
            u'divisor': u':'
        }

        self.assertDictEqual(parse_line(input), expected_result)

    def test_line_parser_with_leading_upper_and_contlex(self):
        l = LexcAligner()
        line = u'jïh Cc ;'
        input = LEXC_LINE_RE.search(line).groupdict()
        input.update(LEXC_CONTENT_RE.match(
            LEXC_LINE_RE.sub('', line)).groupdict())
        expected_result = {
            u'upper': u'jïh',
            u'contlex': u'Cc',
        }

        self.assertDictEqual(parse_line(input), expected_result)

    def test_line_parser_with_leading_exclam(self):
        l = LexcAligner()
        line = u'!dovne Cc ; ! dovne A jïh B'
        input = LEXC_LINE_RE.search(line).groupdict()
        input.update(LEXC_CONTENT_RE.match(
            LEXC_LINE_RE.sub('', line)).groupdict())
        expected_result = {
            u'comment': u'! dovne A jïh B',
            u'upper': u'dovne',
            u'contlex': u'Cc',
            u'exclam': u'!'
        }

        self.assertDictEqual(parse_line(input), expected_result)

    def test_line_parser_less_great(self):
        l = LexcAligner()
        line = (
            u'< "@P.Px.add@" 0:u 0:v 0:v "+V":a "+IV":%> "+Der4":» '
            u'"+Der/NomAct":m > ContLex ;')
        input = LEXC_LINE_RE.search(line).groupdict()
        input.update(LEXC_CONTENT_RE.match(
            LEXC_LINE_RE.sub('', line)).groupdict())
        expected_result = {u'contlex': u'ContLex',
                           u'upper':
                               u'< "@P.Px.add@" 0:u 0:v 0:v "+V":a "+IV":%> '
                               u'"+Der4":» "+Der/NomAct":m >'}

        self.assertDictEqual(parse_line(input), expected_result)

    def test_line_parser_lower_ends_with_percent(self):
        l = LexcAligner()
        line = u'abb:babb%¥ ContLex ;'
        input = LEXC_LINE_RE.search(line).groupdict()
        input.update(LEXC_CONTENT_RE.match(
            LEXC_LINE_RE.sub('', line)).groupdict())
        expected_result = {u'contlex': u'ContLex',
                           u'upper': u'abb',
                           u'lower': u'babb% ',
                           u'divisor': u':', }

        self.assertDictEqual(parse_line(input), expected_result)

    def test_line_parser_multiple_percent_space(self):
        l = LexcAligner()
        line = u'+N+Der+Der/viđá+Adv+Use/-PLX:»X7%¥viđá%¥ K ;'
        input = LEXC_LINE_RE.search(line).groupdict()
        input.update(LEXC_CONTENT_RE.match(
            LEXC_LINE_RE.sub('', line)).groupdict())
        expected_result = {u'contlex': u'K',
                           u'upper': u'+N+Der+Der/viđá+Adv+Use/-PLX',
                           u'lower': u'»X7% viđá% ',
                           u'divisor': u':', }

        self.assertDictEqual(parse_line(input), expected_result)

    def test_only_contlex(self):
        l = LexcAligner()
        line = u'N_NEWWORDS ;'
        input = LEXC_LINE_RE.search(line).groupdict()
        input.update(LEXC_CONTENT_RE.match(
            LEXC_LINE_RE.sub('', line)).groupdict())
        expected_result = {u'contlex': u'N_NEWWORDS'}

        self.assertDictEqual(parse_line(input), expected_result)


class LexcAligner(object):

    def __init__(self):
        self.longest = defaultdict(int)
        self.lines = []

    def parse_lines(self, lines):
        for line in lines:
            line = line.replace(u'% ', u'%¥')
            lexc_line_match = LEXC_LINE_RE.search(line)
            if lexc_line_match and not line.startswith('LEXICON '):
                input = lexc_line_match.groupdict()
                input.update(LEXC_CONTENT_RE.match(
                LEXC_LINE_RE.sub('', line)).groupdict())
                l = parse_line(input)
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

                if self.longest[u'exclam']:
                    if l[u'exclam']:
                        s.write(l[u'exclam'])
                    else:
                        s.write(u' ')

                s.write(u' ' *
                        (self.longest[u'upper'] - len(l[u'upper']) + 1))
                s.write(l[u'upper'])

                if l[u'divisor']:
                    s.write(l[u'divisor'])
                elif self.longest[u'divisor']:
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

                s.write(u';')

                if l[u'comment'] != u'':
                    s.write(u' ')
                    s.write(l[u'comment'])

                newlines.append(s.getvalue())
            else:
                newlines.append(l)

        return newlines


class LexcSorter(object):
    """Sort entries in a lexc lexicon."""

    def __init__(self):
        self.lines = []
        self.lexc_lines = []

    def parse_lines(self, lines):
        for line in lines:
            lexc_line_match = LEXC_LINE_RE.search(line)
            if lexc_line_match and not line.startswith('LEXICON '):
                input = lexc_line_match.groupdict()
                input.update(LEXC_CONTENT_RE.match(
                    LEXC_LINE_RE.sub('', line)).groupdict())
                l = parse_line(input)
                self.lexc_lines.append((l[u'upper'], line))
            else:
                if line.strip():
                    self.lines.append(line)

    def adjust_lines(self):
        newlines = []
        newlines.extend(self.lines)
        newlines.extend([l[1] for l in sorted(self.lexc_lines)])
        newlines.append('')

        return newlines


def parse_line(old_match):
    line_dict = defaultdict(unicode)

    if old_match.get('exclam'):
        line_dict[u'exclam'] = u'!'

    line_dict[u'contlex'] = old_match.get(u'contlex')
    if old_match.get(u'translation'):
        line_dict[u'translation'] = old_match.get(
            u'translation').strip().replace(u'%¥', u'% ')

    if old_match.get(u'comment'):
        line_dict[u'comment'] = old_match.get(
            u'comment').strip().replace(u'%¥', u'% ')

    line = old_match.get('content')
    if line:
        line = line.replace(u'%¥', u'% ')
        if line.startswith(u'<') and line.endswith(u'>'):
            line_dict[u'upper'] = line
        else:
            lexc_line_match = line.find(u":")

            if lexc_line_match != -1:
                line_dict[u'upper'] = line[:lexc_line_match].strip()
                line_dict[u'divisor'] = u':'
                line_dict[u'lower'] = line[lexc_line_match + 1:].strip()
                if line_dict[u'lower'].endswith('%'):
                    line_dict[u'lower'] = line_dict[u'lower'] + u' '
            else:
                if line.strip():
                    line_dict[u'upper'] = line.strip()

    return line_dict


def align_lexicon(readlines):
    lines = LexcAligner()
    lines.parse_lines(readlines)

    return lines.adjust_lines()


def sort_lexicon(readlines):
    lines = LexcSorter()
    lines.parse_lines(readlines)

    return lines.adjust_lines()


def parse_options():
    parser = argparse.ArgumentParser(
        description=u'Align rules given in lexc files')
    group = parser.add_mutually_exclusive_group(required=True)
    group.add_argument(u'--align',
                       action=u'store_true',
                       help=u'Align lexicon entries')
    group.add_argument(u'--sort',
                       action=u'store_true',
                       help=u'Sort lexicon entries')
    parser.add_argument(u'lexcfile',
                        help=u'Lexc file where lexicon entries should '
                        'be manipulated. If filename is -, then the file '
                        'is read from stdin and written to stdout.')

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

        for l in f:
            if l.startswith(u'LEXICON '):
                newlines.extend(readlines)
                readlines = [l.rstrip()]
                break
            readlines.append(l.rstrip())

        for l in f:
            if l.startswith(u'LEXICON '):
                if args.align:
                    newlines.extend(align_lexicon(readlines))
                if args.sort:
                    newlines.extend(sort_lexicon(readlines))
                readlines = []
            readlines.append(l.rstrip())

        if args.align:
            newlines.extend(align_lexicon(readlines))
        if args.sort:
            newlines.extend(sort_lexicon(readlines))

    with open(args.lexcfile, u'w') if args.lexcfile is not "-" \
            else sys.stdout as f:
        f.write(u'\n'.join(newlines))
        f.write(u'\n')
