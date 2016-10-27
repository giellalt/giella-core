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


from __future__ import absolute_import
import unittest
from io import open

class TestLines(unittest.TestCase):

    def testLongest(self):
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
        l.parseLines(input.split(u'\n'))

        longest = {}
        longest[u'upper'] = 19
        longest[u'lower'] = 12
        longest[u'contlex'] = 14
        longest[u'translation'] = 8

        self.assertEqual(longest, l.longest)

    def testOutputWithEmptyUpperLower(self):
        input = [u' FINAL1         ;\n',
           u' +N+Sg:             N_ODD_SG       ;\n']
        expectedResult = [u'        FINAL1   ;\n',
                    u' +N+Sg: N_ODD_SG ;\n']

        l = Lines()
        l.parseLines(input)

        self.assertEqual(expectedResult, l.adjustLines())

    def testOutputWithLexiconAndSemicolon(self):
        input = [u'LEXICON GOAHTI-NE  !!= * __@CODE@__ Bisyll. V-Nouns; Nominative Sg. and Essive\n',
            u' NomV ;\n',
            u' EssV ;\n']

        expectedResult = [u'LEXICON GOAHTI-NE  !!= * __@CODE@__ Bisyll. V-Nouns; Nominative Sg. and Essive\n',
            u'   NomV ;\n',
            u'   EssV ;\n']

        l = Lines()
        l.parseLines(input)
        self.assertEqual(expectedResult, l.adjustLines())

    def testOutput(self):
        input = [u'LEXICON DAKTERE\n',
           u' +N+Sg:             N_ODD_SG       ;\n',
           u' +N+Pl:             N_ODD_PL       ;\n',
           u' +N:             N_ODD_ESS      ;\n',
           u' +N+SgNomCmp:e%^DISIMP    R              ;\n',
           u' +N+SgGenCmp:e%>%^DISIMPn R              ;\n',
           u' +N+PlGenCmp:%>%^DISIMPi  R              ;\n',
           u' +N+Der1+Der/Dimin+N:%»adtj       GIERIEHTSADTJE ;\n',
           u'+A+Comp+Attr:%>abpa      ATTRCONT    ;  ! båajasabpa,   *båajoesabpa\n',
           u'   +A:%>X7 NomVadj "good A" ;',
           u'  ! Test data:\n',
           u'!!€gt-norm: daktere # Odd-syllable test\n']
        l = Lines()
        l.parseLines(input)

        expectedResult = [u'LEXICON DAKTERE\n',
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
        print expectedResult
        print l.adjustLines()
        self.assertEqual(expectedResult, l.adjustLines())

class TestLine(unittest.TestCase):

    def testLineParserUpperLower(self):
        input = u'''        +N+SgNomCmp:e%^DISIMP    R              ;'''
        expectedResult = {u'upper': u'+N+SgNomCmp', u'lower': u'e%^DISIMP', u'contlex': u'R', u'translation': u'', u'comment': u''}

        aligner = Line()
        aligner.parseLine(input)
        self.assertEqual(aligner.line, expectedResult)

    def testLineParserNoLower(self):
        input = u'''               +N+Sg:             N_ODD_SG       ;'''
        expectedResult = {u'upper': u'+N+Sg', u'lower': u'', u'contlex': u'N_ODD_SG', u'translation': u'', u'comment': u''}

        aligner = Line()
        aligner.parseLine(input)
        self.assertEqual(aligner.line, expectedResult)

    def testLineParserNoUpperNoLower(self):
        input = u''' N_ODD_ESS;''';
        expectedResult = {u'upper': u'', u'lower': u'', u'contlex': u'N_ODD_ESS', u'translation': u'', u'comment': u''}

        aligner = Line()
        aligner.parseLine(input)
        self.assertEqual(aligner.line, expectedResult)

    def testLineParserEmptyUpperLower(self):
        input = u''' : N_ODD_E;''';
        expectedResult = {u'upper': u'', u'lower': u'', u'contlex': u'N_ODD_E', u'translation': u'', u'comment': u''}

        aligner = Line()
        aligner.parseLine(input)
        self.assertEqual(aligner.line, expectedResult)

    def testLineParserWithComment(self):
        input = u''' +A+Comp+Attr:%>abpa      ATTRCONT    ;  ! båajasabpa,   *båajoesabpa'''
        expectedResult = {u'upper': u'+A+Comp+Attr', u'lower': u'%>abpa', u'contlex': u'ATTRCONT', u'translation': u'', u'comment': u'! båajasabpa,   *båajoesabpa'}

        aligner = Line()
        aligner.parseLine(input)
        self.assertEqual(aligner.line, expectedResult)

    def testLineParserWithComment(self):
        input = u'''  +A:%>X7 NomVadj "good A" ;'''
        expectedResult = {u'upper': u'+A', u'lower': u'%>X7', u'contlex': u'NomVadj', u'translation': u'"good A"', u'comment': u''}

        aligner = Line()
        aligner.parseLine(input)
        self.assertEqual(aligner.line, expectedResult)

import re
import io
import argparse

class Lines(object):
    def __init__(self):
        self.longest = {}
        self.longest[u'upper'] = 0
        self.longest[u'lower'] = 0
        self.longest[u'contlex'] = 0
        self.longest[u'translation'] = 0
        self.lines = []

    def parseLines(self, lines):
        commentre = re.compile(ur'^\s*!')
        for line in lines:

            commentmatch = commentre.match(line)
            if commentmatch:
                self.lines.append(commentre.sub(u'!', line))
                continue

            contlexre = re.compile(ur'(?P<contlex>\S+)\s*;')
            contlexmatch = contlexre.search(line)
            if contlexmatch and not line.startswith(u'LEXICON '):
                l = Line()
                l.parseLine(line)
                self.lines.append(l)
                self.findLongest(l)
            else:
                self.lines.append(line)

    def findLongest(self, l):
        for name in [u'upper', u'lower', u'translation', u'contlex']:
            if self.longest[name] < len(l.line[name]):
                self.longest[name] = len(l.line[name])

    def adjustLines(self):
        newlines = []

        for l in self.lines:
            if isinstance(l, Line):
                s = io.StringIO()

                pre = self.longest[u'upper'] - len(l.line[u'upper']) + 1
                for i in xrange(0, pre):
                    s.write(u' ')
                s.write(l.line[u'upper'])

                if not (l.line[u'upper'] == u'' and l.line[u'lower'] == u''):
                    s.write(u':')
                else:
                    s.write(u' ')

                s.write(l.line[u'lower'])
                post = self.longest[u'lower'] - len(l.line[u'lower']) + 1
                for i in xrange(0, post):
                    s.write(u' ')

                s.write(l.line[u'contlex'])

                post = self.longest[u'contlex'] - len(l.line[u'contlex']) + 1

                for i in xrange(0, post):
                    s.write(u' ')

                s.write(l.line[u'translation'])

                if self.longest[u'translation'] > 0:
                    post = self.longest[u'translation'] - len(l.line[u'translation']) + 1
                    for i in xrange(0, post):
                        s.write(u' ')

                s.write (u';')

                if l.line[u'comment'] != u'':
                    s.write(u' ')
                    s.write(l.line[u'comment'])

                s.write(u'\n')
                newlines.append(s.getvalue())
            else:
                newlines.append(l)

        return newlines

class Line(object):
    def __init__(self, upper = u'', lower = u'', contlex = u'', translation = u'', comment = u''):
        self.line = {}
        self.line[u'upper'] = upper
        self.line[u'lower'] = lower
        self.line[u'contlex'] = contlex
        self.line[u'translation'] = translation
        self.line[u'comment'] = comment

    def parseLine(self, line):
        contlexre = re.compile(ur'(?P<contlex>\S+)(?P<translation>\s+".+")*\s*;\s*(?P<comment>.*)')
        m = contlexre.search(line)

        self.line[u'contlex'] = contlexre.search(line).group(u'contlex')
        if m.group(u'translation'):
            self.line[u'translation'] = contlexre.search(line).group(u'translation').strip()
        self.line[u'comment'] = contlexre.search(line).group(u'comment').strip()

        line = contlexre.sub(u'', line)

        m = line.find(u":")

        if m != -1:
            self.line[u'upper'] = line[:m].strip()
            self.line[u'lower'] = line[m + 1:].strip()

def parse_options():
    parser = argparse.ArgumentParser(description = u'Align rules given in lexc files')
    parser.add_argument(u'lexcfile', help = u'lexc file where rules should be aligned')

    args = parser.parse_args()
    return args

if __name__ == u'__main__':
    UTF8Reader = codecs.getreader('utf8')
    sys.stdin = UTF8Reader(sys.stdin)
    UTF8Writer = codecs.getwriter('utf8')
    sys.stdout = UTF8Writer(sys.stdout)

    args = parse_options()

    with open(args.lexcfile) as f:
        newlines = []
        readlines = []
        for l in f.readlines():
            if l.startswith(u'LEXICON '):
                lines = Lines()
                lines.parseLines(readlines)
                newlines += lines.adjustLines()
                readlines = []

            readlines.append(l)

        lines = Lines()
        lines.parseLines(readlines)
        newlines += lines.adjustLines()

    with open(args.lexcfile, u'w') as f:
        f.writelines(newlines)
