# -*- coding: utf-8 -*-

#
#   This file contains routines to convert files to the giellatekno xml
#   format.
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
#   Copyright 2012-2013 Børre Gaup <borre.gaup@uit.no>
#

import os
import sys
import unittest
import inspect
import doctest
import lxml.etree as etree
import lxml.doctestcompare as doctestcompare
import re
import codecs
import io
import cStringIO
import subprocess
import bs4
import HTMLParser
from pyth.plugins.rtf15.reader import Rtf15Reader
from pyth.plugins.xhtml.writer import XHTMLWriter
from copy import deepcopy
import decimal
import distutils.dep_util
import tidylib

import decode
import ngram
import errormarkup

def lineno():
    """Returns the current line number in our program."""
    return inspect.currentframe().f_back.f_lineno

class ConversionException(Exception):
    def __init__(self, value):
        self.parameter = value
    def __str__(self):
        return repr(self.parameter)

class TestConverter(unittest.TestCase):
    def setUp(self):
        self.converterInsideOrig = \
        Converter('fakecorpus/orig/nob/samediggi-article-16.html', True)

        self.converterOutsideOrig = \
        Converter('parallelize_data/samediggi-article-48.html', False)

        self.converterInsideFreecorpus = \
        Converter(os.path.join(os.getenv('GTFREE'), \
        'orig/sme/admin/sd/samediggi.no/samediggi-article-48.html'), False)

    def testGetOrig(self):
        self.assertEqual(self.converterInsideOrig.getOrig(), \
        os.path.join(os.getenv('GTHOME'),\
        'gt/script/langTools/fakecorpus/orig/nob/samediggi-article-16.html'))

        self.assertEqual(self.converterOutsideOrig.getOrig(), \
        os.path.join(os.getenv('GTHOME'), \
        'gt/script/langTools/parallelize_data/samediggi-article-48.html'))

        self.assertEqual(self.converterInsideFreecorpus.getOrig(), \
        os.path.join(os.getenv('GTFREE'), \
        'orig/sme/admin/sd/samediggi.no/samediggi-article-48.html'))

    def testGetXsl(self):
        self.assertEqual(self.converterInsideOrig.getXsl(), \
        os.path.join(os.getenv('GTHOME'),\
        'gt/script/langTools/fakecorpus/orig/nob/samediggi-article-16.html.xsl'))

        self.assertEqual(self.converterOutsideOrig.getXsl(), \
        os.path.join(os.getenv('GTHOME'), \
        'gt/script/langTools/parallelize_data/samediggi-article-48.html.xsl'))

        self.assertEqual(self.converterInsideFreecorpus.getXsl(), \
        os.path.join(os.getenv('GTFREE'), \
        'orig/sme/admin/sd/samediggi.no/samediggi-article-48.html.xsl'))

    def testGetTest(self):
        self.assertEqual(self.converterInsideOrig.getTest(), True)

        self.assertEqual(self.converterOutsideOrig.getTest(), False)

        self.assertEqual(self.converterInsideFreecorpus.getTest(), False)

    def testGetTmpdir(self):
        self.assertEqual(self.converterInsideOrig.getTmpdir(), \
            os.path.join(os.getenv('GTHOME'), \
            'gt/script/langTools/fakecorpus/tmp'))

        self.assertEqual(self.converterOutsideOrig.getTmpdir(), \
            os.path.join(os.getenv('GTHOME'), \
            'gt/script/langTools/tmp'))

        self.assertEqual(self.converterInsideFreecorpus.getTmpdir(), \
            os.path.join(os.getenv('GTFREE'), 'tmp'))

    def testGetCorpusdir(self):
        self.assertEqual(self.converterInsideOrig.getCorpusdir(), \
            os.path.join(os.getenv('GTHOME'), \
            'gt/script/langTools/fakecorpus'))

        self.assertEqual(self.converterOutsideOrig.getCorpusdir(), \
            os.path.join(os.getenv('GTHOME'), \
            'gt/script/langTools'))

        self.assertEqual(self.converterInsideFreecorpus.getCorpusdir(), \
            os.getenv('GTFREE'))

    def testGetConvertedNameInsideOrig(self):
        self.assertEqual(self.converterInsideOrig.getConvertedName(),
            os.path.join(os.getenv('GTHOME'), \
            'gt/script/langTools/fakecorpus/converted/nob/samediggi-article-16.html.xml'))

    def testGetConvertedNameOutsideOrig(self):
        self.assertEqual(self.converterOutsideOrig.getConvertedName(), \
            os.path.join(os.getenv('GTHOME'), \
            'gt/script/langTools/converted/samediggi-article-48.html.xml'))

    def testGetConvertedInsideFreecorpus(self):
        self.assertEqual(self.converterInsideFreecorpus.getConvertedName(), \
            os.path.join(os.getenv('GTFREE'), \
            'converted/sme/admin/sd/samediggi.no/samediggi-article-48.html.xml'))

class Converter:
    """
    Class to take care of data common to all Converter classes
    """
    def __init__(self, filename, test = False):
        self.orig = os.path.abspath(filename)
        self.setCorpusdir()
        self.setConvertedName()
        self.dependencies = [self.getOrig(), self.getXsl()]
        self.test = test
        self.fixLangGenreXsl()

    def makeIntermediate(self):
        """Convert the input file from the original format to a basic
        giellatekno xml document
        """
        if 'Avvir' in self.orig:
            intermediate = AvvirConverter(self.orig)

        elif self.orig.endswith('.txt'):
            intermediate = PlaintextConverter(self.orig)

        elif self.orig.endswith('.pdf'):
            intermediate = PDFConverter(self.orig)

        elif self.orig.endswith('.svg'):
            intermediate = SVGConverter(self.orig)

        elif '.htm' in self.orig or '.php' in self.orig:
            intermediate = HTMLConverter(self.orig)

        elif '.doc' in self.orig or '.DOC' in self.orig:
            intermediate = DocConverter(self.orig)

        elif '.rtf' in self.orig:
            intermediate = RTFConverter(self.orig)

        elif self.orig.endswith('.bible.xml'):
            intermediate = BiblexmlConverter(self.orig)

        else:
            raise ConversionException("Not able to convert " + self.orig)

        document = intermediate.convert2intermediate()

        if isinstance(document, etree._XSLTResultTree):
            document = etree.fromstring(etree.tostring(document))

        return document

    def makeComplete(self):
        """Combine the intermediate giellatekno xml file and the metadata into
        a complete giellatekno xml file.
        Fix the character encoding
        Detect the languages in the xml file
        """
        xm = XslMaker(self.getXsl())
        xsltRoot = xm.getXsl()
        try:
            transform = etree.XSLT(xsltRoot)
        except etree.XSLTParseError as (e):
            logfile = open(self.orig + '.log', 'w')

            for entry in e.error_log:
                logfile.write(str(entry))
                logfile.write('\n')

            logfile.close()
            raise ConversionException("Invalid XML in " + self.getXsl())

        intermediate = self.makeIntermediate()

        try:
            complete = transform(intermediate)
        except etree.XSLTApplyError as (e):
            logfile = open(self.orig + '.log', 'w')

            for entry in e.error_log:
                logfile.write(str(entry))
                logfile.write('\n')

            logfile.close()
            raise ConversionException("Check the syntax in: " + self.getXsl())

        dtd = etree.DTD(os.path.join(os.getenv('GTHOME'), 'gt/dtd/corpus.dtd'))

        if not dtd.validate(complete):
            #print etree.tostring(complete)
            logfile = open(self.getOrig() + '.log', 'w')

            for entry in dtd.error_log:
                logfile.write('\n')
                logfile.write(str(entry))
                logfile.write('\n')

            logfile.write(etree.tostring(complete, encoding = 'utf8', pretty_print = 'True'))
            logfile.close()

            raise ConversionException("Not valid XML. More info in the log file: " + self.getOrig() + u".log")

        if 'correct.' in self.orig:
            try:
                em = errormarkup.ErrorMarkup(self.getOrig())

                for element in complete.find('body'):
                    em.addErrorMarkup(element)
            except IndexError as e:
                logfile = open(self.getOrig() + '.log', 'w')
                logfile.write("There is a markup error\n")
                logfile.write("The error message: ")
                logfile.write(str(e))
                logfile.write("\n\n")
                logfile.write("This is the xml tree:\n")
                logfile.write(etree.tostring(complete, encoding = 'utf8', pretty_print = 'True'))
                logfile.write('\n')
                logfile.close()
                raise ConversionException(u"Markup error. More info in the log file: " + self.getOrig() + u".log")

        if complete.getroot().attrib['{http://www.w3.org/XML/1998/namespace}lang'] in ['sma', 'sme']:
            ef = DocumentFixer(etree.fromstring(etree.tostring(complete)))
            complete = ef.fixBodyEncoding()

        ld = LanguageDetector(complete)
        ld.detectLanguage()

        return complete

    def writeComplete(self):
        if distutils.dep_util.newer_group(self.dependencies, self.getConvertedName()):
            self.makedirs()

            if ('goldstandard' in self.orig and '.correct.' in self.orig) \
            or 'goldstandard' not in self.orig:
                complete = self.makeComplete()

                converted = open(self.getConvertedName(), 'w')
                converted.write(etree.tostring(complete, encoding = 'utf8', pretty_print = 'True'))
                converted.close()

    def makedirs(self):
        """Make the converted directory
        """
        try:
            os.makedirs(os.path.dirname(self.getConvertedName()))
        except OSError:
            pass

    def getOrig(self):
        return self.orig

    def getXsl(self):
        return self.orig + '.xsl'

    def getTest(self):
        return self.test

    def getTmpdir(self):
        return os.path.join(self.getCorpusdir(), 'tmp')

    def getCorpusdir(self):
        return self.corpusdir

    def setCorpusdir(self):
        origPos = self.orig.find('orig/')
        if origPos != -1:
            self.corpusdir = os.path.dirname(self.orig[:origPos])
        else:
            self.corpusdir = os.getcwd()

    def fixLangGenreXsl(self):
        """Set the mainlang and genre variables in the xsl file, if possible
        """
        try:
            xsltree = etree.parse(self.getXsl())

            root = xsltree.getroot()
            origname = self.getOrig().replace(self.getCorpusdir(), '')
            if origname.startswith('/orig'):
                parts = origname[1:].split('/')

                lang = root.find("{http://www.w3.org/1999/XSL/Transform}variable[@name='mainlang']").attrib['select'].replace("'", "")

                if lang == "":
                    lang = parts[1]
                    root.find("{http://www.w3.org/1999/XSL/Transform}variable[@name='mainlang']").attrib['select'] = "'" + lang + "'"

                genre = root.find("{http://www.w3.org/1999/XSL/Transform}variable[@name='genre']").attrib['select'].replace("'", "")

                if genre == "" or genre not in ['admin', 'bible', 'facta', 'ficti', 'news']:
                    if parts[2] in ['admin', 'bible', 'facta', 'ficti', 'news']:
                        genre = parts[parts.index('orig') + 2]
                        root.find("{http://www.w3.org/1999/XSL/Transform}variable[@name='genre']").attrib['select'] = "'" + genre + "'"

                xsltree.write(self.getXsl(), encoding="utf-8", xml_declaration = True)
        except etree.XMLSyntaxError as e:
            logfile = open(self.orig + '.log', 'w')

            for entry in e.error_log:
                logfile.write('\n')
                logfile.write(str(entry.line))
                logfile.write(':')
                logfile.write(str(entry.column))
                logfile.write(" ")

                try:
                    logfile.write(entry.message)
                except ValueError:
                    logfile.write(entry.message.encode('latin1'))

                logfile.write('\n')

    def setConvertedName(self):
        """Set the name of the converted file
        """
        convertedBasename = os.path.join(self.getCorpusdir(), 'converted')
        origname = self.getOrig().replace(self.getCorpusdir(), '')
        if origname.startswith('/'):
            origname = origname[1:]
        if origname.startswith('orig/'):
            origname = origname.replace('orig/', '')
        else:
            origname = os.path.basename(origname)

        self._convertedName = os.path.join(convertedBasename, origname) + '.xml'

    def getConvertedName(self):
        return self._convertedName

