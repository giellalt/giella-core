#!/usr/bin/env python3
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
#   Copyright © 2016-2021 The University of Tromsø &
#                         the Norwegian Sámi Parliament
#   http://giellatekno.uit.no & http://divvun.no
#   Author: Børre Gaup <borre.gaup@uit.no>
"""Script to sort and align lexc entries."""


import argparse
import re
import sys
import unittest
from collections import defaultdict

LEXC_LINE_RE = re.compile(
    r"""
    (?P<contlex>\S+)            #  any nonspace
    (?P<translation>\s+".*")?   #  optional translation, might be empty
    \s*;\s*                     #  skip space and semicolon
    (?P<comment>!.*)?           #  followed by an optional comment
    $
""",
    re.VERBOSE | re.UNICODE,
)

LEXC_CONTENT_RE = re.compile(
    r"""
    (?P<exclam>^\s*!\s*)?          #  optional comment
    (?P<content>(<.+>)|(.+))?      #  optional content
""",
    re.VERBOSE | re.UNICODE,
)


class TestLexcAligner(unittest.TestCase):
    """Test that lexc alignment works as supposed to."""

    def test_non_lexc_line(self):
        """Test how non lexc line is handled."""
        content = """
abb ; babb
"""
        expected_result = """
abb ; babb
"""
        aligner = LexcAligner()
        aligner.parse_lines(content.split("\n"))

        self.assertEqual(expected_result, "\n".join(aligner.adjust_lines()))

    def test_longest(self):
        """Check that the longest attribute is set correctly."""
        content = """
 +N+Sg:             N_ODD_SG       ;
 +N+Pl:             N_ODD_PL       ;
 +N:             N_ODD_ESS      ;
 +N+SgNomCmp:e%^DISIMP    R              ;
 +N+SgGenCmp:e%>%^DISIMPn R              ;
 +N+PlGenCmp:%>%^DISIMPi  R              ;
 +N+Der1+Der/Dimin+N:%»adtj       GIERIEHTSADTJE ;
   +A:%>X7 NomVadj "good A" ;
"""

        aligner = LexcAligner()
        aligner.parse_lines(content.split("\n"))

        longest = {}
        longest["upper"] = 19
        longest["lower"] = 12
        longest["contlex"] = 14
        longest["translation"] = 8
        longest["divisor"] = 1

        self.assertEqual(longest, aligner.longest)

    def test_only_contlex(self):
        """Test how contlex only entries are handled."""
        content = """
 FINAL1         ;
 +N+Sg:             N_ODD_SG       ;
"""
        expected_result = """
        FINAL1   ;
 +N+Sg: N_ODD_SG ;
"""

        aligner = LexcAligner()
        aligner.parse_lines(content.split("\n"))

        self.assertEqual(expected_result, "\n".join(aligner.adjust_lines()))

    def test_lexicon_contlex(self):
        """Check how lexicon and contlex only entries are handled."""
        content = """
LEXICON GOAHTI-NE  !!= * __@CODE@__ Bisyll. V-Nouns
 NomV ;
 EssV ;
"""

        expected_result = """
LEXICON GOAHTI-NE  !!= * __@CODE@__ Bisyll. V-Nouns
  NomV ;
  EssV ;
"""

        aligner = LexcAligner()
        aligner.parse_lines(content.split("\n"))
        self.assertEqual(expected_result, "\n".join(aligner.adjust_lines()))

    def test_lexicon_charientries(self):
        """Check how lexicon entries with only chars are handled."""
        content = """
LEXICON Conjunction
jïh Cc ;
jah Cc ;
"""
        expected_result = """
LEXICON Conjunction
 jïh Cc ;
 jah Cc ;
"""
        aligner = LexcAligner()
        aligner.parse_lines(content.split("\n"))
        self.assertEqual(expected_result, "\n".join(aligner.adjust_lines()))

    def test_lexicon_comment(self):
        """Check how commented lexc entries are handled."""
        content = """
LEXICON Conjunction
!dovne Cc ; ! dovne A jïh B
jïh Cc ;
jah Cc ;
"""
        expected_result = """
LEXICON Conjunction
! dovne Cc ; ! dovne A jïh B
    jïh Cc ;
    jah Cc ;
"""
        aligner = LexcAligner()
        aligner.parse_lines(content.split("\n"))
        self.assertEqual(expected_result, "\n".join(aligner.adjust_lines()))

    def test_nonalphabetic(self):
        """Test how entries starting with nonalphetic chars are handled."""
        content = """
LEXICON Cc
+CC:0 # ;
"""
        expected_result = """
LEXICON Cc
 +CC:0 # ;
"""
        aligner = LexcAligner()
        aligner.parse_lines(content.split("\n"))
        self.assertEqual(expected_result, "\n".join(aligner.adjust_lines()))

    def test_output(self):
        """Test that only lexc entries are adjusted."""
        content = """
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
"""

        expected_result = """
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
"""  # nopep8

        aligner = LexcAligner()
        aligner.parse_lines(content.split("\n"))
        self.assertEqual(expected_result, "\n".join(aligner.adjust_lines()))

    def test_less_great(self):
        """Content inside <> should be untouched, but aligned."""
        content = """
LEXICON test
+V+IV+Inf+Err/Orth-a/á:uvvát K ;
< "@P.Px.add@" 0:u 0:v 0:v "+V":a "+IV":%> "+Der4":» "+Der/NomAct":m > ContLex ;
+V+IV+Inf+Err/Orth-a/á:uvvát K ;
"""  # nopep8
        expected_result = """
LEXICON test
                                                 +V+IV+Inf+Err/Orth-a/á:uvvát K       ;
 < "@P.Px.add@" 0:u 0:v 0:v "+V":a "+IV":%> "+Der4":» "+Der/NomAct":m >       ContLex ;
                                                 +V+IV+Inf+Err/Orth-a/á:uvvát K       ;
"""  # nopep8

        aligner = LexcAligner()
        aligner.parse_lines(content.split("\n"))

        self.assertEqual(expected_result, "\n".join(aligner.adjust_lines()))

    def test_line_percent_space_ending(self):
        """Check how lower parts ending on percent are handled."""
        content = """
            abb:babb%    ContLex;
uff:puf Contlex;
"""

        expected_result = """
 abb:babb%  ContLex ;
 uff:puf    Contlex ;
"""

        aligner = LexcAligner()
        aligner.parse_lines(content.split("\n"))

        self.assertEqual(expected_result, "\n".join(aligner.adjust_lines()))

    def test_percent_space(self):
        """Check how lines containing multiple percent signs are handled."""
        content = """
LEXICON GOAHTILONGSHORT !!= * __@CODE@__ Sometimes long nom-compound-forms, long gen
 +N:%> GOAHTILONGSHORTCMP ;
 +N+Sg+Nom: K ;
< "+N":0 "+Sg":0 "+Nom":%> "@R.Nom3Px.add@" > NPx3V ;
 +N+Der+Der/viđá+Adv+Use/-PLX:»X7% viđá%  K ;
 +N+Der+Der/viđi+Adv+Use/-PLX:»X7viđi K ;
"""  # nopep8

        expected_result = """
LEXICON GOAHTILONGSHORT !!= * __@CODE@__ Sometimes long nom-compound-forms, long gen
                                            +N:%>          GOAHTILONGSHORTCMP ;
                                     +N+Sg+Nom:            K                  ;
 < "+N":0 "+Sg":0 "+Nom":%> "@R.Nom3Px.add@" >             NPx3V              ;
                  +N+Der+Der/viđá+Adv+Use/-PLX:»X7% viđá%  K                  ;
                  +N+Der+Der/viđi+Adv+Use/-PLX:»X7viđi     K                  ;
"""  # nopep8
        aligner = LexcAligner()
        aligner.parse_lines(content.split("\n"))

        self.assertEqual(expected_result, "\n".join(aligner.adjust_lines()))

    def test_line_startswith_contlex(self):
        """Check how lines with only contlex entries are handled."""
        content = """
LEXICON NounRoot
N_NEWWORDS ;
 N_sms2x ;
! N-INCOMING ;

LEXICON nouns
!! This is a temporary solution until nouns are moved to xml
N_NEWWORDS ;
"""
        expected_result = """
LEXICON NounRoot
   N_NEWWORDS ;
   N_sms2x    ;
!  N-INCOMING ;

LEXICON nouns
!! This is a temporary solution until nouns are moved to xml
   N_NEWWORDS ;
"""

        aligner = LexcAligner()
        aligner.parse_lines(content.split("\n"))

        self.assertEqual(expected_result, "\n".join(aligner.adjust_lines()))


