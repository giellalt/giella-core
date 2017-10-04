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
#   Copyright © 2016-2017 The University of Tromsø &
#                         the Norwegian Sámi Parliament
#   http://giellatekno.uit.no & http://divvun.no
#

"""Script to sort and align lexc entries."""


from __future__ import absolute_import, print_function

import argparse
import codecs
import io
import re
import sys
import unittest
from collections import defaultdict


LEXC_LINE_RE = re.compile(r'''
    (?P<contlex>\S+)            #  any nonspace
    (?P<translation>\s+".*")?   #  optional translation, might be empty
    \s*;\s*                     #  skip space and semicolon
    (?P<comment>!.*)?           #  followed by an optional comment
    $
''', re.VERBOSE | re.UNICODE)


LEXC_CONTENT_RE = re.compile(r'''
    (?P<exclam>^\s*!\s*)?          #  optional comment
    (?P<content>(<.+>)|(.+))?      #  optional content
''', re.VERBOSE | re.UNICODE)


class TestLexcAligner(unittest.TestCase):
    """Test that lexc alignment works as supposed to."""

    def test_non_lexc_line(self):
        """Test how non lexc line is handled."""
        content = u'''
abb ; babb
'''
        expected_result = u'''
abb ; babb
'''
        aligner = LexcAligner()
        aligner.parse_lines(content.split(u'\n'))

        self.assertEqual(expected_result, '\n'.join(aligner.adjust_lines()))

    def test_longest(self):
        """Check that the longest attribute is set correctly."""
        content = u'''
 +N+Sg:             N_ODD_SG       ;
 +N+Pl:             N_ODD_PL       ;
 +N:             N_ODD_ESS      ;
 +N+SgNomCmp:e%^DISIMP    R              ;
 +N+SgGenCmp:e%>%^DISIMPn R              ;
 +N+PlGenCmp:%>%^DISIMPi  R              ;
 +N+Der1+Der/Dimin+N:%»adtj       GIERIEHTSADTJE ;
   +A:%>X7 NomVadj "good A" ;
'''

        aligner = LexcAligner()
        aligner.parse_lines(content.split(u'\n'))

        longest = {}
        longest[u'upper'] = 19
        longest[u'lower'] = 12
        longest[u'contlex'] = 14
        longest[u'translation'] = 8
        longest[u'divisor'] = 1

        self.assertEqual(longest, aligner.longest)

    def test_only_contlex(self):
        """Test how contlex only entries are handled."""
        content = u'''
 FINAL1         ;
 +N+Sg:             N_ODD_SG       ;
'''
        expected_result = u'''
        FINAL1   ;
 +N+Sg: N_ODD_SG ;
'''

        aligner = LexcAligner()
        aligner.parse_lines(content.split(u'\n'))

        self.assertEqual(expected_result, '\n'.join(aligner.adjust_lines()))

    def test_lexicon_contlex(self):
        """Check how lexicon and contlex only entries are handled."""
        content = u'''
LEXICON GOAHTI-NE  !!= * __@CODE@__ Bisyll. V-Nouns
 NomV ;
 EssV ;
'''

        expected_result = u'''
LEXICON GOAHTI-NE  !!= * __@CODE@__ Bisyll. V-Nouns
  NomV ;
  EssV ;
'''

        aligner = LexcAligner()
        aligner.parse_lines(content.split(u'\n'))
        self.assertEqual(expected_result, '\n'.join(aligner.adjust_lines()))

    def test_lexicon_charientries(self):
        """Check how lexicon entries with only chars are handled."""
        content = u'''
LEXICON Conjunction
jïh Cc ;
jah Cc ;
'''
        expected_result = u'''
LEXICON Conjunction
 jïh Cc ;
 jah Cc ;
'''
        aligner = LexcAligner()
        aligner.parse_lines(content.split(u'\n'))
        self.assertEqual(expected_result, '\n'.join(aligner.adjust_lines()))

    def test_lexicon_comment(self):
        """Check how commented lexc entries are handled."""
        content = u'''
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
        aligner = LexcAligner()
        aligner.parse_lines(content.split(u'\n'))
        self.assertEqual(expected_result, '\n'.join(aligner.adjust_lines()))

    def test_nonalphabetic(self):
        """Test how entries starting with nonalphetic chars are handled."""
        content = u'''