class TestAvvirConverter(unittest.TestCase):
    def setUp(self):
        self.avvir = AvvirConverter('fakecorpus/orig/sme/news/Avvir_xml-filer/Avvir_2008_xml-filer/02nr028av.article.xml')

    def assertXmlEqual(self, got, want):
        """Check if two stringified xml snippets are equal
        """
        checker = doctestcompare.LXMLOutputChecker()
        if not checker.check_output(want, got, 0):
            message = checker.output_difference(doctest.Example("", want), got, 0).encode('utf-8')
            raise AssertionError(message)

    def testConvert2intermediate(self):
        got = self.avvir.convert2intermediate()
        want = etree.parse('parallelize_data/gt-02nr028av.article.xml')

        self.assertXmlEqual(etree.tostring(got), etree.tostring(want))

class AvvirConverter:
    """
    Class to convert Ávvir xml files to the giellatekno xml format
    """

    def __init__(self, filename):
        self.orig = filename
        self.converterXsl = \
        os.path.join(os.getenv('GTHOME'), 'gt/script/corpus/avvir2corpus.xsl')

    def convert2intermediate(self):
        """
        Convert the original document to the giellatekno xml format, with no
        metadata
        The resulting xml is stored in intermediate
        """
        avvirXsltRoot = etree.parse(self.converterXsl)
        transform = etree.XSLT(avvirXsltRoot)
        doc = etree.parse(self.orig)
        intermediate = transform(doc)

        return intermediate

class TestSVGConverter(unittest.TestCase):
    def setUp(self):
        self.svg = SVGConverter('parallelize_data/Riddu_Riddu_avis_TXT.200923.svg')

    def assertXmlEqual(self, got, want):
        """Check if two stringified xml snippets are equal
        """
        checker = doctestcompare.LXMLOutputChecker()
        if not checker.check_output(want, got, 0):
            message = checker.output_difference(doctest.Example("", want), got, 0).encode('utf-8')
            raise AssertionError(message)

    def testConvert2intermediate(self):
        got = self.svg.convert2intermediate()
        want = etree.parse('parallelize_data/Riddu_Riddu_avis_TXT.200923.svg.xml')

        self.assertXmlEqual(etree.tostring(got), etree.tostring(want))

class SVGConverter:
    """
    Class to convert SVG files to the giellatekno xml format
    """

    def __init__(self, filename):
        self.orig = filename
        self.converterXsl = \
        os.path.join(os.getenv('GTHOME'), 'gt/script/corpus/svg2corpus.xsl')

    def convert2intermediate(self):
        """
        Convert the original document to the giellatekno xml format, with no
        metadata
        The resulting xml is stored in intermediate
        """
        svgXsltRoot = etree.parse(self.converterXsl)
        transform = etree.XSLT(svgXsltRoot)
        doc = etree.parse(self.orig)
        intermediate = transform(doc)

        return intermediate

class TestPlaintextConverter(unittest.TestCase):
    def assertXmlEqual(self, got, want):
        """Check if two stringified xml snippets are equal
        """
        checker = doctestcompare.LXMLOutputChecker()
        if not checker.check_output(want, got, 0):
            message = checker.output_difference(doctest.Example("", want), got, 0).encode('utf-8')
            raise AssertionError(message)

    def testToUnicode(self):
        converter = PlaintextConverter('parallelize_data/winsami2-test-ws2.txt')
        got  = converter.toUnicode()

        # Ensure that the data in want is unicode
        f = codecs.open('parallelize_data/winsami2-test-utf8.txt', encoding = 'utf8')
        want = f.read()
        f.close()

        self.assertEqual(got, want)

    def testPlaintext(self):
        plaintext = PlaintextConverter('parallelize_data/plaintext.txt')
        got = plaintext.convert2intermediate()
        want = etree.parse('parallelize_data/plaintext.xml')

        self.assertXmlEqual(etree.tostring(got), etree.tostring(want))

    def testNewstext(self):
        newstext = PlaintextConverter('parallelize_data/newstext.txt')
        got = newstext.convert2intermediate()
        want = etree.parse('parallelize_data/newstext.xml')

        self.assertXmlEqual(etree.tostring(got), etree.tostring(want))

    def testAssu97(self):
        newstext = PlaintextConverter('parallelize_data/assu97.txt')
        got = newstext.convert2intermediate()
        want = etree.parse('parallelize_data/assu97-unfixedutf8.xml')

        self.assertXmlEqual(etree.tostring(got), etree.tostring(want))

    def testBilde(self):
        newstext = PlaintextConverter('parallelize_data/bilde.txt')
        got = newstext.convert2intermediate()
        want = etree.parse('parallelize_data/bilde.xml')

        self.assertXmlEqual(etree.tostring(got), etree.tostring(want))

    def testIngress(self):
        newstext = PlaintextConverter('parallelize_data/ingress.txt')
        got = newstext.convert2intermediate()
        want = etree.parse('parallelize_data/ingress.xml')

        self.assertXmlEqual(etree.tostring(got), etree.tostring(want))

    def testMtitt(self):
        newstext = PlaintextConverter('parallelize_data/mtitt.txt')
        got = newstext.convert2intermediate()
        want = etree.parse('parallelize_data/mtitt.xml')

        self.assertXmlEqual(etree.tostring(got), etree.tostring(want))

    def testTekst(self):
        newstext = PlaintextConverter('parallelize_data/tekst.txt')
        got = newstext.convert2intermediate()
        want = etree.parse('parallelize_data/tekst.xml')

        self.assertXmlEqual(etree.tostring(got), etree.tostring(want))

    def testNBSP(self):
        newstext = PlaintextConverter('parallelize_data/nbsp.txt')
        got = newstext.convert2intermediate()
        want = etree.parse('parallelize_data/nbsp.xml')

        self.assertXmlEqual(etree.tostring(got), etree.tostring(want))

    def testTittel(self):
        newstext = PlaintextConverter('parallelize_data/tittel.txt')
        got = newstext.convert2intermediate()
        want = etree.parse('parallelize_data/tittel.xml')

        self.assertXmlEqual(etree.tostring(got), etree.tostring(want))

    def testByline(self):
        newstext = PlaintextConverter('parallelize_data/byline.txt')
        got = newstext.convert2intermediate()
        want = etree.parse('parallelize_data/byline.xml')

        self.assertXmlEqual(etree.tostring(got), etree.tostring(want))

    def testStikktitt(self):
        newstext = PlaintextConverter('parallelize_data/stikktitt.txt')
        got = newstext.convert2intermediate()
        want = etree.parse('parallelize_data/stikktitt.xml')

        self.assertXmlEqual(etree.tostring(got), etree.tostring(want))

    def testUtitt(self):
        newstext = PlaintextConverter('parallelize_data/utitt.txt')
        got = newstext.convert2intermediate()
        want = etree.parse('parallelize_data/utitt.xml')

        self.assertXmlEqual(etree.tostring(got), etree.tostring(want))

    def testUdotTitt(self):
        newstext = PlaintextConverter('parallelize_data/udottitt.txt')
        got = newstext.convert2intermediate()
        want = etree.parse('parallelize_data/udottitt.xml')

        self.assertXmlEqual(etree.tostring(got), etree.tostring(want))

    def testUndertitt(self):
        newstext = PlaintextConverter('parallelize_data/undertitt.txt')
        got = newstext.convert2intermediate()
        want = etree.parse('parallelize_data/undertitt.xml')

        self.assertXmlEqual(etree.tostring(got), etree.tostring(want))

    def testTtitt(self):
        newstext = PlaintextConverter('parallelize_data/ttitt.txt')
        got = newstext.convert2intermediate()
        want = etree.parse('parallelize_data/ttitt.xml')

        self.assertXmlEqual(etree.tostring(got), etree.tostring(want))

    def testTitt(self):
        newstext = PlaintextConverter('parallelize_data/titt.txt')
        got = newstext.convert2intermediate()
        want = etree.parse('parallelize_data/titt.xml')

        self.assertXmlEqual(etree.tostring(got), etree.tostring(want))

    def testTtt(self):
        newstext = PlaintextConverter('parallelize_data/ttt.txt')
        got = newstext.convert2intermediate()
        want = etree.parse('parallelize_data/ttt.xml')

        self.assertXmlEqual(etree.tostring(got), etree.tostring(want))

    def testTit(self):
        newstext = PlaintextConverter('parallelize_data/tit.txt')
        got = newstext.convert2intermediate()
        want = etree.parse('parallelize_data/tit.xml')

        self.assertXmlEqual(etree.tostring(got), etree.tostring(want))

    def testTwoLines(self):
        twoLines = PlaintextConverter('parallelize_data/twolines.txt')
        got = twoLines.convert2intermediate()
        want = etree.parse('parallelize_data/twolines.xml')

        self.assertXmlEqual(etree.tostring(got), etree.tostring(want))

    def testHyph(self):
        twoLines = PlaintextConverter('parallelize_data/hyph.txt')
        got = twoLines.convert2intermediate()
        want = etree.parse('parallelize_data/hyph.xml')

        self.assertXmlEqual(etree.tostring(got), etree.tostring(want))

