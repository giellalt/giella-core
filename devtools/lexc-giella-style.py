#!/usr/bin/env python3

import unittest

class TestLines(unittest.TestCase):

    def testLongest(self):
        input = ''' +N+Sg:             N_ODD_SG       ;
 +N+Pl:             N_ODD_PL       ;
 +N:             N_ODD_ESS      ;
 +N+SgNomCmp:e%^DISIMP    R              ;
 +N+SgGenCmp:e%>%^DISIMPn R              ;
 +N+PlGenCmp:%>%^DISIMPi  R              ;
 +N+Der1+Der/Dimin+N:%»adtj       GIERIEHTSADTJE ;
   +A:%>X7 NomVadj "good A" ;
'''

        l = Lines()
        l.parseLines(input.split('\n'))

        longest = {}
        longest['upper'] = 19
        longest['lower'] = 12
        longest['contlex'] = 14
        longest['translation'] = 8

        self.assertEqual(longest, l.longest)

    def testOutputWithEmptyUpperLower(self):
        input = [' FINAL1         ;\n',
           ' +N+Sg:             N_ODD_SG       ;\n']
        expectedResult = ['        FINAL1   ;\n',
                    ' +N+Sg: N_ODD_SG ;\n']

        l = Lines()
        l.parseLines(input)

        self.assertEqual(expectedResult, l.adjustLines())

    def testOutputWithLexiconAndSemicolon(self):
        input = ['LEXICON GOAHTI-NE  !!= * __@CODE@__ Bisyll. V-Nouns; Nominative Sg. and Essive\n',
            ' NomV ;\n',
            ' EssV ;\n']

        expectedResult = ['LEXICON GOAHTI-NE  !!= * __@CODE@__ Bisyll. V-Nouns; Nominative Sg. and Essive\n',
            '   NomV ;\n',
            '   EssV ;\n']

        l = Lines()
        l.parseLines(input)
        self.assertEqual(expectedResult, l.adjustLines())

    def testOutput(self):
        input = ['LEXICON DAKTERE\n',
           ' +N+Sg:             N_ODD_SG       ;\n',
           ' +N+Pl:             N_ODD_PL       ;\n',
           ' +N:             N_ODD_ESS      ;\n',
           ' +N+SgNomCmp:e%^DISIMP    R              ;\n',
           ' +N+SgGenCmp:e%>%^DISIMPn R              ;\n',
           ' +N+PlGenCmp:%>%^DISIMPi  R              ;\n',
           ' +N+Der1+Der/Dimin+N:%»adtj       GIERIEHTSADTJE ;\n',
           '+A+Comp+Attr:%>abpa      ATTRCONT    ;  ! båajasabpa,   *båajoesabpa\n',
           '   +A:%>X7 NomVadj "good A" ;',
           '  ! Test data:\n',
           '!!€gt-norm: daktere # Odd-syllable test\n']
        l = Lines()
        l.parseLines(input)

        expectedResult = ['LEXICON DAKTERE\n',
                    '               +N+Sg:             N_ODD_SG                ;\n',
                    '               +N+Pl:             N_ODD_PL                ;\n',
                    '                  +N:             N_ODD_ESS               ;\n',
                    '         +N+SgNomCmp:e%^DISIMP    R                       ;\n',
                    '         +N+SgGenCmp:e%>%^DISIMPn R                       ;\n',
                    '         +N+PlGenCmp:%>%^DISIMPi  R                       ;\n',
                    ' +N+Der1+Der/Dimin+N:%»adtj       GIERIEHTSADTJE          ;\n',
                    '        +A+Comp+Attr:%>abpa       ATTRCONT                ; ! båajasabpa,   *båajoesabpa\n',
                    '                  +A:%>X7         NomVadj        "good A" ;\n',
                    '! Test data:\n',
                    '!!€gt-norm: daktere # Odd-syllable test\n']
        self.maxDiff = None
        print(expectedResult)
        print(l.adjustLines())
        self.assertEqual(expectedResult, l.adjustLines())