class TestLineParser(unittest.TestCase):
    """Test how individual lines are parsed."""

    def test_line_parser_upper_lower(self):
        """Check that lines with upper and lower defined are handled."""
        line = "        +N+SgNomCmp:e%^DISIMP    R              ;"
        content = LEXC_LINE_RE.search(line).groupdict()
        content.update(LEXC_CONTENT_RE.match(LEXC_LINE_RE.sub("", line)).groupdict())
        expected_result = {
            "upper": "+N+SgNomCmp",
            "lower": "e%^DISIMP",
            "contlex": "R",
            "divisor": ":",
        }

        self.assertDictEqual(parse_line(content), expected_result)

    def test_line_parser_no_lower(self):
        """Check how lines with empty lower are handled."""
        line = "               +N+Sg:             N_ODD_SG   ;"
        content = LEXC_LINE_RE.search(line).groupdict()
        content.update(LEXC_CONTENT_RE.match(LEXC_LINE_RE.sub("", line)).groupdict())
        expected_result = {
            "upper": "+N+Sg",
            "lower": "",
            "contlex": "N_ODD_SG",
            "divisor": ":",
        }

        self.assertDictEqual(parse_line(content), expected_result)

    def test_line_contlex_only(self):
        """Check how lines without upper and lower parts are handled."""
        line = " N_ODD_ESS;"
        content = LEXC_LINE_RE.search(line).groupdict()
        content.update(LEXC_CONTENT_RE.match(LEXC_LINE_RE.sub("", line)).groupdict())
        expected_result = {
            "contlex": "N_ODD_ESS",
        }

        self.assertDictEqual(parse_line(content), expected_result)

    def test_empty_upper_lower(self):
        """Check how empty upper/lower combo is handled."""
        line = " : N_ODD_E;"
        content = LEXC_LINE_RE.search(line).groupdict()
        content.update(LEXC_CONTENT_RE.match(LEXC_LINE_RE.sub("", line)).groupdict())
        expected_result = {
            "upper": "",
            "lower": "",
            "contlex": "N_ODD_E",
            "divisor": ":",
        }

        self.assertDictEqual(parse_line(content), expected_result)

    def test_comment(self):
        """Check how commented lines are handled."""
        line = "+A+Comp+Attr:%>abpa ATTRCONT; " "! båajasabpa, *båajoesabpa"
        content = LEXC_LINE_RE.search(line).groupdict()
        content.update(LEXC_CONTENT_RE.match(LEXC_LINE_RE.sub("", line)).groupdict())
        expected_result = {
            "upper": "+A+Comp+Attr",
            "lower": "%>abpa",
            "contlex": "ATTRCONT",
            "comment": "! båajasabpa, *båajoesabpa",
            "divisor": ":",
        }

        self.assertDictEqual(parse_line(content), expected_result)

    def test_translation(self):
        """Check how lines containing translations are handled."""
        line = '  +A:%>X7 NomVadj "good A" ;'
        content = LEXC_LINE_RE.search(line).groupdict()
        content.update(LEXC_CONTENT_RE.match(LEXC_LINE_RE.sub("", line)).groupdict())
        expected_result = {
            "upper": "+A",
            "lower": "%>X7",
            "contlex": "NomVadj",
            "translation": '"good A"',
            "divisor": ":",
        }

        self.assertDictEqual(parse_line(content), expected_result)

    def test_upper_contlex(self):
        """Check how entries with only upper and contlex are handled."""
        line = "jïh Cc ;"
        content = LEXC_LINE_RE.search(line).groupdict()
        content.update(LEXC_CONTENT_RE.match(LEXC_LINE_RE.sub("", line)).groupdict())
        expected_result = {
            "upper": "jïh",
            "contlex": "Cc",
        }

        self.assertDictEqual(parse_line(content), expected_result)

    def test_leading_exclam(self):
        """Check how entries with a leading exclam are handled."""
        line = "!dovne Cc ; ! dovne A jïh B"
        content = LEXC_LINE_RE.search(line).groupdict()
        content.update(LEXC_CONTENT_RE.match(LEXC_LINE_RE.sub("", line)).groupdict())
        expected_result = {
            "comment": "! dovne A jïh B",
            "upper": "dovne",
            "contlex": "Cc",
            "exclam": "!",
        }

        self.assertDictEqual(parse_line(content), expected_result)

    def test_less_great(self):
        """Check that entries within <> are correctly handled."""
        line = (
            '< "@P.Px.add@" 0:u 0:v 0:v "+V":a "+IV":%> "+Der4":» '
            '"+Der/NomAct":m > ContLex ;'
        )
        content = LEXC_LINE_RE.search(line).groupdict()
        content.update(LEXC_CONTENT_RE.match(LEXC_LINE_RE.sub("", line)).groupdict())
        expected_result = {
            "contlex": "ContLex",
            "upper": '< "@P.Px.add@" 0:u 0:v 0:v "+V":a "+IV":%> '
            '"+Der4":» "+Der/NomAct":m >',
        }

        self.assertDictEqual(parse_line(content), expected_result)

    def test_ends_with_percent(self):
        """Check that entries containing percent are correctly handled."""
        line = "abb:babb%¥ ContLex ;"
        content = LEXC_LINE_RE.search(line).groupdict()
        content.update(LEXC_CONTENT_RE.match(LEXC_LINE_RE.sub("", line)).groupdict())
        expected_result = {
            "contlex": "ContLex",
            "upper": "abb",
            "lower": "babb% ",
            "divisor": ":",
        }

        self.assertDictEqual(parse_line(content), expected_result)

    def test_multiple_percent(self):
        """Check how entries with multiple percent signs are handled."""
        line = "+N+Der+Der/viđá+Adv+Use/-PLX:»X7%¥viđá%¥ K ;"
        content = LEXC_LINE_RE.search(line).groupdict()
        content.update(LEXC_CONTENT_RE.match(LEXC_LINE_RE.sub("", line)).groupdict())
        expected_result = {
            "contlex": "K",
            "upper": "+N+Der+Der/viđá+Adv+Use/-PLX",
            "lower": "»X7% viđá% ",
            "divisor": ":",
        }

        self.assertDictEqual(parse_line(content), expected_result)

    def test_only_contlex(self):
        """Check how contlex only lines are handled."""
        line = "N_NEWWORDS ;"
        content = LEXC_LINE_RE.search(line).groupdict()
        content.update(LEXC_CONTENT_RE.match(LEXC_LINE_RE.sub("", line)).groupdict())
        expected_result = {"contlex": "N_NEWWORDS"}

        self.assertDictEqual(parse_line(content), expected_result)

    def test_empty_translation(self):
        """Check lines with empty translation."""
        line = 'tsollegidh:tsolleg GOLTELIDH_IV "" ;'
        content = LEXC_LINE_RE.search(line).groupdict()
        content.update(LEXC_CONTENT_RE.match(LEXC_LINE_RE.sub("", line)).groupdict())
        expected_result = {
            "contlex": "GOLTELIDH_IV",
            "upper": "tsollegidh",
            "lower": "tsolleg",
            "translation": '""',
            "divisor": ":",
        }

        self.assertDictEqual(parse_line(content), expected_result)