class PlaintextConverter:
    """
    A class to convert plain text files containing "news" tags to the
    giellatekno xml format
    """

    def __init__(self, filename):
        self.orig = filename

    def toUnicode(self):
        """
        Read a file into a unicode string.
        If the content of the file is not utf-8, pretend the encoding is
        latin1. The real encoding (for sma, sme and smj) will be detected
        later.

        Return a unicode string
        """
        try:
            content = codecs.open(self.orig, encoding = 'utf8').read()
        except:
            content = codecs.open(self.orig, encoding = 'latin1').read()

        content = content.replace(u'ÊÊ', '\n\n')
        content = content.replace(u'<\!q>', u' ')
        content = content.replace('\x0d', '\x0a')
        content = content.replace('<*B>', '')
        content = content.replace('<*P>', '')
        content = content.replace('<*I>', '')
        content = self.strip_chars(content)

        return content

    def strip_chars(self, content, extra=u''):
        remove_re = re.compile(u'[\x00-\x08\x0B-\x0C\x0E-\x1F\x7F%s]'
                            % extra)
        stripped = 0
        content, count = remove_re.subn('', content)
        if count > 0:
            plur = ((count > 1) and u's') or u''
            #sys.stderr.write('Removed %s character%s.\n'
                            #% (count, plur))

        return content

    def makeElement(self, eName, text, attributes = {}):
        """
        @brief Makes an xml element containing the given name, text and attributes. Adds a hyph element if necessary.

        :param eName: Name of the xml element
        :type el: string

        :param text: The text the xml should contain
        :type text: string

        :param attributes: The attributes the element should have
        :type attributes: dict

        :returns: lxml.etree.Element
        """
        el = etree.Element(eName)
        for key in attributes:
            el.set(key, attributes[key])

        hyphParts = text.split('<hyph/>')
        if len(hyphParts) > 1:
            el.text = hyphParts[0]
            for hyphPart in hyphParts[1:]:
                h = etree.Element('hyph')
                h.tail = hyphPart
                el.append(h)
        else:
            el.text = text

        return el

    def convert2intermediate(self):
        document = etree.Element('document')

        content = io.StringIO(self.toUnicode())
        header = etree.Element('header')
        body = etree.Element('body')
        ptext = ''

        newstags = re.compile(r'(@*logo:|@*ingres+:|.*@*bilde(\s\d)*:|(@|LED)*tekst:|@*stikk:|@foto:|@fotobyline:|@bildetitt:)', re.IGNORECASE)
        titletags = re.compile(r'@m.titt:@ingress:|Mellomtittel:|@*(stikk|under)titt:|@ttt:|@*[utm]*[:\.]*tit+:', re.IGNORECASE)
        headertitletags = re.compile(r'@tittel:|@titt:|TITT:|Tittel:|@LEDtitt:')

        for line in content:
            if newstags.match(line):
                line = newstags.sub('', line).strip()
                body.append(self.makeElement('p', line))
                ptext = ''
            elif line.startswith('@bold:'):
                line = line.replace('@bold:', '').strip()
                p = etree.Element('p')
                p.append(self.makeElement('em', line, {'type': 'bold'}))
                body.append(p)
                ptext = ''
            elif line.startswith('@kursiv:'):
                line = line.replace('@kursiv:', '').strip()
                p = etree.Element('p')
                p.append(self.makeElement('em', line, {'type': 'italic'}))
                body.append(p)
                ptext = ''
            elif line.startswith(u'  '):
                body.append(self.makeElement('p', line.strip()))
                ptext = ''
            elif headertitletags.match(line):
                line = headertitletags.sub('', line).strip()
                if header.find("title") is None:
                    title = etree.Element('title')
                    header.append(self.makeElement('title', line))
                else:
                    body.append(self.makeElement('p', line, {'type': 'title'}))
                ptext = ''
            elif titletags.match(line):
                line = titletags.sub('', line).strip()
                body.append(self.makeElement('p', line, {'type': 'title'}))
                ptext = ''
            elif line.startswith('@byline:') or line.startswith('Byline:'):
                person = etree.Element('person')

                line = line.replace('@byline:', '').strip()
                line = line.replace('Byline:', '').strip()
                names = line.strip().split(' ')
                person.set('lastname', names[-1])
                person.set('firstname', ' '.join(names[:-1]))

                author = etree.Element('author')
                author.append(person)
                header.append(author)
                ptext = ''
            elif line == '\n' and ptext != '':
                if ptext.strip() != '':
                    try:
                        body.append(self.makeElement('p', ptext.strip()))
                        ptext = ''
                    except ValueError:
                        raise ConversionException("Invalid utf8 «" + ptext.strip().encode('utf-8') + "»")

                ptext = ''
            else:
                ptext = ptext + line.replace('\n', ' ')

        if ptext != '':
            body.append(self.makeElement('p', ptext.strip()))

        document.append(header)
        document.append(body)

        return document

#from pdfminer.pdfparser import PDFDocument, PDFParser
#from pdfminer.pdfinterp import PDFResourceManager, PDFPageInterpreter, process_pdf
#from pdfminer.pdfdevice import PDFDevice, TagExtractor
#from pdfminer.converter import TextConverter
#from pdfminer.cmapdb import CMapDB
#from pdfminer.layout import LAParams

class TestPDFConverter(unittest.TestCase):
    def assertXmlEqual(self, got, want):
        """Check if two stringified xml snippets are equal
        """
        checker = doctestcompare.LXMLOutputChecker()
        if not checker.check_output(want, got, 0):
            message = checker.output_difference(doctest.Example("", want), got, 0).encode('utf-8')
            raise AssertionError(message)

    def testPDFConverter(self):
        pdfdocument = PDFConverter('parallelize_data/pdf-test.pdf')
        got = pdfdocument.convert2intermediate()
        want = etree.parse('parallelize_data/pdf-test.xml')

        self.assertXmlEqual(etree.tostring(got), etree.tostring(want))

class PDFConverter:
    def __init__(self, filename):
        self.orig = filename

    def replaceLigatures(self):
        """
        document is a stringified xml document
        """
        replacements = {
            u"[dstrok]": u"đ",
            u"[Dstrok]": u"Đ",
            u"[tstrok]": u"ŧ",
            u"[Tstrok]": u"Ŧ",
            u"[scaron]": u"š",
            u"[Scaron]": u"Š",
            u"[zcaron]": u"ž",
            u"[Zcaron]": u"Ž",
            u"[ccaron]": u"č",
            u"[Ccaron]": u"Č",
            u"[eng": u"ŋ",
            " ]": "",
            u"Ď": u"đ", # cough
            u"ď": u"đ", # cough
            u"ﬁ": "fi",
            u"ﬂ": "fl",
            u"ﬀ": "ff",
            u"ﬃ": "ffi",
            u"ﬄ": "ffl",
            u"ﬅ": "ft",
        }

        for key, value in replacements.items():
            #print '583', key, value
            self.text = self.text.replace(key + ' ', value)
            self.text = self.text.replace(key, value)

    def extractText(self):
        """
        Extract the text from the pdf file using pdftotext
        output contains string from the program and is a utf-8 string
        """
        subp = subprocess.Popen(['pdftotext', '-enc', 'UTF-8', '-nopgbrk', '-eol', 'unix', self.orig, '-'], stdout = subprocess.PIPE, stderr = subprocess.PIPE)
        (output, error) = subp.communicate()

        if subp.returncode != 0:
            logfile = open(self.orig + '.log', 'w')
            logfile.write('stdout\n')
            logfile.write(output)
            logfile.write('\n')
            logfile.write('stderr\n')
            logfile.write(error)
            logfile.write('\n')
            logfile.close()
            raise ConversionException("Could not extract text from pdf. More info in the log file: " + self.filename + u".log")

        self.text = unicode(output, encoding='utf8')
        self.replaceLigatures()
        return self.strip_chars(self.text)

    def strip_chars(self, content, extra=u''):
        remove_re = re.compile(u'[\x00-\x08\x0B-\x0C\x0E-\x1F\x7F%s]'
                            % extra)
        stripped = 0
        content, count = remove_re.subn('', content)
        if count > 0:
            plur = ((count > 1) and u's') or u''
            #sys.stderr.write('Removed %s character%s.\n'
                            #% (count, plur))

        return content

    #def extractText1(self):
        ## debug option
        #debug = 0
        ## input option
        #pagenos = set()
        #maxpages = 0
        ## output option
        #codec = 'utf-8'
        #caching = True
        #laparams = LAParams()

        #PDFDocument.debug = debug
        #PDFParser.debug = debug
        #CMapDB.debug = debug
        #PDFResourceManager.debug = debug
        #PDFPageInterpreter.debug = debug
        #PDFDevice.debug = debug
        ##
        #rsrcmgr = PDFResourceManager(caching=caching)

        #outfp = cStringIO.StringIO()

        #device = TextConverter(rsrcmgr, outfp, codec=codec, laparams=laparams)

        #fp = file(self.orig, 'rb')
        #process_pdf(rsrcmgr, device, fp, pagenos, maxpages=maxpages,
                    #caching=caching, check_extractable=True)
        #fp.close()

        #device.close()
        #self.text = unicode(outfp.getvalue(), encoding='utf8')
        #self.replaceLigatures()
        #outfp.close()

        #return self.text

    def convert2intermediate(self):
        document = etree.Element('document')
        header = etree.Element('header')
        body = etree.Element('body')

        content = io.StringIO(self.extractText())
        ptext = ''

        for line in content:
            if line == '\n':
                p = etree.Element('p')
                p.text = ptext
                body.append(p)
                ptext = ''
            else:
                ptext = ptext + line

        if ptext != '':
            p = etree.Element('p')
            p.text = ptext.replace('\x0c', '')
            body.append(p)

        document.append(header)
        document.append(body)

        return document

class TestDocConverter(unittest.TestCase):
    def setUp(self):
        self.testdoc = DocConverter('parallelize_data/doc-test.doc')

    def assertXmlEqual(self, got, want):
        """Check if two stringified xml snippets are equal
        """
        checker = doctestcompare.LXMLOutputChecker()
        if not checker.check_output(want, got, 0):
            message = checker.output_difference(doctest.Example("", want), got, 0).encode('utf-8')
            raise AssertionError(message)

    def testConvert2intermediate(self):
        got = self.testdoc.convert2intermediate()
        want = etree.parse('parallelize_data/doc-test.xml')

        self.assertXmlEqual(etree.tostring(got), etree.tostring(want))

class DocConverter:
    """
    Class to convert Microsoft Word documents to the giellatekno xml format
    """
    def __init__(self, filename):
        self.orig = filename
        self.converterXsl = \
        os.path.join(os.getenv('GTHOME'), 'gt/script/corpus/docbook2corpus2.xsl')

    def extractText(self):
        """
        Extract the text from the doc file using antiword
        output contains the docbook xml output by antiword,
        and is a utf-8 string
        """
        subp = subprocess.Popen(['antiword', '-x', 'db', self.orig], stdout = subprocess.PIPE, stderr = subprocess.PIPE)
        (output, error) = subp.communicate()

        if subp.returncode != 0:
            print >>sys.stderr, 'Could not process', self.orig
            print >>sys.stderr, output
            print >>sys.stderr, error
            return subp.returncode

        return output

    def convert2intermediate(self):
        """
        Convert the original document to the giellatekno xml format, with no
        metadata
        The resulting xml is stored in intermediate
        """
        docbookXsltRoot = etree.parse(self.converterXsl)
        transform = etree.XSLT(docbookXsltRoot)
        doc = etree.fromstring(self.extractText())
        intermediate = transform(doc)

        return intermediate

