#!/usr/bin/env python
# -*- coding: utf-8 -*-

#
#   This file contains routines to convert pdf files to xml 
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
#   Copyright 2012 Børre Gaup <borre.gaup@uit.no>
#

import os
from lxml import etree
from lxml import doctestcompare
import doctest

import unittest

class TestPdf2Xml(unittest.TestCase):
    """
    A class to test pdf to "our" xml conversion
    """
    def setup():
        pass
    
    def assertXmlEqual(self, got, want):
        """
        Check if two xml snippets are equal
        """
        string_got = etree.tostring(got, pretty_print = True)
        string_want = etree.tostring(want, pretty_print = True)
        
        checker = doctestcompare.LXMLOutputChecker()
        if not checker.check_output(string_got, string_want, 0):
            message = checker.output_difference(doctest.Example("", string_got), string_want, 0).encode('utf-8')
            raise AssertionError(message)
        
    def testConstruction(self):
        """
        Test the constructor
        """
        # Make sure that an IOError is thrown on a non-existing file
        self.assertRaises(IOError, Pdf2Xml, "foofile")
        # Make sure that an etree.XMLSyntaxError is raised when opening a non xml file
        self.assertRaises(etree.XMLSyntaxError, Pdf2Xml, os.path.join(os.environ['GTFREE'], "orig/sme/admin/others/jahkediedahus_2009.pdf"))
        # Check that we raise a ValueError when the input doc isn't a pdf2xml doc
        self.assertRaises(ValueError, Pdf2Xml, "pdf2xml_data/non_pdf2xml.xml")
        
    def testRemoveTableOfContent(self):
        pass
    
    def testHandlePdf2xml(self):
        
        # First make "our" xml
        pdf2xml = Pdf2Xml("pdf2xml_data/simple.pdf.xml")
        gotXml = pdf2xml.handlePdf2xml()

        # Then parse what we want
        wantXml = etree.parse("pdf2xml_data/simple.xml")
        
        self.assertXmlEqual(gotXml, wantXml)
        
class Pdf2Xml:
    """
    A class to convert pdf to "our" xml format.
    Input is a file that has been converted to libpopplers pdf2xml format.
    This file is then further processed and then converted to "our" format
    """
    
    def __init__(self, inXmlFile):
        """
        Parse the infile
        """
        self.etree = etree.parse(inXmlFile)
        root = self.etree.getroot()
        
        # Raise an exception if this isn't the kind of xml doc this program can handle
        if root.tag != "pdf2xml":
            raise ValueError(root.tag)
        
    def handlePdf2xml(self):
        """
        Handle the root element of the input doc, convert it to "our" format
        """
        document = etree.Element("document")
        body = etree.Element("body")
        document.append(body)
        
        return document
    
    def removeTableOfContent(self):
        """
        Remove lines containing four or more consecutive . marks
        """
        pass
    
    def removeHeader(self):
        """
        Remove page numbers and other repeated content at the top of the page
        """
        pass
    
    def removeFooter(self):
        """
        Remove page numbers and other repeated content at the top of the page
        """
        pass
    
    def findStandardFont(self):
        """
        Find the font that is used mostly in the doc
        """
        pass
    
    def makeParagraphs(self):
        """
        Make the paragraphs out the content on the page
        Insert the paragraphs as they are made. Indicate whether 
        """
        pass
    
    def handlePage(self):
        """
        Parse a page.
        Strip away unwanted elements.
        Indicate whether the content continues to the next page or not
        """
        self.removeHeader()
        self.removeFooter()
        self.removeTableOfContent()
        self.makeParagraphs()
        pass
    
if __name__ == '__main__':
    unittest.main()
    #testSuite = unittest.TestSuite()
    #testSuite.addTest(unittest.makeSuite(TestPdf2Xml))
    #unittest.TextTestRunner().run(testSuite)
    