class TestLineCompactor(unittest.TestCase):
    """Test how individual lines are compacted."""

    def test_line_parser_upper_lower(self):
        """Check that lines with upper and lower defined are handled."""
        content = {
            "upper": "+N+SgNomCmp",
            "lower": "e%^DISIMP",
            "contlex": "R",
            "divisor": ":",
        }
        expected_result = "+N+SgNomCmp:e%^DISIMP R ;"

        self.assertEqual(compact_line(content), expected_result)

    def test_line_parser_no_lower(self):
        """Check how lines with empty lower are handled."""
        content = {
            "upper": "+N+Sg",
            "lower": "",
            "contlex": "N_ODD_SG",
            "divisor": ":",
        }
        expected_result = "+N+Sg: N_ODD_SG ;"

        self.assertEqual(compact_line(content), expected_result)

    def test_line_contlex_only(self):
        """Check how lines without upper and lower parts are handled."""
        content = {
            "contlex": "N_ODD_ESS",
        }
        expected_result = "N_ODD_ESS ;"

        self.assertEqual(compact_line(content), expected_result)

    def test_empty_upper_lower(self):
        """Check how empty upper/lower combo is handled."""
        content = {
            "upper": "",
            "lower": "",
            "contlex": "N_ODD_E",
            "divisor": ":",
        }
        expected_result = ": N_ODD_E ;"

        self.assertEqual(compact_line(content), expected_result)

    def test_comment(self):
        """Check how commented lines are handled."""
        content = {
            "upper": "+A+Comp+Attr",
            "lower": "%>abpa",
            "contlex": "ATTRCONT",
            "comment": "! båajasabpa, *båajoesabpa",
            "divisor": ":",
        }
        expected_result = "+A+Comp+Attr:%>abpa ATTRCONT ; " "! båajasabpa, *båajoesabpa"

        self.assertEqual(compact_line(content), expected_result)

    def test_translation(self):
        """Check how lines containing translations are handled."""
        content = {
            "upper": "+A",
            "lower": "%>X7",
            "contlex": "NomVadj",
            "translation": '"good A"',
            "divisor": ":",
        }
        expected_result = '+A:%>X7 NomVadj "good A" ;'

        self.assertEqual(compact_line(content), expected_result)

    def test_upper_contlex(self):
        """Check how entries with only upper and contlex are handled."""
        content = {
            "upper": "jïh",
            "contlex": "Cc",
        }
        expected_result = "jïh Cc ;"

        self.assertEqual(compact_line(content), expected_result)

    def test_leading_exclam(self):
        """Check how entries with a leading exclam are handled."""
        content = {
            "comment": "! dovne A jïh B",
            "upper": "dovne",
            "contlex": "Cc",
            "exclam": "!",
        }
        expected_result = "!dovne Cc ; ! dovne A jïh B"

        self.assertEqual(compact_line(content), expected_result)

    def test_less_great(self):
        """Check that entries within <> are correctly handled."""
        content = {
            "contlex": "ContLex",
            "upper": '< "@P.Px.add@" 0:u 0:v 0:v "+V":a "+IV":%> '
            '"+Der4":» "+Der/NomAct":m >',
        }
        expected_result = (
            '< "@P.Px.add@" 0:u 0:v 0:v "+V":a "+IV":%> "+Der4":» '
            '"+Der/NomAct":m > ContLex ;'
        )

        self.assertEqual(compact_line(content), expected_result)

    def test_ends_with_percent(self):
        """Check that entries containing percent are correctly handled."""
        content = {
            "contlex": "ContLex",
            "upper": "abb",
            "lower": "babb% ",
            "divisor": ":",
        }
        expected_result = "abb:babb%  ContLex ;"

        self.assertEqual(compact_line(content), expected_result)

    def test_multiple_percent(self):
        """Check how entries with multiple percent signs are handled."""
        content = {
            "contlex": "K",
            "upper": "+N+Der+Der/vida+Adv+Use/-PLX",
            "lower": "»X7% vida% ",
            "divisor": ":",
        }
        expected_result = "+N+Der+Der/vida+Adv+Use/-PLX:»X7% vida%  K ;"

        self.assertEqual(compact_line(content), expected_result)

    def test_only_contlex(self):
        """Check how contlex only lines are handled."""
        expected_result = "N_NEWWORDS ;"
        content = {"contlex": "N_NEWWORDS"}

        self.assertEqual(compact_line(content), expected_result)