class TestBiblexmlConverter(unittest.TestCase):
    def setUp(self):
        self.testdoc = BiblexmlConverter('parallelize_data/bible-test.xml')

    def assertXmlEqual(self, got, want):
        """Check if two stringified xml snippets are equal
        """
        checker = doctestcompare.LXMLOutputChecker()
        if not checker.check_output(want, got, 0):
            message = checker.output_difference(doctest.Example("", want), got, 0).encode('utf-8')
            raise AssertionError(message)

    def testConvert2intermediate(self):
        got = self.testdoc.convert2intermediate()
        want = etree.parse('parallelize_data/bible-test.xml.xml')

        self.assertXmlEqual(etree.tostring(got), etree.tostring(want))

class BiblexmlConverter:
    """
    Class to convert bible xml files to the giellatekno xml format
    """
    def __init__(self, filename):
        self.orig = filename

    def convert2intermediate(self):
        """
        Convert the bible xml to giellatekno xml format using bible2xml.pl
        """
        subp = subprocess.Popen(['bible2xml.pl', '-out', 'kluff.xml', self.orig], stdout = subprocess.PIPE, stderr = subprocess.PIPE)
        (output, error) = subp.communicate()

        if subp.returncode != 0:
            print >>sys.stderr, 'Could not process', self.orig
            print >>sys.stderr, output
            print >>sys.stderr, error
            return subp.returncode

        return etree.parse('kluff.xml')

class TestHTMLConverter(unittest.TestCase):
    def setUp(self):
        self.testhtml = HTMLConverter('parallelize_data/samediggi-article-48s.html')

    def assertXmlEqual(self, got, want):
        """Check if two stringified xml snippets are equal
        """
        checker = doctestcompare.LXMLOutputChecker()
        if not checker.check_output(want, got, 0):
            message = checker.output_difference(doctest.Example("", want), got, 0).encode('utf-8')
            raise AssertionError(message)

    def testConvert2intermediate(self):
        got = self.testhtml.convert2intermediate()
        want = etree.parse('parallelize_data/samediggi-article-48s.xml')

        self.assertXmlEqual(etree.tostring(got), etree.tostring(want))

class TestHTMLContentConverter(unittest.TestCase):
    def assertXmlEqual(self, got, want):
        """Check if two stringified xml snippets are equal
        """
        checker = doctestcompare.LXMLOutputChecker()
        if not checker.check_output(want, got, 0):
            message = checker.output_difference(doctest.Example("", want), got, 0).encode('utf-8')
            raise AssertionError(message)

    def testRemoveOp(self):
        got = HTMLContentConverter('with-o:p.html', '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd"><html xmlns="http://www.w3.org/1999/xhtml" xml:lang="nn" lang="nn"><head><title>Avdeling for havbruk, sj&#248;mat og marknad - regjeringen.no</title></head><body onload="javascript:Operatest();"><o:p><font face="Times New Roman" size="3">&nbsp;</font></o:p></body></html>').tidy()

        want = '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd"><html xmlns="http://www.w3.org/1999/xhtml" xml:lang="nn" lang="nn"><head><title>Avdeling for havbruk, sj&#248;mat og marknad - regjeringen.no</title></head><body onload="javascript:Operatest();"></body></html>'

        self.assertXmlEqual(got, want)

    def testRemoveFblike(self):
        got = HTMLContentConverter('with-fb:like.html', '<html xmlns="http://www.w3.org/1999/xhtml"><body><fb:like send="true" show_faces="false" action="recommend"></fb:like></body></html>').tidy()

        want = '<html xmlns="http://www.w3.org/1999/xhtml"><head><title/></head><body></body></html>'

        self.assertXmlEqual(got, want)

    def testRemoveFbcomments(self):
        got = HTMLContentConverter('with-fb:comments.html', '<html xmlns="http://www.w3.org/1999/xhtml"><body><fb:comments href="http://www.nord-salten.no/no/nyheter/samisk/hellmocuhppa.4032" num_posts="2" width="750"></fb:comments></body></html>').tidy()

        want = '<html xmlns="http://www.w3.org/1999/xhtml"><head><title/></head><body></body></html>'

        self.assertXmlEqual(got, want)

    def testRemoveGplusone(self):
        got = HTMLContentConverter('with-g:plusone.html', '<html xmlns="http://www.w3.org/1999/xhtml"><body><g:plusone size="standard" count="true"></g:plusone></body></html>').tidy()

        want = '<html xmlns="http://www.w3.org/1999/xhtml"><head><title/></head><body></body></html>'

        self.assertXmlEqual(got, want)

    def testRemoveSt1CountryRegion(self):
        got = HTMLContentConverter('with-o:p.html', '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd"><html xmlns="http://www.w3.org/1999/xhtml" xml:lang="nn" lang="nn"><head><title>Avdeling for havbruk, sj&#248;mat og marknad - regjeringen.no</title></head><body onload="javascript:Operatest();"><st1:country-region w:st="on"><st1:place w:st="on">Norway</st1:place></st1:country-region></body></html>').tidy()

        want = '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd"><html xmlns="http://www.w3.org/1999/xhtml" xml:lang="nn" lang="nn"><head><title>Avdeling for havbruk, sj&#248;mat og marknad - regjeringen.no</title></head><body onload="javascript:Operatest();"></body></html>'

        self.assertXmlEqual(got, want)

    def testRemoveSt1MetricConverter(self):
        got = HTMLContentConverter('with-o:p.html', '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd"><html xmlns="http://www.w3.org/1999/xhtml" xml:lang="nn" lang="nn"><head><title>Avdeling for havbruk, sj&#248;mat og marknad - regjeringen.no</title></head><body onload="javascript:Operatest();"><st1:metricconverter productid="1,85 G"><span lang="I-SAMI-NO" style="mso-ansi-language: I-SAMI-NO">1,85 G</span></st1:metricconverter></body></html>').tidy()

        want = '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd"><html xmlns="http://www.w3.org/1999/xhtml" xml:lang="nn" lang="nn"><head><title>Avdeling for havbruk, sj&#248;mat og marknad - regjeringen.no</title></head><body onload="javascript:Operatest();"></body></html>'

        self.assertXmlEqual(got, want)

    def testRemoveVShapeType(self):
        got = HTMLContentConverter('with-o:p.html', '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd"><html xmlns="http://www.w3.org/1999/xhtml" xml:lang="nn" lang="nn"><head><title>Avdeling for havbruk, sj&#248;mat og marknad - regjeringen.no</title></head><body onload="javascript:Operatest();"><v:shapetype id="_x0000_t75" path="m@4@5l@4@11@9@11@9@5xe" stroked="f" filled="f" o:preferrelative="t" o:spt="75" coordsize="21600,21600"> <v:stroke joinstyle="miter"></v:stroke><v:formulas><v:f eqn="if lineDrawn pixelLineWidth 0"></v:f><v:f eqn="sum @0 1 0"></v:f><v:f eqn="sum 0 0 @1"></v:f><v:f eqn="prod @2 1 2"></v:f><v:f eqn="prod @3 21600 pixelWidth"></v:f><v:f eqn="prod @3 21600 pixelHeight"></v:f><v:f eqn="sum @0 0 1"></v:f><v:f eqn="prod @6 1 2"></v:f><v:f eqn="prod @7 21600 pixelWidth"></v:f><v:f eqn="sum @8 21600 0"></v:f><v:f eqn="prod @7 21600 pixelHeight"></v:f><v:f eqn="sum @10 21600 0"></v:f></v:formulas><v:path o:connecttype="rect" gradientshapeok="t" o:extrusionok="f"></v:path><?xml:namespace prefix = o ns = "urn:schemas-microsoft-com:office:office"/?><o:lock aspectratio="t" v:ext="edit"></o:lock></v:shapetype></body></html>').tidy()

        want = '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd"><html xmlns="http://www.w3.org/1999/xhtml" xml:lang="nn" lang="nn"><head><title>Avdeling for havbruk, sj&#248;mat og marknad - regjeringen.no</title></head><body onload="javascript:Operatest();"></body></html>'

        self.assertXmlEqual(got, want)

    def testRemoveVShape(self):
        got = HTMLContentConverter('with-o:p.html', '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd"><html xmlns="http://www.w3.org/1999/xhtml" xml:lang="nn" lang="nn"><head><title>Avdeling for havbruk, sj&#248;mat og marknad - regjeringen.no</title></head><body onload="javascript:Operatest();"><v:shape style="WIDTH: 405pt; HEIGHT: 202.5pt" id="_x0000_i1025" type="#_x0000_t75" alt="Jens Stoltenberg, Dmitrij Medvedjev og Jonas Gahr Støre. Foto: Statsministerens kontor"><v:imagedata src="file:///C:\DOCUME~1\oeoe\LOCALS~1\Temp\msohtml1\01\clip_image001.jpg" o:href="http://www.regjeringen.no/upload/SMK/Nyhetsbilder/2010/Stoltenberg-og-Medvedjev_samtaler1_540x270.jpg"></v:imagedata></v:shape></body></html>').tidy()

        want = '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd"><html xmlns="http://www.w3.org/1999/xhtml" xml:lang="nn" lang="nn"><head><title>Avdeling for havbruk, sj&#248;mat og marknad - regjeringen.no</title></head><body onload="javascript:Operatest();"></body></html>'

        self.assertXmlEqual(got, want)

    def testRemoveArea(self):
        got = HTMLContentConverter('with-o:p.html', '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd"><html xmlns="http://www.w3.org/1999/xhtml" xml:lang="nn" lang="nn"><head><title>Avdeling for havbruk, sj&#248;mat og marknad - regjeringen.no</title></head><body onload="javascript:Operatest();"><area title="Suodjalusministtar" href="/fd/sami/p30007057/p30007075/bn.html" shape="rect" alt="Suodjalusministtar" coords="230,10,374,24" /></body></html>').tidy()

        want = '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd"><html xmlns="http://www.w3.org/1999/xhtml" xml:lang="nn" lang="nn"><head><title>Avdeling for havbruk, sj&#248;mat og marknad - regjeringen.no</title></head><body onload="javascript:Operatest();"></body></html>'

        self.assertXmlEqual(got, want)

    def testRemoveObject(self):
        got = HTMLContentConverter('with-o:p.html', '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd"><html xmlns="http://www.w3.org/1999/xhtml" xml:lang="nn" lang="nn"><head><title>Avdeling for havbruk, sj&#248;mat og marknad - regjeringen.no</title></head><body onload="javascript:Operatest();"><object width="640" height="385"><param name="movie" value="http://www.youtube.com/v/1HH5pmM4SAs&amp;hl=nb_NO&amp;fs=1&amp;rel=0" /><param name="allowFullScreen" value="true" /><param name="allowscriptaccess" value="always" /><embed src="http://www.youtube.com/v/1HH5pmM4SAs&amp;hl=nb_NO&amp;fs=1&amp;rel=0" type="application/x-shockwave-flash" allowscriptaccess="always" allowfullscreen="true" width="640" height="385"></embed></object></body></html>').tidy()

        want = '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd"><html xmlns="http://www.w3.org/1999/xhtml" xml:lang="nn" lang="nn"><head><title>Avdeling for havbruk, sj&#248;mat og marknad - regjeringen.no</title></head><body onload="javascript:Operatest();"></body></html>'

        self.assertXmlEqual(got, want)

    def testRemoveComment(self):
        got = HTMLContentConverter('with-o:p.html', '<html><body><b><!--Hey, buddy. Want to buy a used parser?--></b></body></html>').tidy()

        want = '<html xmlns="http://www.w3.org/1999/xhtml"><head><title/></head><body></body></html>'

        self.assertXmlEqual(got, want)

    def testRemoveStyle(self):
        got = HTMLContentConverter('with-o:p.html', '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd"><html xmlns="http://www.w3.org/1999/xhtml"> <head>  <style id="page-skin-1" type="text/css">   <!--------------------------------------------------->  </style> </head> <body> </body></html>').tidy()

        want = '<html xmlns="http://www.w3.org/1999/xhtml"><head><title/></head><body/></html>'

        self.assertXmlEqual(got, want)

    def testRemoveScript(self):
        got = HTMLContentConverter('with-o:p.html', '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd"><html xmlns="http://www.w3.org/1999/xhtml"> <head><script type="text/javascript">(function() { var a=window;function e(b){this.t={};this.tick=function(c,h,d){d=d?d:(new Date).getTime();this.t[c]=[d,h]};this.tick("start",null,b)}var f=new e;a.jstiming={Timer:e,load:f};try{a.jstiming.pt=a.gtbExternal&&a.gtbExternal.pageT()||a.external&&a.external.pageT}catch(g){};a.tickAboveFold=function(b){b=b;var c=0;if(b.offsetParent){do c+=b.offsetTop;while(b=b.offsetParent)}b=c;b<=750&&a.jstiming.load.tick("aft")};var i=false;function j(){if(!i){i=true;a.jstiming.load.tick("firstScrollTime")}}a.addEventListener?a.addEventListener("scroll",j,false):a.attachEvent("onscroll",j); })();</script></head> <body> </body></html>').tidy()

        want = '<html xmlns="http://www.w3.org/1999/xhtml"><head><title/></head><body/></html>'

        self.assertXmlEqual(got, want)

    def testAddPAroundText(self):
        got = HTMLContentConverter('withoutp.html', '<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Final//EN"><html><head><meta http-equiv="Content-type" content="text/html; charset=utf-8"><title>– Den utdøende stammes frykt</title><link rel="stylesheet" type="text/css" href="ssh1.css" /></head><body><h3>VI</h3>... Stockfleth<a href=#[1]>[1]</a> saa<p>Dette høres<h3>VII</h3>... Finnerne<p>Der</body></html>').tidy()

        want = '<?xml version="1.0"?><!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"    "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd"><html xmlns="http://www.w3.org/1999/xhtml"><head><title>– Den utdøende stammes frykt</title>  <link rel="stylesheet" type="text/css" href="ssh1.css" /></head><body>  <h3>VI</h3>  <p>... Stockfleth<a href="#[1]">[1]</a> saa</p>  <p>Dette høres</p>  <h3>VII</h3>  <p>... Finnerne</p>  <p>Der</p></body></html>'

        self.assertXmlEqual(got, want)

