# -*- coding:utf-8 -*-

#
#   This file contains routines to change names of corpus files
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
#   Copyright 2013 Børre Gaup <borre.gaup@uit.no>
#

import os
import sys
import unittest
import unicodedata
import subprocess
import inspect
import lxml.etree as etree

def lineno():
    """Returns the current line number in our program."""
    return inspect.currentframe().f_back.f_lineno


class TestNameChanger(unittest.TestCase):
    def testNoneAsciiLower(self):
        want = 'astndzcaoaoai_'

        name = u'ášŧŋđžčåøæöäï+'
        nc = NameChanger(name)

        self.assertEqual(nc.newname, want)

    def testNoneAsciiUpper(self):
        want = 'astndzcaoaoai_'

        name = u'ÁŠŦŊĐŽČÅØÆÖÄÏ+'
        nc = NameChanger(name)

        self.assertEqual(nc.newname, want)

    def testNoneAsciiBlabla(self):
        want = 'astndzcaoaoai_'

        name = u'ášŧŋđŽČÅØÆÖÄï+'
        nc = NameChanger(name)

        self.assertEqual(nc.newname, want)

    def testOwnNameWithOnlyAscii(self):
        want = 'youllneverwalkalone'

        oldname = 'haha'
        newname = 'YoullNeverWalkAlone'
        nc = NameChanger(oldname, newname)

        self.assertEqual(nc.newname, want)

    def testOwnNameWithOnlyAsciiAndSpace(self):
        want = 'youll_never_walk_alone'

        oldname = 'haha'
        newname = 'Youll Never Walk Alone'
        nc = NameChanger(oldname, newname)

        self.assertEqual(nc.newname, want)

    def testOwnNameWithAsciiAndSpaceAndApostrophe(self):
        want = 'you_ll_never_walk_alone'

        oldname = 'haha'
        newname = "You'll Never Walk Alone"
        nc = NameChanger(oldname, newname)

        self.assertEqual(nc.newname, want)

    def testOwnNameWithNonAscii(self):
        want = 'saddago_beaivi_vai_idja'

        oldname = 'haha'
        newname = u'Šaddágo beaivi vai idja'
        klass = newname.encode('utf8')
        nc = NameChanger(oldname.encode('utf8'), klass)

        self.assertEqual(nc.newname, want)