class TestSorting(unittest.TestCase):
    """Test how individual lines are parsed."""

    def setUp(self):
        """Set up common resources."""
        self.sorting_lines = [
            "aabbesegærja+N+Sem/Txt:aabbese#gærj MAANA ;",
            "faadta+N+Sem/Dummytag:faadt MAANA ;",
            "göölen-åejjie+N+Sem/Dummytag:göölen-åejj N_IE ;",
            "göölenåajjaråantjoe+N+Sem/Dummytag:göölenåajja#råantj N_OE_UML ;",
            "juveele+v1+N+Use/DNorm+Sem/Dummytag:juveel NIEJTE ;",
            "juveele+v2+N+Use/NotDNorm+Sem/Dummytag:juvel NIEJTE ;",
            "jielemes-åssjeles+N+Sem/Dummytag:jielemes-åssjeles N-TODO ;",
            "robot+N+Sem/Dummytag:robot N_ODD_C ;",
            "avteld+N+Sem/Dummytag+Cmp/SgNom:avteld R ;",
        ]

    def test_alpha(self):
        """Test sorting by lemma."""
        self.assertListEqual(
            [
                "aabbesegærja+N+Sem/Txt:aabbese#gærj MAANA ;",
                "avteld+N+Sem/Dummytag+Cmp/SgNom:avteld R ;",
                "faadta+N+Sem/Dummytag:faadt MAANA ;",
                "göölen-åejjie+N+Sem/Dummytag:göölen-åejj N_IE ;",
                "göölenåajjaråantjoe+N+Sem/Dummytag:göölenåajja#råantj N_OE_UML ;",
                "jielemes-åssjeles+N+Sem/Dummytag:jielemes-åssjeles N-TODO ;",
                "juveele+v1+N+Use/DNorm+Sem/Dummytag:juveel NIEJTE ;",
                "juveele+v2+N+Use/NotDNorm+Sem/Dummytag:juvel NIEJTE ;",
                "robot+N+Sem/Dummytag:robot N_ODD_C ;",
                "",
            ],
            sort_lexicon(self.sorting_lines, mode="alpha"),
        )

    def test_contlex(self):
        """Test sorting by continuation lexicon."""
        self.assertListEqual(
            [
                "aabbesegærja+N+Sem/Txt:aabbese#gærj MAANA ;",
                "faadta+N+Sem/Dummytag:faadt MAANA ;",
                "jielemes-åssjeles+N+Sem/Dummytag:jielemes-åssjeles N-TODO ;",
                "juveele+v1+N+Use/DNorm+Sem/Dummytag:juveel NIEJTE ;",
                "juveele+v2+N+Use/NotDNorm+Sem/Dummytag:juvel NIEJTE ;",
                "göölen-åejjie+N+Sem/Dummytag:göölen-åejj N_IE ;",
                "robot+N+Sem/Dummytag:robot N_ODD_C ;",
                "göölenåajjaråantjoe+N+Sem/Dummytag:göölenåajja#råantj N_OE_UML ;",
                "avteld+N+Sem/Dummytag+Cmp/SgNom:avteld R ;",
                "",
            ],
            sort_lexicon(self.sorting_lines, mode="contlex"),
        )

    def test_revstem(self):
        """Test sorting by reverted stem."""
        self.assertListEqual(
            [
                "avteld+N+Sem/Dummytag+Cmp/SgNom:avteld R ;",
                "göölen-åejjie+N+Sem/Dummytag:göölen-åejj N_IE ;",
                "aabbesegærja+N+Sem/Txt:aabbese#gærj MAANA ;",
                "göölenåajjaråantjoe+N+Sem/Dummytag:göölenåajja#råantj N_OE_UML ;",
                "juveele+v1+N+Use/DNorm+Sem/Dummytag:juveel NIEJTE ;",
                "juveele+v2+N+Use/NotDNorm+Sem/Dummytag:juvel NIEJTE ;",
                "jielemes-åssjeles+N+Sem/Dummytag:jielemes-åssjeles N-TODO ;",
                "faadta+N+Sem/Dummytag:faadt MAANA ;",
                "robot+N+Sem/Dummytag:robot N_ODD_C ;",
                "",
            ],
            sort_lexicon(self.sorting_lines, mode="revstem"),
        )

    def test_revlemma(self):
        """Test sorting by reverted lemma."""
        self.assertListEqual(
            [
                "aabbesegærja+N+Sem/Txt:aabbese#gærj MAANA ;",
                "faadta+N+Sem/Dummytag:faadt MAANA ;",
                "avteld+N+Sem/Dummytag+Cmp/SgNom:avteld R ;",
                "göölen-åejjie+N+Sem/Dummytag:göölen-åejj N_IE ;",
                "juveele+v1+N+Use/DNorm+Sem/Dummytag:juveel NIEJTE ;",
                "juveele+v2+N+Use/NotDNorm+Sem/Dummytag:juvel NIEJTE ;",
                "göölenåajjaråantjoe+N+Sem/Dummytag:göölenåajja#råantj N_OE_UML ;",
                "jielemes-åssjeles+N+Sem/Dummytag:jielemes-åssjeles N-TODO ;",
                "robot+N+Sem/Dummytag:robot N_ODD_C ;",
                "",
            ],
            sort_lexicon(self.sorting_lines, mode="revlemma"),
        )


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
            line = line.replace("% ", "%¥")
            lexc_line_match = LEXC_LINE_RE.search(line)
            if lexc_line_match and not line.startswith("LEXICON "):
                content = lexc_line_match.groupdict()
                content.update(
                    LEXC_CONTENT_RE.match(LEXC_LINE_RE.sub("", line)).groupdict()
                )
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

                if self.longest["exclam"]:
                    if line["exclam"]:
                        string_buffer.append(line["exclam"])
                    else:
                        string_buffer.append(" ")

                string_buffer.append(
                    " " * (self.longest["upper"] - len(line["upper"]) + 1)
                )
                string_buffer.append(line["upper"])

                if line["divisor"]:
                    string_buffer.append(line["divisor"])
                elif self.longest["divisor"]:
                    string_buffer.append(" ")

                string_buffer.append(line["lower"])

                string_buffer.append(
                    " " * (self.longest["lower"] - len(line["lower"]) + 1)
                )

                string_buffer.append(line["contlex"])

                string_buffer.append(
                    " " * (self.longest["contlex"] - len(line["contlex"]) + 1)
                )

                string_buffer.append(line["translation"])

                if self.longest["translation"] > 0:
                    string_buffer.append(
                        " "
                        * (self.longest["translation"] - len(line["translation"]) + 1)
                    )

                string_buffer.append(";")

                if line["comment"] != "":
                    string_buffer.append(" ")
                    string_buffer.append(line["comment"])

                adjusted_lines.append("".join(string_buffer))
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
            if lexc_line_match and not line.startswith("LEXICON "):
                content = lexc_line_match.groupdict()
                content.update(
                    LEXC_CONTENT_RE.match(LEXC_LINE_RE.sub("", line)).groupdict()
                )
                line_dict = parse_line(content)
                self.lexc_lines.append(
                    (self.sorting_key(line_dict), compact_line(line_dict))
                )
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
        if self.mode == "alpha":
            return line_tuple["upper"]

        if self.mode == "revlemma":
            return line_tuple["upper"].partition("+")[0][::-1]

        if self.mode == "revstem":
            # nopep8 https://stackoverflow.com/questions/931092/reverse-a-string-in-python
            return (
                line_tuple["lower"][::-1]
                if line_tuple.get("lower")
                else line_tuple["upper"][::-1]
            )

        if self.mode == "contlex":
            return line_tuple["contlex"]

        raise KeyError("No sorting mode given")

    def adjust_lines(self):
        """Sort the lines."""
        self.lines.extend([line_tuple[1] for line_tuple in sorted(self.lexc_lines)])
        self.lines.append("")