class HTMLContentConverter:
    """
    Class to convert html documents to the giellatekno xml format
    """
    def __init__(self, filename, content):
        self.orig = filename
        self.content = content

        self.converterXsl = \
        os.path.join(os.getenv('GTHOME'), 'gt/script/corpus/xhtml2corpus.xsl')

    def tidy(self):
        """
        Run html through tidy
        """
        try:
            soup = bs4.BeautifulSoup(self.content)
        except HTMLParser.HTMLParseError:
            raise ConversionException("BeautifulSoup couldn't parse the html")

        comments = soup.findAll(text=lambda text:isinstance(text, bs4.Comment))
        [comment.extract() for comment in comments]

        [item.extract() for item in soup.findAll(text = lambda text:isinstance(text, bs4.ProcessingInstruction ))]
        [item.extract() for item in soup.findAll(text = lambda text:isinstance(text, bs4.Declaration ))]

        remove_tags = ['script', 'style', 'o:p', 'st1:country-region', 'v:shapetype', 'v:shape', 'st1:metricconverter', 'area', 'object', 'meta', 'fb:like', 'fb:comments', 'g:plusone']

        for remove_tag in remove_tags:
            removes = soup.findAll(remove_tag)
            for remove in removes:
                remove.extract()

        if not ("xmlns", "http://www.w3.org/1999/xhtml") in soup.html.attrs:
            soup.html["xmlns"] = "http://www.w3.org/1999/xhtml"

        soup = soup.prettify().replace('&shy;', u'­').replace('&nbsp;', ' ').replace('&aelig;', u'æ').replace('&eacute;', u'é')

        tidyOption = {"indent": "auto",
                      "indent-spaces": 2,
                      "wrap": 72,
                      "markup": "yes",
                      "output-xml": "yes",
                      "add-xml-decl": "yes",
                      "input-xml": "no",
                      "show-warnings": "no",
                      "numeric-entities": "yes",
                      "quote-marks": "yes",
                      "quote-nbsp": "yes",
                      "quote-ampersand": "yes",
                      "break-before-br": "no",
                      "uppercase-tags": "no",
                      "uppercase-attributes": "no",
                      "char-encoding": "utf8",
                      "enclose-block-text": "yes",
                      "new-empty-tags": "ms,mb,nf,mu",
                      "new-inline-tags": "dato,note,idiv,o:p,pb,v:shapetype,v:stroke,v:formulas,v:f,v:path,v:shape,v:imagedata,o:lock,st1:country-region,st1:place,st1:metricconverter,g:plusone,fb:like,fb:comments",
                      "new-blocklevel-tags": "label,nav,article,header,figcaption,time,aside,figure,footer",
                      "clean": "true",
                      "drop-proprietary-attributes": "true",
                      "drop-empty-paras": "true"
                      }

        tidiedHtml, errors = tidylib.tidy_document(soup, tidyOption)

        #sys.stderr.write(str(lineno()) + ' ' +  soup.prettify())
        return tidiedHtml

    def convert2intermediate(self):
        """
        Convert the original document to the giellatekno xml format, with no
        metadata
        The resulting xml is stored in intermediate
        """
        #print docbook
        htmlXsltRoot = etree.parse(self.converterXsl)
        transform = etree.XSLT(htmlXsltRoot)

        intermediate = ''

        html = self.tidy()
        try:
            doc = etree.fromstring(html)
            intermediate = transform(doc)
        except etree.XMLSyntaxError as e:
            logfile = open(self.orig + '.log', 'w')

            for entry in e.error_log:
                logfile.write('\n')
                logfile.write(str(entry.line))
                logfile.write(':')
                logfile.write(str(entry.column))
                logfile.write(" ")

                try:
                    logfile.write(entry.message)
                except ValueError:
                    logfile.write(entry.message.encode('latin1'))

                logfile.write('\n')

            # html is unicode, encode it as utf8 before writing it
            logfile.write(html.encode('utf8'))
            logfile.close()
            raise ConversionException("Invalid html, log is found in " + self.orig + '.log')


        if len(transform.error_log) > 0:

            logfile = open(self.orig + '.log', 'w')

            for entry in transform.error_log:
                logfile.write('\n')
                logfile.write(str(entry.line))
                logfile.write(':')
                logfile.write(str(entry.column))
                logfile.write(" ")

                try:
                    logfile.write(entry.message)
                except ValueError:
                    logfile.write(entry.message.encode('latin1'))

                logfile.write('\n')

            logfile.write(html.encode('utf8'))
            logfile.close()
            raise ConversionException('transformation failed' + self.orig + '.log')

        return intermediate

class HTMLConverter(HTMLContentConverter):
    def __init__(self, filename):
        f = open(filename)
        HTMLContentConverter.__init__(self, filename, f.read())
        f.close()

class TestRTFConverter(unittest.TestCase):
    def setUp(self):
        self.testrtf = RTFConverter('parallelize_data/Folkemøte.rtf')

    def assertXmlEqual(self, got, want):
        """Check if two stringified xml snippets are equal
        """
        checker = doctestcompare.LXMLOutputChecker()
        if not checker.check_output(want, got, 0):
            message = checker.output_difference(doctest.Example("", want), got, 0).encode('utf-8')
            raise AssertionError(message)

    def testConvert2intermediate(self):
        got = self.testrtf.convert2intermediate()
        want = etree.parse('parallelize_data/Folkemøte.xml')

        self.assertXmlEqual(etree.tostring(got), etree.tostring(want))

class RTFConverter(HTMLContentConverter):
    """
    Class to convert html documents to the giellatekno xml format
    """
    def __init__(self, filename):
        self.orig = filename
        HTMLContentConverter.__init__(self, filename, self.rtf2html())

    def rtf2html(self):
        """Open the rtf document
        Turn it into an html snippet (which starts with a div)
        Change the div tag to body
        Append the body to an html element
        """
        doc = open(self.orig, "rb")
        content = doc.read()
        doc = Rtf15Reader.read(io.BytesIO(content.replace('fcharset256', 'fcharset255')))
        html = XHTMLWriter.write(doc, pretty=True).read()
        xml = etree.fromstring(html)
        xml.tag = 'body'
        htmlElement = etree.Element('html')
        htmlElement.append(xml)
        return etree.tostring(htmlElement)