class NameChanger:
    """Class to change names of corpus files.
    Will also take care of changing info in meta data of parallel files.
    """

    def __init__(self, oldname, newname = None):
        """Find the directory the oldname is in.
        self.oldname is the basename of oldname.
        self.newname is the basename of oldname, in lowercase and
        with some characters replaced.
        """
        self.dirname = os.path.dirname(oldname)
        self.oldname = os.path.basename(oldname)

        if newname is not None:
            self.newname = self.changeToAscii(newname.decode('utf8'))
        else:
            self.newname = self.changeToAscii(self.oldname)

    def changeToAscii(self, oldname):
        """Downcase all chars in oldname, replace some chars
        """
        chars = {u'á':u'a', u'š':u's', u'ŧ':u't', u'ŋ':u'n', u'đ':u'd', u'ž':u'z', u'č':u'c', u'å':u'a', u'ø':u'o', u'æ':u'a', u'ö':u'o', u'ä':u'a', u'ï':u'i', u'+':'_', u' ': u'_', u'(': u'_', u')': u'_', u"'": u'_', u'–': u'-', u'?': u'_'}

        newname = oldname.lower()

        for key, value in chars.items():
            utf8keys = [unicodedata.normalize('NFD', key), unicodedata.normalize('NFC', key)]
            for utf8key in utf8keys:
                if utf8key in newname:
                    newname = newname.replace(utf8key, value)

        return newname

    def moveFile(self, fromname, toname):
        """Change name of file from fromname to toname"""
        if os.path.exists(fromname):
            subp = subprocess.Popen(['svn', 'mv', fromname, toname], stdout = subprocess.PIPE, stderr = subprocess.PIPE)
            (output, error) = subp.communicate()

            if subp.returncode != 0:
                print >>sys.stderr, 'Could not move', fromname, 'to', toname
                print >>sys.stderr, output
                print >>sys.stderr, error
            else:
                sys.stdout.write('.')

        pass

    def changeName(self):
        """Change the name of the original file and it's metadata file
        Update the name in parallel files
        Also move the other files that's connected to the original file
        """
        if self.oldname != self.newname:
            self.moveOrigfile()
            self.moveXslfile()
            self.updateNameInParallelFiles()
            self.movePrestableConverted()
            self.movePrestableToktmx()
            self.movePrestableTmx()

        pass

    def moveOrigfile(self):
        """Change the name of the original file
        using the routines of a given repository tool
        """
        fromname = os.path.join(self.dirname, self.oldname)
        toname = os.path.join(self.dirname, self.newname)

        self.moveFile(fromname, toname)

        pass

    def moveXslfile(self):
        """Change the name of an xsl file using the
        routines of a given repository tool
        """
        fromname = os.path.join(self.dirname, self.oldname + '.xsl')
        toname = os.path.join(self.dirname, self.newname + '.xsl')

        self.moveFile(fromname, toname)

        pass

    def openXslfile(self, xslfile):
        """Open xslfile, return the tree"""
        try:
            tree = etree.parse(xslfile)
        except Exception, inst:
            print "Unexpected error opening %s: %s" % (xslfile, inst)
            sys.exit(254)

        return tree

    def setNewname(self, mainlang, paralang, paraname):
        """
        """
        paradir = self.dirname.replace(mainlang, paralang)
        parafile = os.path.join(paradir, paraname + '.xsl')
        if os.path.exists(parafile):
            paratree = self.openXslfile()
            pararoot = paratree.getroot()

            pararoot.find(".//*[@name='para_" + mainlang + "']").set('select', "'" + self.newname + "'")

            paratree.write(parafile, encoding = 'utf8', xml_declaration = True)

        pass

    def updateNameInParallelFiles(self):
        """Open the .xsl file belonging to the file we are changing names of. Look for parallel files.
        Open the xsl files of these parallel files and change the name of this
        parallel from the old to the new one
        """
        xslfile = os.path.join(self.dirname, self.newname + '.xsl')
        if os.path.exists(xslfile):
            xsltree = self.openXslfile(xslfile)
            xslroot = xsltree.getroot()

            mainlang = xslroot.find(".//*[@name='mainlang']").get('select').replace("'", "")

            if mainlang != "":
                for element in xslroot.iter():
                    if element.attrib.get('name') and \
                    'para_' in element.attrib.get('name') and \
                    element.attrib.get('select') != "''":
                        paralang = element.attrib.get('name').replace('para_', '')
                        paraname = element.attrib.get('select').replace("'", "")
                        self.setNewname(mainlang, paralang, paraname)

        pass

    def movePrestableConverted(self):
        """Move the file in prestable/converted from the old to the new name
        """
        dirname = self.dirname.replace('/orig/', '/prestable/converted/')
        fromname = os.path.join(dirname, self.oldname + '.xml')
        toname = os.path.join(dirname, self.newname + '.xml')

        self.moveFile(fromname, toname)

        pass

    def movePrestableToktmx(self):
        """Move the file in prestable/toktmx from the old to the new name
        """
        for suggestion in ['/prestable/toktmx/sme2nob/', '/prestable/toktmx/nob2sme/']:
            dirname = self.dirname.replace('/orig/', suggestion)
            fromname = os.path.join(dirname, self.oldname + '.toktmx')
            if os.path.exists(fromname):
                toname = os.path.join(dirname, self.newname + '.toktmx')
                self.moveFile(fromname, toname)

        pass

    def movePrestableTmx(self):
        """Move the file in prestable/tmx from the old to the new name
        """
        for suggestion in ['/prestable/tmx/sme2nob/', '/prestable/tmx/nob2sme/']:
            dirname = self.dirname.replace('/orig/', suggestion)
            fromname = os.path.join(dirname, self.oldname + '.tmx')
            if os.path.exists(fromname):
                toname = os.path.join(dirname, self.newname + '.tmx')
                self.moveFile(fromname, toname)

        pass

if __name__ == "__main__":
    nc = NameChanger(os.path.abspath(sys.argv[1]).decode('utf8'))
    print nc.dirname
    print nc.oldname
    print nc.newname