def compact_line(line_dict):
    """Remove unneeded white space from a lexc entry."""
    string_buffer = []

    if line_dict.get("exclam"):
        string_buffer.append(line_dict["exclam"])

    if line_dict.get("upper"):
        string_buffer.append(line_dict["upper"])

    if line_dict.get("divisor"):
        string_buffer.append(line_dict["divisor"])

    if line_dict.get("lower"):
        string_buffer.append(line_dict["lower"])

    if string_buffer:
        string_buffer.append(" ")

    string_buffer.append(line_dict["contlex"])

    if line_dict.get("translation"):
        string_buffer.append(" ")
        string_buffer.append(line_dict["translation"])

    string_buffer.append(" ;")

    if line_dict.get("comment"):
        string_buffer.append(" ")
        string_buffer.append(line_dict["comment"])

    return "".join(string_buffer)


def parse_line(old_match):
    """Parse a lexc line.

    Arguments:
        old_match:

    Returns:
        dict of unicode: The entries inside the lexc line expressed as
            a dict
    """
    line_dict = defaultdict(str)

    if old_match.get("exclam"):
        line_dict["exclam"] = "!"

    line_dict["contlex"] = old_match.get("contlex")
    if old_match.get("translation"):
        line_dict["translation"] = (
            old_match.get("translation").strip().replace("%¥", "% ")
        )

    if old_match.get("comment"):
        line_dict["comment"] = old_match.get("comment").strip().replace("%¥", "% ")

    line = old_match.get("content")
    if line:
        line = line.replace("%¥", "% ")
        if line.startswith("<") and line.endswith(">"):
            line_dict["upper"] = line
        else:
            lexc_line_match = line.find(":")

            if lexc_line_match != -1:
                line_dict["upper"] = line[:lexc_line_match].strip()
                line_dict["divisor"] = ":"
                line_dict["lower"] = line[lexc_line_match + 1 :].strip()
                if line_dict["lower"].endswith("%"):
                    line_dict["lower"] = line_dict["lower"] + " "
            else:
                if line.strip():
                    line_dict["upper"] = line.strip()

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
        description="Align or sort rules given in lexc files"
    )
    group = parser.add_mutually_exclusive_group(required=True)
    group.add_argument("--align", action="store_true", help="Align lexicon entries")
    group.add_argument(
        "--sort",
        choices=["alpha", "revstem", "revlemma", "contlex"],
        help="Sort lexicon entries",
    )
    parser.add_argument(
        "lexcfile",
        help="Lexc file where lexicon entries should "
        "be manipulated. If filename is -, then the file "
        "is read from stdin and written to stdout.",
    )

    arguments = parser.parse_args()

    return arguments


if __name__ == "__main__":
    ARGS = parse_options()

    with open(ARGS.lexcfile) if ARGS.lexcfile != "-" else sys.stdin as file_:
        NEWLINES = []
        READLINES = []

        for lexc_line in file_:
            if lexc_line.startswith("LEXICON "):
                NEWLINES.extend(READLINES)
                READLINES = [lexc_line.rstrip()]
                break
            READLINES.append(lexc_line.rstrip())

        for lexc_line in file_:
            if lexc_line.startswith("LEXICON ") or lexc_line.startswith("!!"):
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

    with open(ARGS.lexcfile, "w") if ARGS.lexcfile != "-" else sys.stdout as file_:
        file_.write("\n".join(NEWLINES))
        file_.write("\n")