class TestDocumentFixer(unittest.TestCase):
    def assertXmlEqual(self, got, want):
        """Check if two stringified xml snippets are equal
        """
        checker = doctestcompare.LXMLOutputChecker()
        if not checker.check_output(want, got, 0):
            message = checker.output_difference(doctest.Example("", want), got, 0).encode('utf-8')
            raise AssertionError(message)

    def testFixBodyEncoding(self):
        newstext = PlaintextConverter('parallelize_data/assu97-mac-sami.txt')

        eg = DocumentFixer(newstext.convert2intermediate())
        got = eg.fixBodyEncoding()

        want = etree.parse('parallelize_data/assu97-fixedutf8.xml')

        self.assertXmlEqual(etree.tostring(got), etree.tostring(want))

    def testReplaceLigatures(self):
        svgtext = SVGConverter('parallelize_data/Riddu_Riddu_avis_TXT.200923.svg')
        eg = DocumentFixer(etree.fromstring(etree.tostring(svgtext.convert2intermediate())))
        got = eg.fixBodyEncoding()

        want = etree.parse('parallelize_data/Riddu_Riddu_avis_TXT.200923.xml')

        self.assertXmlEqual(etree.tostring(got), etree.tostring(want))

    def testSimpleDetectQuote1(self):
        origParagraph = '<p>bla bla "bla bla" bla bla </p>'
        expectedParagraph = '<p>bla bla <span type="quote">"bla bla"</span> bla bla</p>'

        df = DocumentFixer(etree.parse('parallelize_data/samediggi-article-48s-before-lang-detection-with-multilingual-tag.xml'))
        gotParagraph = df.detectQuote(etree.fromstring(origParagraph))

        self.assertXmlEqual(etree.tostring(gotParagraph), expectedParagraph)

    def testSimpleDetectQuote2(self):
        origParagraph = '<p>bla bla “bla bla” bla bla</p>'
        expectedParagraph = '<p>bla bla <span type="quote">“bla bla”</span> bla bla</p>'

        df = DocumentFixer(etree.parse('parallelize_data/samediggi-article-48s-before-lang-detection-with-multilingual-tag.xml'))
        gotParagraph = df.detectQuote(etree.fromstring(origParagraph))

        self.assertXmlEqual(etree.tostring(gotParagraph), expectedParagraph)

    def testSimpleDetectQuote3(self):
        origParagraph = '<p>bla bla «bla bla» bla bla</p>'
        expectedParagraph = '<p>bla bla <span type="quote">«bla bla»</span> bla bla</p>'

        df = DocumentFixer(etree.parse('parallelize_data/samediggi-article-48s-before-lang-detection-with-multilingual-tag.xml'))
        gotParagraph = df.detectQuote(etree.fromstring(origParagraph))

        self.assertXmlEqual(etree.tostring(gotParagraph), expectedParagraph)

    def testSimpleDetectQuote4(self):
        origParagraph = '<p type="title">Sámegiel čálamearkkat Windows XP várás.</p>'
        expectedParagraph = '<p type="title">Sámegiel čálamearkkat Windows XP várás.</p>'

        df = DocumentFixer(etree.parse('parallelize_data/samediggi-article-48s-before-lang-detection-with-multilingual-tag.xml'))
        gotParagraph = df.detectQuote(etree.fromstring(origParagraph))

        self.assertXmlEqual(etree.tostring(gotParagraph), expectedParagraph)

    def testSimpleDetectQuote2Quotes(self):
        origParagraph = '<p>bla bla «bla bla» bla bla «bla bla» bla bla</p>'
        expectedParagraph = '<p>bla bla <span type="quote">«bla bla»</span> bla bla <span type="quote">«bla bla»</span> bla bla</p>'

        df = DocumentFixer(etree.parse('parallelize_data/samediggi-article-48s-before-lang-detection-with-multilingual-tag.xml'))
        gotParagraph = df.detectQuote(etree.fromstring(origParagraph))

        self.assertXmlEqual(etree.tostring(gotParagraph), expectedParagraph)

    def testDetectQuoteWithFollowingTag(self):
        origParagraph = '<p>bla bla «bla bla» <em>bla bla</em></p>'
        expectedParagraph = '<p>bla bla <span type="quote">«bla bla»</span> <em>bla bla</em></p>'

        df = DocumentFixer(etree.parse('parallelize_data/samediggi-article-48s-before-lang-detection-with-multilingual-tag.xml'))
        gotParagraph = df.detectQuote(etree.fromstring(origParagraph))

        self.assertXmlEqual(etree.tostring(gotParagraph), expectedParagraph)

    def testDetectQuoteWithTagInfront(self):
        origParagraph = '<p>bla bla <em>bla bla</em> «bla bla»</p>'
        expectedParagraph = '<p>bla bla <em>bla bla</em> <span type="quote">«bla bla»</span></p>'

        df = DocumentFixer(etree.parse('parallelize_data/samediggi-article-48s-before-lang-detection-with-multilingual-tag.xml'))
        gotParagraph = df.detectQuote(etree.fromstring(origParagraph))

        self.assertXmlEqual(etree.tostring(gotParagraph), expectedParagraph)

    def testDetectQuoteWithinTag(self):
        origParagraph = '<p>bla bla <em>bla bla «bla bla»</em></p>'
        expectedParagraph = '<p>bla bla <em>bla bla <span type="quote">«bla bla»</span></em></p>'

        df = DocumentFixer(etree.parse('parallelize_data/samediggi-article-48s-before-lang-detection-with-multilingual-tag.xml'))
        gotParagraph = df.detectQuote(etree.fromstring(origParagraph))

        self.assertXmlEqual(etree.tostring(gotParagraph), expectedParagraph)

    def testWordCount(self):
        origDoc = etree.parse(io.BytesIO('<document xml:lang="sma" id="no_id"><header><title/><genre/><author><unknown/></author><availability><free/></availability><multilingual/></header><body><p>Bïevnesh naasjovnalen pryövoej bïjre</p><p>2008</p><p>Bïevnesh eejhtegidie, tjidtjieh aehtjieh bielide naasjovnalen pryövoej bïjre giej leah maanah 5. jïh 8. tsiehkine</p></body></document>'))

        expectedDoc = '<document xml:lang="sma" id="no_id"><header><title/><genre/><author><unknown/></author><wordcount>20</wordcount><availability><free/></availability><multilingual/></header><body><p>Bïevnesh naasjovnalen pryövoej bïjre</p><p>2008</p><p>Bïevnesh eejhtegidie, tjidtjieh aehtjieh bielide naasjovnalen pryövoej bïjre giej leah maanah 5. jïh 8. tsiehkine</p></body></document>'

        df = DocumentFixer(origDoc)
        df.setWordCount()

        self.assertXmlEqual(etree.tostring(df.etree), expectedDoc)

class DocumentFixer:
    """
    Receive a stringified etree from one of the raw converters,
    replace ligatures, fix the encoding and return an etree with correct
    characters
    """
    def __init__(self, document):
        self.etree = document

    def replaceLigatures(self):
        """
        document is a stringified xml document
        """
        replacements = {
            u"[dstrok]": u"đ",
            u"[Dstrok]": u"Đ",
            u"[tstrok]": u"ŧ",
            u"[Tstrok]": u"Ŧ",
            u"[scaron]": u"š",
            u"[Scaron]": u"Š",
            u"[zcaron]": u"ž",
            u"[Zcaron]": u"Ž",
            u"[ccaron]": u"č",
            u"[Ccaron]": u"Č",
            u"[eng": u"ŋ",
            " ]": "",
            u"Ď": u"đ", # cough
            u"ď": u"đ", # cough
            "\x03": "",
            "\x04": "",
            "\x07": "",
            "\x08": "",
            "\x0F": "",
            "\x10": "",
            "\x11": "",
            "\x13": "",
            "\x14": "",
            "\x15": "",
            "\x17": "",
            "\x18": "",
            "\x1A": "",
            "\x1B": "",
            "\x1C": "",
            "\x1D": "",
            "\x1E": "",
            u"ﬁ": "fi",
            u"ﬂ": "fl",
            u"ﬀ": "ff",
            u"ﬃ": "ffi",
            u"ﬄ": "ffl",
            u"ﬅ": "ft",
        }

        for element in self.etree.iter('p'):
            if element.text:
                for key, value in replacements.items():
                    element.text = element.text.replace(key + ' ', value)
                    element.text = element.text.replace(key, value)

    def fixBodyEncoding(self):
        """
        Send a stringified version of the body into the EncodingGuesser class.
        It returns the same version, but with fixed characters.
        Parse the returned string, insert it into the document
        """
        self.replaceLigatures()

        if isinstance(self.etree, etree._XSLTResultTree):
            sys.stderr.write("xslt!\n")

        body = self.etree.find('body')
        bodyString = etree.tostring(body, encoding='utf-8')
        body.getparent().remove(body)

        eg = decode.EncodingGuesser()
        encoding = eg.guessBodyEncoding(bodyString)

        body = etree.fromstring(eg.decodePara(encoding, bodyString))
        self.etree.append(body)

        self.detectQuotes()

        return etree.parse(io.BytesIO(etree.tostring(self.etree)))

    def detectQuote(self, element):
        """Detect quotes in an etree element.
        """
        newelement = deepcopy(element)

        element.text = ''
        for child in element:
            child.getparent().remove(child)

        quoteList = []
        quoteRegexes = [re.compile('".+?"'), re.compile(u'«.+?»'), re.compile(u'“.+?”')]

        text = newelement.text
        if text:
            for quoteRegex in quoteRegexes:
                for m in quoteRegex.finditer(text):
                    quoteList.append(m.span())

            if len(quoteList) > 0:
                quoteList.sort()
                element.text = text[0:quoteList[0][0]]

                for x in range(0, len(quoteList)):
                    span = etree.Element('span')
                    span.set('type', 'quote')
                    span.text = text[quoteList[x][0]:quoteList[x][1]]
                    if x + 1 < len(quoteList):
                        span.tail = text[quoteList[x][1]:quoteList[x + 1][0]]
                    else:
                        span.tail = text[quoteList[x][1]:]
                    element.append(span)
            else:
                element.text = text

        for child in newelement:
            element.append(self.detectQuote(child))

            if child.tail:
                quoteList = []
                text = child.tail

                for quoteRegex in quoteRegexes:
                    for m in quoteRegex.finditer(text):
                        quoteList.append(m.span())

                if len(quoteList) > 0:
                    quoteList.sort()
                    child.tail = text[0:quoteList[0][0]]

                for x in range(0, len(quoteList)):
                    span = etree.Element('span')
                    span.set('type', 'quote')
                    span.text = text[quoteList[x][0]:quoteList[x][1]]
                    if x + 1 < len(quoteList):
                        span.tail = text[quoteList[x][1]:quoteList[x + 1][0]]
                    else:
                        span.tail = text[quoteList[x][1]:]
                    element.append(span)

        return element

    def detectQuotes(self):
        """Detect quotes in all paragraphs
        """
        for paragraph in self.etree.iter('p'):
            paragraph = self.detectQuote(paragraph)

    def setWordCount(self):
        """Count the words in the file
        """
        plist = []
        for paragraph in self.etree.iter('p'):
            plist.append(etree.tostring(paragraph, method = 'text', encoding = 'utf8'))

        words = len(re.findall(r'\S+', ' '.join(plist)))

        wordcount = self.etree.find('header/wordcount')
        if wordcount is None:
            tags = ['collection', 'publChannel', 'place', 'year', 'translated_from', 'translator', 'author']
            for tag in tags:
                found = self.etree.find('header/' + tag)
                if found is not None:
                    wordcount = etree.Element('wordcount')
                    header = found.getparent()
                    header.insert(header.index(found) + 1, wordcount)
                    break

        wordcount.text = str(words)


class TestXslMaker(unittest.TestCase):
    def assertXmlEqual(self, got, want):
        """Check if two stringified xml snippets are equal
        """
        checker = doctestcompare.LXMLOutputChecker()
        if not checker.check_output(want, got, 0):
            message = checker.output_difference(doctest.Example("", want), got, 0).encode('utf-8')
            raise AssertionError(message)

    def testGetXsl(self):
        xslmaker = XslMaker('parallelize_data/samediggi-article-48.html.xsl')
        got = xslmaker.getXsl()

        want = etree.parse('parallelize_data/test.xsl')

        self.assertXmlEqual(etree.tostring(got), etree.tostring(want))

