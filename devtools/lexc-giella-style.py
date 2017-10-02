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
        self.maxDiff = None

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
        self.maxDiff = None

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
        self.maxDiff = None
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

        self.maxDiff = None
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
                string_buffer = io.StringIO()

                if self.longest[u'exclam']:
                    if line[u'exclam']:
                        string_buffer.write(line[u'exclam'])
                    else:
                        string_buffer.write(u' ')

                string_buffer.write(u' ' *
                                    (self.longest[u'upper'] -
                                     len(line[u'upper']) + 1))
                string_buffer.write(line[u'upper'])

                if line[u'divisor']:
                    string_buffer.write(line[u'divisor'])
                elif self.longest[u'divisor']:
                    string_buffer.write(u' ')

                string_buffer.write(line[u'lower'])

                string_buffer.write(u' ' *
                                    (self.longest[u'lower'] -
                                     len(line[u'lower']) + 1))

                string_buffer.write(line[u'contlex'])

                string_buffer.write(u' ' *
                                    (self.longest[u'contlex'] -
                                     len(line[u'contlex']) + 1))

                string_buffer.write(line[u'translation'])

                if self.longest[u'translation'] > 0:
                    string_buffer.write(u' ' *
                                        (self.longest[u'translation'] -
                                         len(line[u'translation']) + 1))

                string_buffer.write(u';')

                if line[u'comment'] != u'':
                    string_buffer.write(u' ')
                    string_buffer.write(line[u'comment'])

                adjusted_lines.append(string_buffer.getvalue())
            else:
                adjusted_lines.append(line)

        return adjusted_lines


class LexcSorter(object):
    """Sort entries in a lexc lexicon."""

    def __init__(self):
        """Initialise the LexcSorter class."""
        self.lines = []
        self.lexc_lines = []

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
                self.lexc_lines.append((line_dict[u'upper'], line))
            else:
                if line.strip():
                    self.lines.append(line)

    def adjust_lines(self):
        """Sort the lines."""
        adjusted_lines = []
        adjusted_lines.extend(self.lines)
        adjusted_lines.extend([line_tuple[1]
                               for line_tuple in sorted(self.lexc_lines)])
        adjusted_lines.append('')

        return adjusted_lines


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


def sort_lexicon(lexc_lines):
    """Sort lexicons.

    Arguments:
        lexc_lines (list of str): contents of a lexicon to be sorted.

    Returns:
        list of str: sorted lines.
    """
    lines = LexcSorter()
    lines.parse_lines(lexc_lines)

    return lines.adjust_lines()


def parse_options():
    """Parse command line arguments."""
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

    arguments = parser.parse_args()

    return arguments


if __name__ == u'__main__':
    UTF8READER = codecs.getreader('utf8')
    sys.stdin = UTF8READER(sys.stdin)
    UTF8WRITER = codecs.getwriter('utf8')
    sys.stdout = UTF8WRITER(sys.stdout)

    ARGS = parse_options()

    with open(ARGS.lexcfile) if ARGS.lexcfile is not "-" \
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
                    NEWLINES.extend(sort_lexicon(READLINES))
                READLINES = []
            READLINES.append(lexc_line.rstrip())

        if ARGS.align:
            NEWLINES.extend(align_lexicon(READLINES))
        if ARGS.sort:
            NEWLINES.extend(sort_lexicon(READLINES))

    with open(ARGS.lexcfile, u'w') if ARGS.lexcfile is not "-" \
            else sys.stdout as file_:
        file_.write(u'\n'.join(NEWLINES))
        file_.write(u'\n')