class TestLine(unittest.TestCase):

    def testLineParserUpperLower(self):
        input = '''        +N+SgNomCmp:e%^DISIMP    R              ;'''
        expectedResult = {'upper': '+N+SgNomCmp', 'lower': 'e%^DISIMP', 'contlex': 'R', 'translation': '', 'comment': ''}

        aligner = Line()
        aligner.parseLine(input)
        self.assertEqual(aligner.line, expectedResult)

    def testLineParserNoLower(self):
        input = '''               +N+Sg:             N_ODD_SG       ;'''
        expectedResult = {'upper': '+N+Sg', 'lower': '', 'contlex': 'N_ODD_SG', 'translation': '', 'comment': ''}

        aligner = Line()
        aligner.parseLine(input)
        self.assertEqual(aligner.line, expectedResult)

    def testLineParserNoUpperNoLower(self):
        input = ''' N_ODD_ESS;''';
        expectedResult = {'upper': '', 'lower': '', 'contlex': 'N_ODD_ESS', 'translation': '', 'comment': ''}

        aligner = Line()
        aligner.parseLine(input)
        self.assertEqual(aligner.line, expectedResult)

    def testLineParserEmptyUpperLower(self):
        input = ''' : N_ODD_E;''';
        expectedResult = {'upper': '', 'lower': '', 'contlex': 'N_ODD_E', 'translation': '', 'comment': ''}

        aligner = Line()
        aligner.parseLine(input)
        self.assertEqual(aligner.line, expectedResult)

    def testLineParserWithComment(self):
        input = ''' +A+Comp+Attr:%>abpa      ATTRCONT    ;  ! båajasabpa,   *båajoesabpa'''
        expectedResult = {'upper': '+A+Comp+Attr', 'lower': '%>abpa', 'contlex': 'ATTRCONT', 'translation': '', 'comment': '! båajasabpa,   *båajoesabpa'}

        aligner = Line()
        aligner.parseLine(input)
        self.assertEqual(aligner.line, expectedResult)

    def testLineParserWithComment(self):
        input = '''  +A:%>X7 NomVadj "good A" ;'''
        expectedResult = {'upper': '+A', 'lower': '%>X7', 'contlex': 'NomVadj', 'translation': '"good A"', 'comment': ''}

        aligner = Line()
        aligner.parseLine(input)
        self.assertEqual(aligner.line, expectedResult)

import re
import io
import argparse

class Lines:
    def __init__(self):
        self.longest = {}
        self.longest['upper'] = 0
        self.longest['lower'] = 0
        self.longest['contlex'] = 0
        self.longest['translation'] = 0
        self.lines = []

    def parseLines(self, lines):
        commentre = re.compile(r'^\s*!')
        for line in lines:

            commentmatch = commentre.match(line)
            if commentmatch:
                self.lines.append(commentre.sub('!', line))
                continue

            contlexre = re.compile(r'(?P<contlex>\S+)\s*;')
            contlexmatch = contlexre.search(line)
            if contlexmatch and not line.startswith('LEXICON '):
                l = Line()
                l.parseLine(line)
                self.lines.append(l)
                self.findLongest(l)
            else:
                self.lines.append(line)

    def findLongest(self, l):
        for name in ['upper', 'lower', 'translation', 'contlex']:
            if self.longest[name] < len(l.line[name]):
                self.longest[name] = len(l.line[name])

    def adjustLines(self):
        newlines = []

        for l in self.lines:
            if isinstance(l, Line):
                s = io.StringIO()

                pre = self.longest['upper'] - len(l.line['upper']) + 1
                for i in range(0, pre):
                    s.write(' ')
                s.write(l.line['upper'])

                if not (l.line['upper'] == '' and l.line['lower'] == ''):
                    s.write(':')
                else:
                    s.write(' ')

                s.write(l.line['lower'])
                post = self.longest['lower'] - len(l.line['lower']) + 1
                for i in range(0, post):
                    s.write(' ')

                s.write(l.line['contlex'])

                post = self.longest['contlex'] - len(l.line['contlex']) + 1

                for i in range(0, post):
                    s.write(' ')

                s.write(l.line['translation'])

                if self.longest['translation'] > 0:
                    post = self.longest['translation'] - len(l.line['translation']) + 1
                    for i in range(0, post):
                        s.write(' ')

                s.write (';')

                if l.line['comment'] != '':
                    s.write(' ')
                    s.write(l.line['comment'])

                s.write('\n')
                newlines.append(s.getvalue())
            else:
                newlines.append(l)

        return newlines

class Line:
    def __init__(self, upper = '', lower = '', contlex = '', translation = '', comment = ''):
        self.line = {}
        self.line['upper'] = upper
        self.line['lower'] = lower
        self.line['contlex'] = contlex
        self.line['translation'] = translation
        self.line['comment'] = comment

    def parseLine(self, line):
        contlexre = re.compile(r'(?P<contlex>\S+)(?P<translation>\s+".+")*\s*;\s*(?P<comment>.*)')
        m = contlexre.search(line)

        self.line['contlex'] = contlexre.search(line).group('contlex')
        if m.group('translation'):
            self.line['translation'] = contlexre.search(line).group('translation').strip()
        self.line['comment'] = contlexre.search(line).group('comment').strip()

        line = contlexre.sub('', line)

        m = line.find(":")

        if m != -1:
            self.line['upper'] = line[:m].strip()
            self.line['lower'] = line[m + 1:].strip()

def parse_options():
    parser = argparse.ArgumentParser(description = 'Align rules given in lexc files')
    parser.add_argument('lexcfile', help = 'lexc file where rules should be aligned')

    args = parser.parse_args()
    return args

if __name__ == '__main__':
    args = parse_options()
    f = open(args.lexcfile)

    newlines = []
    readlines = []
    for l in f.readlines():
        if l.startswith('LEXICON '):
            lines = Lines()
            lines.parseLines(readlines)
            newlines += lines.adjustLines()
            readlines = []

        readlines.append(l)

    lines = Lines()
    lines.parseLines(readlines)
    newlines += lines.adjustLines()

    f.close()

    f = open(args.lexcfile, 'w')
    f.writelines(newlines)
    f.close()