class XslMaker:
    """
    To convert the intermediate xml to a fullfledged  giellatekno document
    a combination of three xsl files + the intermediate files is needed
    This class makes the xsl file
    """

    def __init__(self, xslfile):
        preprocessXsl = etree.parse(os.path.join(os.getenv('GTHOME'), \
            'gt/script/corpus/preprocxsl.xsl'))
        preprocessXslTransformer = etree.XSLT(preprocessXsl)

        self.filename = xslfile
        try:
            filexsl = etree.parse(xslfile)
        except etree.XMLSyntaxError as e:
            logfile = open(self.filename + '.log', 'w')

            for entry in e.error_log:
                logfile.write(str(entry))
                logfile.write('\n')

            logfile.close()
            raise ConversionException("Syntax error in " + self.filename)

        self.finalXsl = preprocessXslTransformer(filexsl, commonxsl = etree.XSLT.strparam('file://' + os.path.join(os.getenv('GTHOME'), \
            'gt/script/corpus/common.xsl')))

    def getXsl(self):
        return self.finalXsl

class TestLanguageDetector(unittest.TestCase):
    """
    Test the functionality of LanguageDetector
    """
    def setUp(self):
        self.document = etree.parse('parallelize_data/samediggi-article-48s-before-lang-detection-with-multilingual-tag.xml')

    def assertXmlEqual(self, got, want):
        """Check if two stringified xml snippets are equal
        """
        checker = doctestcompare.LXMLOutputChecker()
        if not checker.check_output(want, got, 0):
            message = checker.output_difference(doctest.Example("", want), got, 0).encode('utf-8')
            raise AssertionError(message)

    def testGetMainLang(self):
        testMainLang = 'sme'
        ld = LanguageDetector(self.document)
        self.assertEqual(testMainLang, ld.getMainlang())

    def testSetParagraphLanguageMainlanguage(self):
        origParagraph = '<p>Sámegiella lea 2004 čavčča rájes standárda giellaválga Microsofta operatiivavuogádagas Windows XP. Dat mearkkaša ahte sámegiel bustávaid ja hámiid sáhttá válljet buot prográmmain. Buot leat dás dán fitnodaga Service Pack 2-páhkas, maid ferte viežžat ja bidjat dihtorii. Boađus lea ahte buot boahttevaš Microsoft prográmmat dorjot sámegiela. Dattetge sáhttet deaividit váttisvuođat go čálát sámegiela Outlook-kaleandaris dahje e-poastta namahussajis, ja go čálát sámegillii dakkár prográmmain, maid Microsoft ii leat ráhkadan.</p>'
        expectedParagraph = '<p>Sámegiella lea 2004 čavčča rájes standárda giellaválga Microsofta operatiivavuogádagas Windows XP. Dat mearkkaša ahte sámegiel bustávaid ja hámiid sáhttá válljet buot prográmmain. Buot leat dás dán fitnodaga Service Pack 2-páhkas, maid ferte viežžat ja bidjat dihtorii. Boađus lea ahte buot boahttevaš Microsoft prográmmat dorjot sámegiela. Dattetge sáhttet deaividit váttisvuođat go čálát sámegiela Outlook-kaleandaris dahje e-poastta namahussajis, ja go čálát sámegillii dakkár prográmmain, maid Microsoft ii leat ráhkadan.</p>'

        ld = LanguageDetector(self.document)
        gotParagraph = ld.setParagraphLanguage(etree.fromstring(origParagraph))

        self.assertXmlEqual(etree.tostring(gotParagraph), expectedParagraph)

    def testSetParagraphLanguageMainlanguageQuoteMainlang(self):
        origParagraph = '<p>Sámegiella lea 2004 čavčča rájes standárda giellaválga Microsofta operatiivavuogádagas Windows XP. Dat mearkkaša ahte sámegiel bustávaid ja hámiid sáhttá válljet buot prográmmain. <span type="quote">«Buot leat dás dán fitnodaga Service Pack 2-páhkas, maid ferte viežžat ja bidjat dihtorii»</span>. Boađus lea ahte buot boahttevaš Microsoft prográmmat dorjot sámegiela. Dattetge sáhttet deaividit váttisvuođat go čálát sámegiela Outlook-kaleandaris dahje e-poastta namahussajis, ja go čálát sámegillii dakkár prográmmain, maid Microsoft ii leat ráhkadan.</p>'
        expectedParagraph = '<p>Sámegiella lea 2004 čavčča rájes standárda giellaválga Microsofta operatiivavuogádagas Windows XP. Dat mearkkaša ahte sámegiel bustávaid ja hámiid sáhttá válljet buot prográmmain. <span type="quote">«Buot leat dás dán fitnodaga Service Pack 2-páhkas, maid ferte viežžat ja bidjat dihtorii»</span>. Boađus lea ahte buot boahttevaš Microsoft prográmmat dorjot sámegiela. Dattetge sáhttet deaividit váttisvuođat go čálát sámegiela Outlook-kaleandaris dahje e-poastta namahussajis, ja go čálát sámegillii dakkár prográmmain, maid Microsoft ii leat ráhkadan.</p>'

        ld = LanguageDetector(self.document)
        gotParagraph = ld.setParagraphLanguage(etree.fromstring(origParagraph))

        self.assertXmlEqual(etree.tostring(gotParagraph), expectedParagraph)

    def testSetParagraphLanguageMainlanguageQuoteNotMainlang(self):
        origParagraph = '<p>Sámegiella lea 2004 čavčča rájes standárda giellaválga Microsofta operatiivavuogádagas Windows XP. Dat mearkkaša ahte sámegiel bustávaid ja hámiid sáhttá válljet buot prográmmain. <span type="quote">«Alt finnes i den foreliggende Service Pack 2 fra selskapet, som må lastes ned og installeres på din datamaskin. Konsekvensen er at all framtidig programvare fra Microsoft vil inneholde støtte for samisk»</span>. Boađus lea ahte buot boahttevaš Microsoft prográmmat dorjot sámegiela. Dattetge sáhttet deaividit váttisvuođat go čálát sámegiela Outlook-kaleandaris dahje e-poastta namahussajis, ja go čálát sámegillii dakkár prográmmain, maid Microsoft ii leat ráhkadan.</p>'
        expectedParagraph = '<p>Sámegiella lea 2004 čavčča rájes standárda giellaválga Microsofta operatiivavuogádagas Windows XP. Dat mearkkaša ahte sámegiel bustávaid ja hámiid sáhttá válljet buot prográmmain. <span type="quote" xml:lang="nob">«Alt finnes i den foreliggende Service Pack 2 fra selskapet, som må lastes ned og installeres på din datamaskin. Konsekvensen er at all framtidig programvare fra Microsoft vil inneholde støtte for samisk»</span>. Boađus lea ahte buot boahttevaš Microsoft prográmmat dorjot sámegiela. Dattetge sáhttet deaividit váttisvuođat go čálát sámegiela Outlook-kaleandaris dahje e-poastta namahussajis, ja go čálát sámegillii dakkár prográmmain, maid Microsoft ii leat ráhkadan.</p>'

        ld = LanguageDetector(self.document)
        gotParagraph = ld.setParagraphLanguage(etree.fromstring(origParagraph))

        self.assertXmlEqual(etree.tostring(gotParagraph), expectedParagraph)

    def testSetParagraphLanguageNotMainlanguage(self):
        origParagraph = '<p>Samisk er fra høsten 2004 et standard språkvalg Microsofts operativsystem Windows XP. I praksis betyr det at samiske bokstaver og formater kan velges i alle programmer. Alt finnes i den foreliggende Service Pack 2 fra selskapet, som må lastes ned og installeres på din datamaskin. Konsekvensen er at all framtidig programvare fra Microsoft vil inneholde støtte for samisk. Du vil imidlertid fremdeles kunne oppleve problemer med å skrive samisk i Outlook-kalenderen eller i tittel-feltet i e-post, og med å skrive samisk i programmer levert av andre enn Microsoft.</p>'
        expectedParagraph = '<p xml:lang="nob">Samisk er fra høsten 2004 et standard språkvalg Microsofts operativsystem Windows XP. I praksis betyr det at samiske bokstaver og formater kan velges i alle programmer. Alt finnes i den foreliggende Service Pack 2 fra selskapet, som må lastes ned og installeres på din datamaskin. Konsekvensen er at all framtidig programvare fra Microsoft vil inneholde støtte for samisk. Du vil imidlertid fremdeles kunne oppleve problemer med å skrive samisk i Outlook-kalenderen eller i tittel-feltet i e-post, og med å skrive samisk i programmer levert av andre enn Microsoft.</p>'

        ld = LanguageDetector(self.document)
        gotParagraph = ld.setParagraphLanguage(etree.fromstring(origParagraph))

        self.assertXmlEqual(etree.tostring(gotParagraph), expectedParagraph)

    def testRemoveQuote(self):
        origParagraph = '<p>bla bla <span type="quote">bla1 bla</span> ble ble <span type="quote">bla2 bla</span> <b>bli</b> bli <span type="quote">bla3 bla</span> blo blo</p>'
        expectedParagraph = 'bla bla  ble ble  bli bli  blo blo'

        ld = LanguageDetector(self.document)
        gotParagraph = ld.removeQuote(etree.fromstring(origParagraph))

        self.assertEqual(gotParagraph, expectedParagraph)

    def testDetectLanguageWithMultilingualtag(self):
        ld = LanguageDetector(etree.parse('parallelize_data/samediggi-article-48s-before-lang-detection-with-multilingual-tag.xml'))
        ld.detectLanguage()
        gotDocument = ld.getDocument()

        expectedDocument = etree.parse('parallelize_data/samediggi-article-48s-after-lang-detection-with-multilingual-tag.xml')

        self.assertXmlEqual(etree.tostring(gotDocument), etree.tostring(expectedDocument))

    def testDetectLanguageWithoutMultilingualtag(self):
        ld = LanguageDetector(etree.parse('parallelize_data/samediggi-article-48s-before-lang-detection-without-multilingual-tag.xml'))
        ld.detectLanguage()
        gotDocument = ld.getDocument()

        expectedDocument = etree.parse('parallelize_data/samediggi-article-48s-after-lang-detection-without-multilingual-tag.xml')

        self.assertXmlEqual(etree.tostring(gotDocument), etree.tostring(expectedDocument))