LEXICON Cc
+CC:0 # ;
'''
        expected_result = u'''
LEXICON Cc
 +CC:0 # ;
'''
        aligner = LexcAligner()
        aligner.parse_lines(content.split(u'\n'))
        self.assertEqual(expected_result, '\n'.join(aligner.adjust_lines()))

    def test_output(self):
        """Test that only lexc entries are adjusted."""
        content = u'''
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

        aligner = LexcAligner()
        aligner.parse_lines(content.split(u'\n'))
        self.assertEqual(expected_result, '\n'.join(aligner.adjust_lines()))

    def test_less_great(self):
        """Content inside <> should be untouched, but aligned."""
        content = u'''
LEXICON test
+V+IV+Inf+Err/Orth-a/á:uvvát K ;
< "@P.Px.add@" 0:u 0:v 0:v "+V":a "+IV":%> "+Der4":» "+Der/NomAct":m > ContLex ;
+V+IV+Inf+Err/Orth-a/á:uvvát K ;
'''  # nopep8
        expected_result = u'''
LEXICON test
                                                 +V+IV+Inf+Err/Orth-a/á:uvvát K       ;
 < "@P.Px.add@" 0:u 0:v 0:v "+V":a "+IV":%> "+Der4":» "+Der/NomAct":m >       ContLex ;
                                                 +V+IV+Inf+Err/Orth-a/á:uvvát K       ;
'''  # nopep8

        aligner = LexcAligner()
        aligner.parse_lines(content.split(u'\n'))

        self.assertEqual(expected_result, '\n'.join(aligner.adjust_lines()))

    def test_line_percent_space_ending(self):
        """Check how lower parts ending on percent are handled."""
        content = u'''
            abb:babb%    ContLex;
uff:puf Contlex;
'''

        expected_result = u'''
 abb:babb%  ContLex ;
 uff:puf    Contlex ;
'''

        aligner = LexcAligner()
        aligner.parse_lines(content.split(u'\n'))

        self.assertEqual(expected_result, '\n'.join(aligner.adjust_lines()))

    def test_percent_space(self):
        """Check how lines containing multiple percent signs are handled."""
        content = u'''
LEXICON GOAHTILONGSHORT !!= * __@CODE@__ Sometimes long nom-compound-forms, long gen
 +N:%> GOAHTILONGSHORTCMP ;
 +N+Sg+Nom: K ;
< "+N":0 "+Sg":0 "+Nom":%> "@R.Nom3Px.add@" > NPx3V ;
 +N+Der+Der/viđá+Adv+Use/-PLX:»X7% viđá%  K ;
 +N+Der+Der/viđi+Adv+Use/-PLX:»X7viđi K ;
'''  # nopep8

        expected_result = u'''
LEXICON GOAHTILONGSHORT !!= * __@CODE@__ Sometimes long nom-compound-forms, long gen
                                            +N:%>          GOAHTILONGSHORTCMP ;
                                     +N+Sg+Nom:            K                  ;
 < "+N":0 "+Sg":0 "+Nom":%> "@R.Nom3Px.add@" >             NPx3V              ;
                  +N+Der+Der/viđá+Adv+Use/-PLX:»X7% viđá%  K                  ;
                  +N+Der+Der/viđi+Adv+Use/-PLX:»X7viđi     K                  ;
'''  # nopep8
        aligner = LexcAligner()
        aligner.parse_lines(content.split(u'\n'))

        self.assertEqual(expected_result, '\n'.join(aligner.adjust_lines()))

    def test_line_startswith_contlex(self):
        """Check how lines with only contlex entries are handled."""
        content = u'''
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

        aligner = LexcAligner()
        aligner.parse_lines(content.split(u'\n'))

        self.assertEqual(expected_result, '\n'.join(aligner.adjust_lines()))


class TestLineParser(unittest.TestCase):
    """Test how individual lines are parsed."""

    def test_line_parser_upper_lower(self):
        """Check that lines with upper and lower defined are handled."""
        line = u'        +N+SgNomCmp:e%^DISIMP    R              ;'
        content = LEXC_LINE_RE.search(line).groupdict()
        content.update(LEXC_CONTENT_RE.match(
            LEXC_LINE_RE.sub('', line)).groupdict())
        expected_result = {
            u'upper': u'+N+SgNomCmp',
            u'lower': u'e%^DISIMP',
            u'contlex': u'R',
            u'divisor': u':'
        }

        self.assertDictEqual(parse_line(content), expected_result)

    def test_line_parser_no_lower(self):
        """Check how lines with empty lower are handled."""
        line = (
            u'               +N+Sg:             N_ODD_SG   ;')
        content = LEXC_LINE_RE.search(line).groupdict()
        content.update(LEXC_CONTENT_RE.match(
            LEXC_LINE_RE.sub('', line)).groupdict())
        expected_result = {
            u'upper': u'+N+Sg',
            u'lower': u'',
            u'contlex': u'N_ODD_SG',
            u'divisor': u':'
        }

        self.assertDictEqual(parse_line(content), expected_result)

    def test_line_contlex_only(self):
        """Check how lines without upper and lower parts are handled."""
        line = u' N_ODD_ESS;'
        content = LEXC_LINE_RE.search(line).groupdict()
        content.update(LEXC_CONTENT_RE.match(
            LEXC_LINE_RE.sub('', line)).groupdict())
        expected_result = {
            u'contlex': u'N_ODD_ESS',
        }

        self.assertDictEqual(parse_line(content), expected_result)

    def test_empty_upper_lower(self):
        """Check how empty upper/lower combo is handled."""
        line = u' : N_ODD_E;'
        content = LEXC_LINE_RE.search(line).groupdict()
        content.update(LEXC_CONTENT_RE.match(
            LEXC_LINE_RE.sub('', line)).groupdict())
        expected_result = {
            u'upper': u'', u'lower': u'',
            u'contlex': u'N_ODD_E',
            u'divisor': u':'
        }

        self.assertDictEqual(parse_line(content), expected_result)

    def test_comment(self):
        """Check how commented lines are handled."""
        line = (
            u'+A+Comp+Attr:%>abpa ATTRCONT; '
            u'! båajasabpa, *båajoesabpa')
        content = LEXC_LINE_RE.search(line).groupdict()
        content.update(LEXC_CONTENT_RE.match(
            LEXC_LINE_RE.sub('', line)).groupdict())
        expected_result = {
            u'upper': u'+A+Comp+Attr',
            u'lower': u'%>abpa',
            u'contlex': u'ATTRCONT',
            u'comment': u'! båajasabpa, *båajoesabpa',
            u'divisor': u':'
        }

        self.assertDictEqual(parse_line(content), expected_result)

    def test_translation(self):
        """Check how lines containing translations are handled."""
        line = u'  +A:%>X7 NomVadj "good A" ;'
        content = LEXC_LINE_RE.search(line).groupdict()
        content.update(LEXC_CONTENT_RE.match(
            LEXC_LINE_RE.sub('', line)).groupdict())
        expected_result = {
            u'upper': u'+A', u'lower': u'%>X7',
            u'contlex': u'NomVadj',
            u'translation': u'"good A"',
            u'divisor': u':'
        }

        self.assertDictEqual(parse_line(content), expected_result)

    def test_upper_contlex(self):
        """Check how entries with only upper and contlex are handled."""
        line = u'jïh Cc ;'
        content = LEXC_LINE_RE.search(line).groupdict()
        content.update(LEXC_CONTENT_RE.match(
            LEXC_LINE_RE.sub('', line)).groupdict())
        expected_result = {
            u'upper': u'jïh',
            u'contlex': u'Cc',
        }

        self.assertDictEqual(parse_line(content), expected_result)

    def test_leading_exclam(self):
        """Check how entries with a leading exclam are handled."""
        line = u'!dovne Cc ; ! dovne A jïh B'
        content = LEXC_LINE_RE.search(line).groupdict()
        content.update(LEXC_CONTENT_RE.match(
            LEXC_LINE_RE.sub('', line)).groupdict())
        expected_result = {
            u'comment': u'! dovne A jïh B',
            u'upper': u'dovne',
            u'contlex': u'Cc',
            u'exclam': u'!'
        }

        self.assertDictEqual(parse_line(content), expected_result)

    def test_less_great(self):
        """Check that entries within <> are correctly handled."""
        line = (
            u'< "@P.Px.add@" 0:u 0:v 0:v "+V":a "+IV":%> "+Der4":» '
            u'"+Der/NomAct":m > ContLex ;')
        content = LEXC_LINE_RE.search(line).groupdict()
        content.update(LEXC_CONTENT_RE.match(
            LEXC_LINE_RE.sub('', line)).groupdict())
        expected_result = {u'contlex': u'ContLex',
                           u'upper':
                               u'< "@P.Px.add@" 0:u 0:v 0:v "+V":a "+IV":%> '
                               u'"+Der4":» "+Der/NomAct":m >'}

        self.assertDictEqual(parse_line(content), expected_result)

    def test_ends_with_percent(self):
        """Check that entries containing percent are correctly handled."""
        line = u'abb:babb%¥ ContLex ;'
        content = LEXC_LINE_RE.search(line).groupdict()
        content.update(LEXC_CONTENT_RE.match(
            LEXC_LINE_RE.sub('', line)).groupdict())
        expected_result = {u'contlex': u'ContLex',
                           u'upper': u'abb',
                           u'lower': u'babb% ',
                           u'divisor': u':', }

        self.assertDictEqual(parse_line(content), expected_result)

    def test_multiple_percent(self):
        """Check how entries with multiple percent signs are handled."""
        line = u'+N+Der+Der/viđá+Adv+Use/-PLX:»X7%¥viđá%¥ K ;'
        content = LEXC_LINE_RE.search(line).groupdict()
        content.update(LEXC_CONTENT_RE.match(
            LEXC_LINE_RE.sub('', line)).groupdict())
        expected_result = {u'contlex': u'K',
                           u'upper': u'+N+Der+Der/viđá+Adv+Use/-PLX',
                           u'lower': u'»X7% viđá% ',
                           u'divisor': u':', }

        self.assertDictEqual(parse_line(content), expected_result)

    def test_only_contlex(self):
        """Check how contlex only lines are handled."""
        line = u'N_NEWWORDS ;'
        content = LEXC_LINE_RE.search(line).groupdict()
        content.update(LEXC_CONTENT_RE.match(
            LEXC_LINE_RE.sub('', line)).groupdict())
        expected_result = {u'contlex': u'N_NEWWORDS'}

        self.assertDictEqual(parse_line(content), expected_result)

    def test_empty_translation(self):
        """Check lines with empty translation."""
        line = u'tsollegidh:tsolleg GOLTELIDH_IV "" ;'
        content = LEXC_LINE_RE.search(line).groupdict()
        content.update(LEXC_CONTENT_RE.match(
            LEXC_LINE_RE.sub('', line)).groupdict())
        expected_result = {u'contlex': u'GOLTELIDH_IV',
                           u'upper': u'tsollegidh',
                           u'lower': u'tsolleg',
                           u'translation': u'""',
                           u'divisor': u':'}

        self.assertDictEqual(parse_line(content), expected_result)


class TestLineCompactor(unittest.TestCase):
    """Test how individual lines are compacted."""

    def test_line_parser_upper_lower(self):
        """Check that lines with upper and lower defined are handled."""
        content = {
            u'upper': u'+N+SgNomCmp',
            u'lower': u'e%^DISIMP',
            u'contlex': u'R',
            u'divisor': u':'
        }
        expected_result = u'+N+SgNomCmp:e%^DISIMP R ;'

        self.assertEqual(compact_line(content), expected_result)

    def test_line_parser_no_lower(self):
        """Check how lines with empty lower are handled."""
        content = {
            u'upper': u'+N+Sg',
            u'lower': u'',
            u'contlex': u'N_ODD_SG',
            u'divisor': u':'
        }
        expected_result = (u'+N+Sg: N_ODD_SG ;')

        self.assertEqual(compact_line(content), expected_result)

    def test_line_contlex_only(self):
        """Check how lines without upper and lower parts are handled."""
        content = {
            u'contlex': u'N_ODD_ESS',
        }
        expected_result = u'N_ODD_ESS ;'

        self.assertEqual(compact_line(content), expected_result)

    def test_empty_upper_lower(self):
        """Check how empty upper/lower combo is handled."""
        content = {
            u'upper': u'', u'lower': u'',
            u'contlex': u'N_ODD_E',
            u'divisor': u':'
        }
        expected_result = u': N_ODD_E ;'

        self.assertEqual(compact_line(content), expected_result)

    def test_comment(self):
        """Check how commented lines are handled."""
        content = {
            u'upper': u'+A+Comp+Attr',
            u'lower': u'%>abpa',
            u'contlex': u'ATTRCONT',
            u'comment': u'! båajasabpa, *båajoesabpa',
            u'divisor': u':'
        }
        expected_result = (
            u'+A+Comp+Attr:%>abpa ATTRCONT ; '
            u'! båajasabpa, *båajoesabpa')

        self.assertEqual(compact_line(content), expected_result)

    def test_translation(self):
        """Check how lines containing translations are handled."""
        content = {
            u'upper': u'+A', u'lower': u'%>X7',
            u'contlex': u'NomVadj',
            u'translation': u'"good A"',
            u'divisor': u':'
        }
        expected_result = u'+A:%>X7 NomVadj "good A" ;'

        self.assertEqual(compact_line(content), expected_result)

    def test_upper_contlex(self):
        """Check how entries with only upper and contlex are handled."""
        content = {
            u'upper': u'jïh',
            u'contlex': u'Cc',
        }
        expected_result = u'jïh Cc ;'

        self.assertEqual(compact_line(content), expected_result)

    def test_leading_exclam(self):
        """Check how entries with a leading exclam are handled."""
        content = {
            u'comment': u'! dovne A jïh B',
            u'upper': u'dovne',
            u'contlex': u'Cc',
            u'exclam': u'!'
        }
        expected_result = u'!dovne Cc ; ! dovne A jïh B'

        self.assertEqual(compact_line(content), expected_result)

    def test_less_great(self):
        """Check that entries within <> are correctly handled."""
        content = {u'contlex': u'ContLex',
                   u'upper':
                       u'< "@P.Px.add@" 0:u 0:v 0:v "+V":a "+IV":%> '
                       u'"+Der4":» "+Der/NomAct":m >'}
        expected_result = (
            u'< "@P.Px.add@" 0:u 0:v 0:v "+V":a "+IV":%> "+Der4":» '
            u'"+Der/NomAct":m > ContLex ;')

        self.assertEqual(compact_line(content), expected_result)

    def test_ends_with_percent(self):
        """Check that entries containing percent are correctly handled."""
        content = {u'contlex': u'ContLex',
                   u'upper': u'abb',
                   u'lower': u'babb% ',
                   u'divisor': u':', }
        expected_result = u'abb:babb%  ContLex ;'

        self.assertEqual(compact_line(content), expected_result)

    def test_multiple_percent(self):
        """Check how entries with multiple percent signs are handled."""
        content = {u'contlex': u'K',
                   u'upper': u'+N+Der+Der/vida+Adv+Use/-PLX',
                   u'lower': u'»X7% vida% ',
                   u'divisor': u':', }
        expected_result = u'+N+Der+Der/vida+Adv+Use/-PLX:»X7% vida%  K ;'

        self.assertEqual(compact_line(content), expected_result)

    def test_only_contlex(self):
        """Check how contlex only lines are handled."""
        expected_result = u'N_NEWWORDS ;'
        content = {u'contlex': u'N_NEWWORDS'}

        self.assertEqual(compact_line(content), expected_result)


class TestSorting(unittest.TestCase):
    """Test how individual lines are parsed."""

    def setUp(self):
        """Set up common resources."""
        self.sorting_lines = [
            u'ábčđ:cdef ABBR;',
            u'aŋđŧá:abcd CABBR;',
            u'bžčŋ:bcde BABBR;',
        ]

    def test_alpha(self):
        """Test sorting by lemma."""
        self.assertListEqual(
            [u'aŋđŧá:abcd CABBR ;', u'bžčŋ:bcde BABBR ;',
             u'ábčđ:cdef ABBR ;', u''],
            sort_lexicon(self.sorting_lines, mode='alpha'))

    def test_contlex(self):
        """Test sorting by continuation lexicon."""
        self.assertListEqual(
            [u'ábčđ:cdef ABBR ;', u'bžčŋ:bcde BABBR ;',
             u'aŋđŧá:abcd CABBR ;', u''],
            sort_lexicon(self.sorting_lines, mode='contlex'))

    def test_revstem(self):
        """Test sorting by reverted stem."""
        self.assertListEqual(
            [u'aŋđŧá:abcd CABBR ;', u'bžčŋ:bcde BABBR ;',
             u'ábčđ:cdef ABBR ;', u''],
            sort_lexicon(self.sorting_lines, mode='revstem'))


class LexcAligner(object):
    """Class to align lexc elements inside a lexicon."""

    def __init__(self):
        """Initialise the LexcAligner class."""
        self.longest = defaultdict(int)
        self.lines = []

    def parse_lines(self, lines):
        """Parse the lines given.

        Arguments:
            lines (list of str): the entries of a lexicon.
        """
        for line in lines:
            line = line.replace(u'% ', u'%¥')
            lexc_line_match = LEXC_LINE_RE.search(line)
            if lexc_line_match and not line.startswith('LEXICON '):
                content = lexc_line_match.groupdict()
                content.update(LEXC_CONTENT_RE.match(
                    LEXC_LINE_RE.sub('', line)).groupdict())
                line_dict = parse_line(content)
                self.lines.append(line_dict)
                self.set_longest(line_dict)
            else:
                self.lines.append(line)

    def set_longest(self, line_dict):
        """Record the longest entries."""
        for name in line_dict:
            if self.longest[name] < len(line_dict[name]):
                self.longest[name] = len(line_dict[name])

    def adjust_lines(self):
        """Align the lines of a lexicon."""
        adjusted_lines = []
        for line in self.lines:
            if isinstance(line, dict):
                string_buffer = []

                if self.longest[u'exclam']:
                    if line[u'exclam']:
                        string_buffer.append(line[u'exclam'])
                    else:
                        string_buffer.append(u' ')

                string_buffer.append(u' ' *
                                     (self.longest[u'upper'] -
                                      len(line[u'upper']) + 1))
                string_buffer.append(line[u'upper'])

                if line[u'divisor']:
                    string_buffer.append(line[u'divisor'])
                elif self.longest[u'divisor']:
                    string_buffer.append(u' ')

                string_buffer.append(line[u'lower'])

                string_buffer.append(u' ' *
                                     (self.longest[u'lower'] -
                                      len(line[u'lower']) + 1))

                string_buffer.append(line[u'contlex'])

                string_buffer.append(u' ' *
                                     (self.longest[u'contlex'] -
                                      len(line[u'contlex']) + 1))

                string_buffer.append(line[u'translation'])

                if self.longest[u'translation'] > 0:
                    string_buffer.append(u' ' *
                                         (self.longest[u'translation'] -
                                          len(line[u'translation']) + 1))

                string_buffer.append(u';')

                if line[u'comment'] != u'':
                    string_buffer.append(u' ')
                    string_buffer.append(line[u'comment'])

                adjusted_lines.append(''.join(string_buffer))
            else:
                adjusted_lines.append(line)

        return adjusted_lines


class LexcSorter(object):
    """Sort entries in a lexc lexicon."""

    def __init__(self, mode):
        """Initialise the LexcSorter class."""
        self.lines = []
        self.lexc_lines = []
        self.mode = mode

    def parse_lines(self, lines):
        """Parse the lines of a lexicon.

        Arguments:
            lines (list of str): the lines of a lexicon.
        """
        for line in lines:
            lexc_line_match = LEXC_LINE_RE.search(line)
            if lexc_line_match and not line.startswith('LEXICON '):
                content = lexc_line_match.groupdict()
                content.update(LEXC_CONTENT_RE.match(
                    LEXC_LINE_RE.sub('', line)).groupdict())
                line_dict = parse_line(content)
                self.lexc_lines.append((self.sorting_key(line_dict),
                                        compact_line(line_dict)))
            else:
                if line.strip():
                    self.lines.append(line)

    def sorting_key(self, line_tuple):
        """Revert the sorting key depending on sorting mode.

        Arguments:
            line_tuple (dict): dict containing the different parts of a lexc
                line.

        Returns:
            unicode
        """
        if self.mode == 'alpha':
            return line_tuple['upper']
        elif self.mode == 'revstem':
            # nopep8 https://stackoverflow.com/questions/931092/reverse-a-string-in-python
            return line_tuple['lower'][::-1] if line_tuple.get('lower') \
                else line_tuple['upper'][::-1]
        elif self.mode == 'contlex':
            return line_tuple['contlex']
        else:
            raise KeyError('No sorting mode given')

    def adjust_lines(self):
        """Sort the lines."""
        self.lines.extend([line_tuple[1]
                           for line_tuple in sorted(self.lexc_lines)])
        self.lines.append('')


def compact_line(line_dict):
    """Remove unneeded white space from a lexc entry."""
    string_buffer = []

    if line_dict.get(u'exclam'):
        string_buffer.append(line_dict[u'exclam'])

    if line_dict.get(u'upper'):
        string_buffer.append(line_dict[u'upper'])

    if line_dict.get(u'divisor'):
        string_buffer.append(line_dict[u'divisor'])

    if line_dict.get(u'lower'):
        string_buffer.append(line_dict[u'lower'])

    if string_buffer:
        string_buffer.append(' ')

    string_buffer.append(line_dict[u'contlex'])

    if line_dict.get(u'translation'):
        string_buffer.append(' ')
        string_buffer.append(line_dict[u'translation'])

    string_buffer.append(u' ;')

    if line_dict.get(u'comment'):
        string_buffer.append(u' ')
        string_buffer.append(line_dict[u'comment'])

    return ''.join(string_buffer)


def parse_line(old_match):
    """Parse a lexc line.

    Arguments:
        old_match:

    Returns:
        dict of unicode: The entries inside the lexc line expressed as
            a dict
    """
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


def align_lexicon(lexc_lines):
    """Align lexicons.

    Arguments:
    lexc_lines (list of str): contents of a lexicon to be aligned.

    Returns:
        list of str: aligned lines.
    """
    lines = LexcAligner()
    lines.parse_lines(lexc_lines)

    return lines.adjust_lines()


def sort_lexicon(lexc_lines, mode):
    """Sort lexicons.

    Arguments:
        lexc_lines (list of str): contents of a lexicon to be sorted.
        mode (str): the sorting mode applied

    Returns:
        list of str: sorted lines.
    """
    lines = LexcSorter(mode=mode)
    lines.parse_lines(lexc_lines)
    lines.adjust_lines()

    return lines.lines


def parse_options():
    """Parse command line arguments."""
    parser = argparse.ArgumentParser(
        description=u'Align or sort rules given in lexc files')
    group = parser.add_mutually_exclusive_group(required=True)
    group.add_argument(u'--align',
                       action=u'store_true',
                       help=u'Align lexicon entries')
    group.add_argument(u'--sort',
                       choices=['alpha', 'revstem', 'contlex'],
                       help=u'Sort lexicon entries')
    parser.add_argument(u'lexcfile',
                        help=u'Lexc file where lexicon entries should '
                        'be manipulated. If filename is -, then the file '
                        'is read from stdin and written to stdout.')

    arguments = parser.parse_args()

    return arguments


if __name__ == u'__main__':
    # nopep8  https://stackoverflow.com/questions/2737966/how-to-change-the-stdin-encoding-on-python
    UTF8READER = codecs.getreader('utf8')
    sys.stdin = UTF8READER(sys.stdin)
    UTF8WRITER = codecs.getwriter('utf8')
    sys.stdout = UTF8WRITER(sys.stdout)

    ARGS = parse_options()

    with io.open(ARGS.lexcfile) if ARGS.lexcfile is not "-" \
            else sys.stdin as file_:
        NEWLINES = []
        READLINES = []

        for lexc_line in file_:
            if lexc_line.startswith(u'LEXICON '):
                NEWLINES.extend(READLINES)
                READLINES = [lexc_line.rstrip()]
                break
            READLINES.append(lexc_line.rstrip())

        for lexc_line in file_:
            if lexc_line.startswith(u'LEXICON ') or lexc_line.startswith('!!'):
                if ARGS.align:
                    NEWLINES.extend(align_lexicon(READLINES))
                if ARGS.sort:
                    NEWLINES.extend(sort_lexicon(READLINES, ARGS.sort))
                READLINES = []
            READLINES.append(lexc_line.rstrip())

        if ARGS.align:
            NEWLINES.extend(align_lexicon(READLINES))
        if ARGS.sort:
            NEWLINES.extend(sort_lexicon(READLINES, ARGS.sort))

    with io.open(ARGS.lexcfile, u'w') if ARGS.lexcfile is not "-" \
            else sys.stdout as file_:
        file_.write(u'\n'.join(NEWLINES))
        file_.write(u'\n')