class LanguageDetector:
    """
    Receive an etree.
    Detect the languages of quotes.
    Detect the languages of the paragraphs.
    """
    def __init__(self, document):
        self.document = document
        self.mainlang = self.document.getroot().attrib['{http://www.w3.org/XML/1998/namespace}lang']

        inlangs = []
        for language in self.document.findall('header/multilingual/language'):
            inlangs.append(language.get('{http://www.w3.org/XML/1998/namespace}lang'))
        if len(inlangs) != 0:
            if self.mainlang != '':
                inlangs.append(self.mainlang)
            else:
                raise ConversionException('mainlang not set')

        self.languageGuesser = ngram.NGram(os.path.join(os.getenv('GTHOME'), 'tools/lang-guesser/LM/'), langs = inlangs )

    def getDocument(self):
        return self.document

    def getMainlang(self):
        """
        Get the mainlang of the file
        """
        return self.mainlang

    def setParagraphLanguage(self, paragraph):
        """Extract the text outside the quotes, use this text to set language of
        the paragraph.
        Set the language of the quotes in the paragraph
        """
        paragraphText = self.removeQuote(paragraph)
        lang = self.languageGuesser.classify(paragraphText.encode("ascii", "ignore"))
        if lang != self.getMainlang():
            paragraph.set('{http://www.w3.org/XML/1998/namespace}lang', lang)

        for element in paragraph.iter("span"):
            if element.get("type") == "quote":
                lang = self.languageGuesser.classify(element.text.encode("ascii", "ignore"))
                if lang != self.getMainlang():
                    element.set('{http://www.w3.org/XML/1998/namespace}lang', lang)

        return paragraph

    def removeQuote(self, paragraph):
        """Extract all text except the one inside <span type='quote'>"""
        text = ''
        for element in paragraph.iter():
            if element.tag == 'span' and element.get('type') == 'quote' and element.tail != None:
                text = text + element.tail
            else:
                if element.text != None:
                    text = text + element.text
                if element.tail != None:
                    text = text + element.tail

        return text

    def detectLanguage(self):
        """Detect language in all the paragraphs in self.document
        """
        if self.document.find('header/multilingual') is not None:
            for paragraph in self.document.iter('p'):
                paragraph = self.setParagraphLanguage(paragraph)

class TestDocumentTester(unittest.TestCase):
    def setUp(self):
        pass

    def assertXmlEqual(self, got, want):
        """Check if two stringified xml snippets are equal
        """
        checker = doctestcompare.LXMLOutputChecker()
        if not checker.check_output(want, got, 0):
            message = checker.output_difference(doctest.Example("", want), got, 0).encode('utf-8')
            raise AssertionError(message)


    def testRemoveForeignLanguage1(self):
        origDoc = etree.parse(io.BytesIO('<document xml:lang="sma" id="no_id"><header><title/><genre/><author><unknown/></author><availability><free/></availability><multilingual/></header><body><p>Bïevnesh naasjovnalen</p></body></document>'))

        expectedDoc = '<document xml:lang="sma" id="no_id"><header><title/><genre/><author><unknown/></author><availability><free/></availability><multilingual/></header><body><p>Bïevnesh naasjovnalen</p></body></document>'

        dt = DocumentTester(origDoc)
        dt.removeForeignLanguage()

        self.assertXmlEqual(etree.tostring(dt.document), expectedDoc)

    def testRemoveForeignLanguage2(self):
        origDoc = etree.parse(io.BytesIO('<document xml:lang="sma" id="no_id"><header><title/><genre/><author><unknown/></author><availability><free/></availability><multilingual/></header><body><p xml:lang="nob">Nasjonale prøver</p></body></document>'))

        expectedDoc = '<document xml:lang="sma" id="no_id"><header><title/><genre/><author><unknown/></author><availability><free/></availability><multilingual/></header><body></body></document>'

        dt = DocumentTester(origDoc)
        dt.removeForeignLanguage()

        self.assertXmlEqual(etree.tostring(dt.document), expectedDoc)

    def testRemoveForeignLanguage3(self):
        origDoc = etree.parse(io.BytesIO('<document xml:lang="sma" id="no_id"><header><title/><genre/><author><unknown/></author><availability><free/></availability><multilingual/></header><body><p xml:lang="nob">Nasjonale prøver<span type="quote">Bïevnesh naasjovnalen </span></p></body></document>'))

        expectedDoc = '<document xml:lang="sma" id="no_id"><header><title/><genre/><author><unknown/></author><availability><free/></availability><multilingual/></header><body><p>Bïevnesh naasjovnalen </p></body></document>'

        dt = DocumentTester(origDoc)
        dt.removeForeignLanguage()

        self.assertXmlEqual(etree.tostring(dt.document), expectedDoc)

    def testRemoveForeignLanguage4(self):
        origDoc = etree.parse(io.BytesIO('<document xml:lang="sma" id="no_id"><header><title/><genre/><author><unknown/></author><availability><free/></availability><multilingual/></header><body><p>Bïevnesh naasjovnalen <span type="quote" xml:lang="nob">Nasjonale prøver</span></p></body></document>'))

        expectedDoc = '<document xml:lang="sma" id="no_id"><header><title/><genre/><author><unknown/></author><availability><free/></availability><multilingual/></header><body><p>Bïevnesh naasjovnalen <span type="quote" xml:lang="nob"></span></p></body></document>'

        dt = DocumentTester(origDoc)
        dt.removeForeignLanguage()

        self.assertXmlEqual(etree.tostring(dt.document), expectedDoc)

    def testGetMainLangRatio(self):
        origDoc = etree.parse(io.BytesIO('<document xml:lang="sma" id="no_id"><header><title/><genre/><author><unknown/></author><wordcount>12</wordcount><availability><free/></availability><multilingual/></header><body><p>Bïevnesh naasjovnalen</p><p xml:lang="nob">Nasjonale prøver</p><p xml:lang="nob">Nasjonale prøver <span type="quote">Bïevnesh naasjovnalen </span></p><p>Bïevnesh naasjovnalen <span type="quote" xml:lang="nob">Nasjonale prøver</span></p></body></document>'))

        dt = DocumentTester(origDoc)

        self.assertEqual(dt.getMainlangRatio(), 0.50)

    def testGetUnknownWordsRatio(self):
        origDoc = etree.parse(io.BytesIO('<document xml:lang="sme" id="no_id"><header><title/><genre/><author><unknown/></author><wordcount>86</wordcount><availability><free/></availability><multilingual/></header><body><p>Sámegiellaqw leaqw 2004 čavččaqw rájesqw standárdaqw giellaválgaqw Microsoftaqw qwoperatiivavuogádagas qwWindows qwXP. qwDat mearkkaša ahte sámegiel bustávaid ja hámiid sáhttá válljet buot prográmmain. <span type="quote" xml:lang="nob">«Alt finnes i den foreliggende Service Pack 2 fra selskapet, som må lastes ned og installeres på din datamaskin. Konsekvensen er at all framtidig programvare fra Microsoft vil inneholde støtte for samisk»</span>. Boađus lea ahte buot boahttevaš Microsoft prográmmat dorjot sámegiela. Dattetge sáhttet deaividit váttisvuođat go čálát sámegiela Outlook-kaleandaris dahje e-poastta namahussajis, ja go čálát sámegillii dakkár prográmmain, maid Microsoft ii leat ráhkadan.</p></body></document>'))

        dt = DocumentTester(origDoc)

        self.assertEqual(decimal.Decimal(dt.getUnknownWordsRatio()).quantize(decimal.Decimal('.1'), rounding=decimal.ROUND_DOWN) , decimal.Decimal('0.2').quantize(decimal.Decimal('.1'), rounding=decimal.ROUND_DOWN))

class DocumentTester:
    def __init__(self, document):
        self.document = document
        self.mainlang = self.document.getroot().attrib['{http://www.w3.org/XML/1998/namespace}lang']
        self.removeForeignLanguage()

    def getMainlang(self):
        """
        Get the mainlang of the file
        """
        return self.mainlang

    def getMainlangWordcount(self):
        return len(re.findall(r'\S+', self.getMainlangWords()))

    def getUnknownWordsRatio(self):
        return 1.0 * self.getUnknownWordcount() / self.getMainlangWordcount()

    def getMainlangRatio(self):
        return 1.0 * self.getMainlangWordcount() / float(self.document.find('header/wordcount').text)

    def removeForeignLanguage(self):
        """Remove text mark as not belonging to mainlang
        First remove foreign language in quotes
        Then look for paragraphs with foreign language
        If they contain quotes in the original language, set that as the text
        of the paragraph and remove the xml:lang attribute
        If it contains only foreign text, remove the whole paragraph
        """

        for span in self.document.xpath('//span[@xml:lang]'):
            span.text = ''

        hit = False

        for paragraph in self.document.xpath('//p[@xml:lang]'):
            paragraph.text = ''
            for span in paragraph.xpath('//span[@type="quote"]'):
                if span.get('xml:lang') is None:
                    hit = True
                    paragraph.text = paragraph.text + span.text
                span.getparent().remove(span)

            if not hit:
                paragraph.getparent().remove(paragraph)
            else:
                del paragraph.attrib['{http://www.w3.org/XML/1998/namespace}lang']

    def getUnknownWordcount(self):
        lookupCommand = ['lookup', '-flags', 'mbTT']
        if self.getMainlang() == 'sme':
            lookupCommand.append(os.getenv('GTHOME') + '/gt/' + self.getMainlang() + '/bin/' + self.getMainlang() + '.fst')
        else:
            lookupCommand.append(os.getenv('GTHOME') + '/langs/' + self.getMainlang() + '/src/analyser-gt-desc.xfst')

        subp = subprocess.Popen(lookupCommand, stdin = subprocess.PIPE, stdout = subprocess.PIPE, stderr = subprocess.PIPE)
        (output, error) = subp.communicate(self.getPreprocessedMainlangWords())

        if subp.returncode != 0:
            print >>sys.stderr, 'Could not lookup text'
            print >>sys.stderr, output
            raise ConversionException(error)
        else:
            count = 0
            for line in output.split():
                if '+?' in line:
                    count += 1

            return count

    def getPreprocessedMainlangWords(self):
        """Send the text into preprocess, return the result.
        If the process fails, exit the program
        """
        preprocessCommand = []
        if self.getMainlang() == 'sme':
            abbrFile = os.path.join(os.environ['GTHOME'], 'gt/sme/bin/abbr.txt')
            corrFile = os.path.join(os.environ['GTHOME'], 'gt/sme/bin/corr.txt')
            preprocessCommand = ['preprocess', '--abbr=' + abbrFile, '--corr=' + corrFile]
        else:
            preprocessCommand = ['preprocess']

        subp = subprocess.Popen(preprocessCommand, stdin = subprocess.PIPE, stdout = subprocess.PIPE, stderr = subprocess.PIPE)
        (output, error) = subp.communicate(self.getMainlangWords().replace('\n', ' '))

        if subp.returncode != 0:
            print >>sys.stderr, output
            print >>sys.stderr, error
            raise ConversionException('Could not preprocess text')
        else:
            return output

    def getMainlangWords(self):
        plist = []
        for paragraph in self.document.iter('p'):
            plist.append(etree.tostring(paragraph, method = 'text', encoding = 'utf8'))

        return ' '.join(plist)
