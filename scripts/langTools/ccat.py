# -*- coding:utf-8 -*-

import inspect
def lineno():
    """Returns the current line number in our program."""
    return inspect.currentframe().f_back.f_lineno

import unittest
import io
import cStringIO

from lxml import etree
import os
import sys

class XMLPrinter:
    def __init__(self,
                 lang=None,
                 allP=False,
                 title=False,
                 listitem=False,
                 table=False,
                 correction=False,
                 error=False,
                 errorort=False,
                 errorortreal=False,
                 errormorphsyn=False,
                 errorsyn=False,
                 errorlex=False,
                 errorlang=False,
                 noforeign=False,
                 typos=False,
                 printFilename=False,
                 oneWordPerLine=False):

        self.p = True
        self.allP = allP

        if title or listitem or table:
            self.p = False

        self.title = title
        self.listitem = listitem
        self.table = table

        self.correction = correction
        self.error = error
        self.errorort = errorort
        self.errorortreal = errorortreal
        self.errormorphsyn = errormorphsyn
        self.errorsyn = errorsyn
        self.errorlex = errorlex
        self.errorlang = errorlang
        self.noforeign = noforeign

        if (error or
            errorort or
            errorortreal or
            errormorphsyn or
            errorsyn or
            errorlex or
            errorlang or
            noforeign):
            self.errorFiltering = True
        else:
            self.errorFiltering = False

        self.typos = typos
        self.printFilename = printFilename
        if self.typos:
            self.oneWordPerLine = True
        else:
            self.oneWordPerLine = oneWordPerLine

        self.lang = lang
        self.outfile = sys.stdout

    def getLang(self):
        """
        Get the lang of the file
        """
        return self.eTree.getroot().attrib['{http://www.w3.org/XML/1998/namespace}lang']

    def getElementLanguage(self, element, parentlang):
        if element.get('{http://www.w3.org/XML/1998/namespace}lang') is None:
            return parentlang
        else:
            return element.get('{http://www.w3.org/XML/1998/namespace}lang')

    def collectNotInlineErrors(self, element, textlist):
        '''Add the formatted errors as strings to the textlist list
        '''
        errorString = self.errorNotInline(element)
        if errorString != '':
            textlist.append(errorString)

        for child in element:
            if self.visitErrorNotInline(child):
                self.collectNotInlineErrors(child, textlist)

        if not self.typos:
            if element.tail != None and element.tail.strip() != '':
                if not self.oneWordPerLine:
                    textlist.append(element.tail.strip())
                else:
                    textlist.append('\n'.join(element.tail.strip().split()))

    def errorNotInline(self, element):
        '''Collect and format element.text, element.tail and
        the attributes into the string text

        Also scan the children if there is no error filtering or
        if the element is filtered
        '''
        text = ''
        if not self.noforeign:
            if element.text is not None and element.text.strip() != '':
                text = element.text.strip()

            if not self.errorFiltering or self.includeThisError(element):
                for child in element:
                    if text != '':
                        text += ' '
                    text += child.get('correct')
                    if  child.tail is not None and child.tail.strip() != '':
                        text += ' ' + child.tail.strip()

            text += self.getErrorAttributes(dict(element.attrib))

        return text

    def getErrorAttributes(self, attributes):
        '''Collect and format the attributes + the filename
        into the string text.
        '''
        text = '\t'
        text += attributes.get('correct')
        del attributes['correct']

        attr = []
        for key in sorted(attributes):
            attr.append(key + '=' + attributes[key])

        if len(attr) > 0:
            text += '\t#'
            text += ','.join(attr)

            if self.printFilename:
                text += ', file: ' + os.path.basename(self.filename)

        elif self.printFilename:
            text += '\t#file: ' + os.path.basename(self.filename)

        return text

    def collectInlineErrors(self, element, textlist, parentlang):
        '''Add the "correct" element to the list textlist
        '''
        if element.get('correct') != None and not self.noforeign:
            textlist.append(element.get('correct'))

        self.getTail(element, textlist, parentlang)

    def collectPlainP(self, element, parentlang):
        textlist = []

        self.plainP(element, textlist, parentlang)

        if len(textlist) > 0:
            if not self.oneWordPerLine:
                self.outfile.write(' '.join(textlist).encode('utf8'))
                self.outfile.write(' ¶\n')
            else:
                self.outfile.write('\n'.join(textlist).encode('utf8'))
                self.outfile.write('\n')

    def getText(self, element, textlist, parentlang):
        '''Get the text part of an lxml element
        '''
        if element.text != None and element.text.strip() != '' and (self.lang == None or self.getElementLanguage(element, parentlang) == self.lang):
            if not self.oneWordPerLine:
                textlist.append(element.text.strip())
            else:
                textlist.append('\n'.join(element.text.strip().split()))

    def getTail(self, element, textlist, parentlang):
        '''Get the tail part of an lxml element
        '''
        if element.tail != None and element.tail.strip() != '' and (self.lang == None or parentlang == self.lang):
            if not self.oneWordPerLine:
                textlist.append(element.tail.strip())
            else:
                textlist.append('\n'.join(element.tail.strip().split()))

    def visitChildren(self, element, textlist, parentlang):
        for child in element:
            if self.visitErrorInline(child):
                self.collectInlineErrors(child, textlist, self.getElementLanguage(child, parentlang))
            elif self.visitErrorNotInline(child):
                self.collectNotInlineErrors(child, textlist)
            else:
                self.plainP(child, textlist, self.getElementLanguage(element, parentlang))

    def plainP(self, element, textlist, parentlang):
        if not self.typos:
            self.getText(element, textlist, parentlang)
        self.visitChildren(element, textlist, parentlang)
        if not self.typos:
            self.getTail(element, textlist, parentlang)

    def visitThisNode(self, element):
        '''Return True if the element should be visited
        '''
        return (
            self.allP or
            (
                self.p is True and (element.get('type') is None or element.get('type') == 'text')
            ) or (
                self.title is True and element.get('type') == 'title'
            ) or (
                self.listitem is True and element.get('type') == 'listitem'
            ) or (
                self.table is True and element.get('type') == 'tablecell'
            )
        )

    def visitErrorNotInline(self, element):
        return (
            element.tag.startswith('error') and self.oneWordPerLine and not self.errorFiltering or
            self.includeThisError(element)
            )

    def visitErrorInline(self, element):
        return (
                element.tag.startswith('error') and not self.oneWordPerLine and
                (self.correction or self.includeThisError(element))
            )

    def includeThisError(self, element):
        return self.errorFiltering and (
                (element.tag == 'error' and self.error) or \
                (element.tag == 'errorort' and self.errorort) or \
                (element.tag == 'errorortreal' and self.errorortreal) or \
                (element.tag == 'errormorphsyn' and self.errormorphsyn) or \
                (element.tag == 'errorsyn' and self.errorsyn) or \
                (element.tag == 'errorlex' and self.errorlex) or \
                (element.tag == 'errorlang' and self.errorlang) or \
                (element.tag == 'errorlang' and self.noforeign)
            )

    def setOutfile(self, outfile):
        '''outfile must either be a string containing the path to the file
        where the result should be written, or an object that supports the
        write method
        '''
        if type(outfile) != file:
            if isinstance(outfile, (str, unicode)):
                self.outfile = open(outfile, 'w')
            else:
                self.outfile = outfile

    def processFile(self, filename):
        if os.path.exists(filename):
            self.eTree = etree.parse(filename)
        self.filename = filename

        for p in self.eTree.findall('.//p'):
            if self.visitThisNode(p):
                self.collectPlainP(p, self.getLang())

class TestCcat(unittest.TestCase):
    def testSingleErrorInline(self):
        x = XMLPrinter()
        inputError = etree.fromstring('<errorortreal correct="fiskeleting" errtype="nosplit" pos="noun">fiske leting</errorortreal>')

        textlist = []
        x.collectInlineErrors(inputError, textlist, 'nob')

        self.assertEqual('\n'.join(textlist), 'fiskeleting')

    def testSingleErrorNotInline(self):
        x = XMLPrinter()
        inputError = etree.fromstring('<errorortreal correct="fiskeleting" errtype="nosplit" pos="noun">fiske leting</errorortreal>')

        textlist = []
        x.collectNotInlineErrors(inputError, textlist)

        self.assertEqual('\n'.join(textlist), 'fiske leting\tfiskeleting\t#errtype=nosplit,pos=noun')

    def testSingleErrorNotInlineWithFilename(self):
        x = XMLPrinter(printFilename=True)
        inputError = etree.fromstring('<errorortreal correct="fiskeleting" errtype="nosplit" pos="noun">fiske leting</errorortreal>')

        x.filename = 'p.xml'

        textlist = []
        x.collectNotInlineErrors(inputError, textlist)

        self.assertEqual('\n'.join(textlist), 'fiske leting\tfiskeleting\t#errtype=nosplit,pos=noun, file: p.xml')

    def testSingleErrorNotInlineWithFilenameWithoutAttributes(self):
        x = XMLPrinter(printFilename=True)
        inputError = etree.fromstring('<errorortreal correct="fiskeleting">fiske leting</errorortreal>')

        x.filename = 'p.xml'

        textlist = []
        x.collectNotInlineErrors(inputError, textlist)

        self.assertEqual('\n'.join(textlist), 'fiske leting\tfiskeleting\t#file: p.xml')

    def testMultiErrorInLine(self):
        x = XMLPrinter(printFilename=True)

        inputError = etree.fromstring('<errormorphsyn cat="x" const="spred" correct="skoledagene er så vanskelige" errtype="agr" orig="x" pos="adj">skoledagene er så<errorort correct="vanskelig" errtype="nosilent" pos="adj">vanskerlig</errorort></errormorphsyn>')
        textlist = []
        x.collectInlineErrors(inputError, textlist, 'nob')

        self.assertEqual('\n'.join(textlist),
                         u'skoledagene er så vanskelige')

    def testMultiErrormorphsynNotInlineWithFilename(self):
        inputError = etree.fromstring('<errormorphsyn cat="x" const="spred" correct="skoledagene er så vanskelige" errtype="agr" orig="x" pos="adj">skoledagene er så<errorort correct="vanskelig" errtype="nosilent" pos="adj">vanskerlig</errorort></errormorphsyn>')

        x = XMLPrinter(oneWordPerLine=True, printFilename=True)
        x.filename = 'p.xml'

        textlist = []
        x.collectNotInlineErrors(inputError, textlist)

        self.assertEqual('\n'.join(textlist), u'skoledagene er så vanskelig\tskoledagene er så vanskelige\t#cat=x,const=spred,errtype=agr,orig=x,pos=adj, file: p.xml\nvanskerlig\tvanskelig\t#errtype=nosilent,pos=adj, file: p.xml')

    def testMultiErrorlexNotInline(self):
        inputError = etree.fromstring('<errorlex correct="man soga"><errorort correct="makkár" errtype="á" pos="interr">makkar</errorort> soga</errorlex>')
        textlist = []

        x = XMLPrinter(typos=True)
        x.collectNotInlineErrors(inputError, textlist)

        self.assertEqual('\n'.join(textlist), u'makkár soga\tman soga\nmakkar\tmakkár\t#errtype=á,pos=interr')

    def testP(self):
        x = XMLPrinter()
        x.setOutfile(cStringIO.StringIO())
        inputP = etree.fromstring('<p>Et stykke av Norge som er lite kjent - Litt om Norge i mellomkrigstiden</p>')

        x.collectPlainP(inputP, 'nob')
        self.assertEqual(x.outfile.getvalue(), 'Et stykke av Norge som er lite kjent - Litt om Norge i mellomkrigstiden ¶\n')

    def testPWithSpan(self):
        x = XMLPrinter()
        x.setOutfile(cStringIO.StringIO())

        inputP = etree.fromstring('<p>I 1864 ga han ut boka <span type="quote" xml:lang="dan">"Fornuftigt Madstel"</span>.</p>')

        x.collectPlainP(inputP, 'nob')
        self.assertEqual(x.outfile.getvalue(), 'I 1864 ga han ut boka "Fornuftigt Madstel" . ¶\n')

    def testPWithError(self):
        x = XMLPrinter()
        x.setOutfile(cStringIO.StringIO())

        inputP = etree.fromstring('<p><errormorphsyn cat="pl3prs" const="fin" correct="Bearpmehat sirrejit" errtype="agr" orig="sg3prs" pos="verb"><errorort correct="Bearpmehat" errtype="svow" pos="noun">Bearpmahat</errorort> <errorlex correct="sirre" errtype="w" origpos="v" pos="verb">earuha</errorlex></errormorphsyn> uskki ja loaiddu.</p>')

        x.collectPlainP(inputP, 'sme')
        self.assertEqual(x.outfile.getvalue(), "Bearpmahat earuha uskki ja loaiddu. ¶\n")

    def testPOneWordPerLine(self):
        inputP = etree.fromstring('<p>Et stykke av Norge som er lite kjent - Litt om Norge i mellomkrigstiden</p>')

        x = XMLPrinter(oneWordPerLine=True)

        x.setOutfile(cStringIO.StringIO())

        x.collectPlainP(inputP, 'nob')
        self.assertEqual(x.outfile.getvalue(), 'Et\nstykke\nav\nNorge\nsom\ner\nlite\nkjent\n-\nLitt\nom\nNorge\ni\nmellomkrigstiden\n')

    def testPWithSpanOneWordPerLine(self):
        inputP = etree.fromstring('<p>I 1864 ga han ut boka <span type="quote" xml:lang="dan">"Fornuftigt Madstel"</span>.</p>')

        x = XMLPrinter(oneWordPerLine=True)
        x.setOutfile(cStringIO.StringIO())

        x.collectPlainP(inputP, 'nob')
        self.assertEqual(x.outfile.getvalue(), 'I\n1864\nga\nhan\nut\nboka\n\"Fornuftigt\nMadstel\"\n.\n')

    def testPWithErrorOneWordPerLine(self):
        inputP = etree.fromstring('<p>livččii <errorort correct="makkárge" errtype="á" pos="adv">makkarge</errorort> politihkka, muhto rahpasit baicca muitalivčče <errorlex correct="man soga"><errorort correct="makkár" errtype="á" pos="interr">makkar</errorort> soga</errorlex>sii</p>')

        x = XMLPrinter(oneWordPerLine=True)

        x.setOutfile(cStringIO.StringIO())
        x.collectPlainP(inputP, 'sme')
        self.assertEqual(x.outfile.getvalue(), "livččii\nmakkarge\tmakkárge\t#errtype=á,pos=adv\npolitihkka,\nmuhto\nrahpasit\nbaicca\nmuitalivčče\nmakkár soga\tman soga\nmakkar\tmakkár\t#errtype=á,pos=interr\nsoga\nsii\n")

    def testPWithErrorCorrection(self):
        inputP = etree.fromstring('<p>livččii <errorort correct="makkárge" errtype="á" pos="adv">makkarge</errorort> politihkka, muhto rahpasit baicca muitalivčče <errorlex correct="man soga"><errorort correct="makkár" errtype="á" pos="interr">makkar</errorort> soga</errorlex>sii</p>')

        x = XMLPrinter(correction=True)

        x.setOutfile(cStringIO.StringIO())
        x.collectPlainP(inputP, 'sme')
        self.assertEqual(x.outfile.getvalue(), "livččii makkárge politihkka, muhto rahpasit baicca muitalivčče man soga sii ¶\n")

    def testPWithErrorfilteringErrorlex(self):
        inputP = etree.fromstring('<p>livččii <errorort correct="makkárge" errtype="á" pos="adv">makkarge</errorort> politihkka, muhto rahpasit baicca muitalivčče <errorlex correct="man soga"><errorort correct="makkár" errtype="á" pos="interr">makkar</errorort> soga</errorlex>sii</p>')

        x = XMLPrinter(errorlex=True)

        x.setOutfile(cStringIO.StringIO())
        x.collectPlainP(inputP, 'sme')
        self.assertEqual(x.outfile.getvalue(), "livččii makkarge politihkka, muhto rahpasit baicca muitalivčče man soga sii ¶\n")

    def testPWithErrorfilteringErrormorphsyn(self):
        inputP = etree.fromstring('<p>livččii <errorort correct="makkárge" errtype="á" pos="adv">makkarge</errorort> politihkka, muhto rahpasit baicca muitalivčče <errorlex correct="man soga"><errorort correct="makkár" errtype="á" pos="interr">makkar</errorort> soga</errorlex>sii</p>')

        x = XMLPrinter(errormorphsyn=True)

        x.setOutfile(cStringIO.StringIO())
        x.collectPlainP(inputP, 'sme')
        self.assertEqual(x.outfile.getvalue(), "livččii makkarge politihkka, muhto rahpasit baicca muitalivčče makkar soga sii ¶\n")

    def testPWithErrorfilteringErrorort(self):
        x = XMLPrinter(errorort=True)

        inputP = etree.fromstring('<p>livččii <errorort correct="makkárge" errtype="á" pos="adv">makkarge</errorort> politihkka, muhto rahpasit baicca muitalivčče <errorlex correct="man soga"><errorort correct="makkár" errtype="á" pos="interr">makkar</errorort> soga</errorlex>sii</p>')


        x.setOutfile(cStringIO.StringIO())
        x.collectPlainP(inputP, 'sme')
        self.assertEqual(x.outfile.getvalue(), "livččii makkárge politihkka, muhto rahpasit baicca muitalivčče makkár soga sii ¶\n")

    def testPWithErrorfilteringErrorortreal(self):
        x = XMLPrinter(errorortreal=True)

        inputP = etree.fromstring('<p>livččii <errorort correct="makkárge" errtype="á" pos="adv">makkarge</errorort> politihkka, muhto rahpasit baicca muitalivčče <errorlex correct="man soga"><errorort correct="makkár" errtype="á" pos="interr">makkar</errorort> soga</errorlex>sii</p>')

        x.setOutfile(cStringIO.StringIO())
        x.collectPlainP(inputP, 'sme')
        self.assertEqual(x.outfile.getvalue(), "livččii makkarge politihkka, muhto rahpasit baicca muitalivčče makkar soga sii ¶\n")

    def testVisitThisPDefault(self):
        x = XMLPrinter()

        for types in [' type="title"',
                      ' type="listitem"',
                      ' type="tablecell"']:
            inputXML = etree.fromstring('<p' + types + '>ášŧŋđžčøåæ</p>')
            self.assertFalse(x.visitThisNode(inputXML))

        for types in ['',
                      ' type="text"']:
            inputXML = etree.fromstring('<p' + types + '>ášŧŋđžčøåæ</p>')
            self.assertTrue(x.visitThisNode(inputXML))

    def testVisitThisPTitleSet(self):
        x = XMLPrinter(title=True)

        for types in ['',
                      ' type="text"',
                      ' type="listitem"',
                      ' type="tablecell"']:
            inputXML = etree.fromstring('<p' + types + '>ášŧŋđžčøåæ</p>')
            self.assertFalse(x.visitThisNode(inputXML))

        for types in [' type="title"']:
            inputXML = etree.fromstring('<p' + types + '>ášŧŋđžčøåæ</p>')
            self.assertTrue(x.visitThisNode(inputXML))

    def testVisitThisPListitemSet(self):
        x = XMLPrinter(listitem=True)

        for types in ['',
                      ' type="text"',
                      ' type="title"',
                      ' type="tablecell"']:
            inputXML = etree.fromstring('<p' + types + '>ášŧŋđžčøåæ</p>')
            self.assertFalse(x.visitThisNode(inputXML))

        for types in [' type="listitem"']:
            inputXML = etree.fromstring('<p' + types + '>ášŧŋđžčøåæ</p>')
            self.assertTrue(x.visitThisNode(inputXML))

    def testVisitThisPTablecellSet(self):
        x = XMLPrinter(table=True)

        for types in ['',
                      ' type="text"',
                      ' type="title"',
                      ' type="listitem"']:
            inputXML = etree.fromstring('<p' + types + '>ášŧŋđžčøåæ</p>')
            self.assertFalse(x.visitThisNode(inputXML))

        for types in [' type="tablecell"']:
            inputXML = etree.fromstring('<p' + types + '>ášŧŋđžčøåæ</p>')
            self.assertTrue(x.visitThisNode(inputXML))

    def testVisitThisPAllpSet(self):
        x = XMLPrinter(allP=True)

        for types in ['',
                      ' type="text"',
                      ' type="title"',
                      ' type="listitem"',
                      ' type="tablecell"']:
            inputXML = etree.fromstring('<p' + types + '>ášŧŋđžčøåæ</p>')
            self.assertTrue(x.visitThisNode(inputXML))

    def testProcessFileDefault(self):
        x = XMLPrinter()

        for types in [' type="title"',
                      ' type="listitem"',
                      ' type="tablecell"']:
            x.eTree = etree.parse(io.BytesIO('<document id="no_id" xml:lang="sme"><body><p' + types + '>ášŧŋđžčøåæ</p></body></document>'))
            x.setOutfile(cStringIO.StringIO())

            x.processFile('barabbas/p.xml')
            self.assertEqual(x.outfile.getvalue(), '')

        for types in ['',
                      ' type="text"']:
            x.eTree = etree.parse(io.BytesIO('<document id="no_id" xml:lang="sme"><body><p' + types + '>ášŧŋđžčøåæ</p></body></document>'))
            x.setOutfile(cStringIO.StringIO())

            x.processFile('barabbas/p.xml')
            self.assertEqual(x.outfile.getvalue(), 'ášŧŋđžčøåæ ¶\n')

    def testProcessFileTitleSet(self):
        x = XMLPrinter(title=True)

        for types in ['',
                      ' type="text"',
                      ' type="listitem"',
                      ' type="tablecell"']:
            x.eTree = etree.parse(io.BytesIO('<document id="no_id" xml:lang="sme"><body><p' + types + '>ášŧŋđžčøåæ</p></body></document>'))
            x.setOutfile(cStringIO.StringIO())

            x.processFile('barabbas/p.xml')
            self.assertEqual(x.outfile.getvalue(), '')

        for types in [' type="title"']:
            x.eTree = etree.parse(io.BytesIO('<document id="no_id" xml:lang="sme"><body><p' + types + '>ášŧŋđžčøåæ</p></body></document>'))
            x.setOutfile(cStringIO.StringIO())
            x.processFile('barabbas/p.xml')
            self.assertEqual(x.outfile.getvalue(), 'ášŧŋđžčøåæ ¶\n')

    def testProcessFileListitemSet(self):
        x = XMLPrinter(listitem=True)

        for types in ['',
                      ' type="text"',
                      ' type="title"',
                      ' type="tablecell"']:
            x.eTree = etree.parse(io.BytesIO('<document id="no_id" xml:lang="sme"><body><p' + types + '>ášŧŋđžčøåæ</p></body></document>'))
            x.setOutfile(cStringIO.StringIO())
            x.processFile('barabbas/p.xml')
            self.assertEqual(x.outfile.getvalue(), '')

        for types in [' type="listitem"']:
            x.eTree = etree.parse(io.BytesIO('<document id="no_id" xml:lang="sme"><body><p' + types + '>ášŧŋđžčøåæ</p></body></document>'))
            x.setOutfile(cStringIO.StringIO())
            x.processFile('barabbas/p.xml')
            self.assertEqual(x.outfile.getvalue(), 'ášŧŋđžčøåæ ¶\n')

    def testProcessFileTablecellSet(self):
        x = XMLPrinter(table=True)

        for types in ['',
                      ' type="text"',
                      ' type="title"',
                      ' type="listitem"']:
            x.eTree = etree.parse(io.BytesIO('<document id="no_id" xml:lang="sme"><body><p' + types + '>ášŧŋđžčøåæ</p></body></document>'))
            x.setOutfile(cStringIO.StringIO())
            x.processFile('barabbas/p.xml')
            self.assertEqual(x.outfile.getvalue(), '')

        for types in [' type="tablecell"']:
            x.eTree = etree.parse(io.BytesIO('<document id="no_id" xml:lang="sme"><body><p' + types + '>ášŧŋđžčøåæ</p></body></document>'))
            x.setOutfile(cStringIO.StringIO())
            x.processFile('barabbas/p.xml')
            self.assertEqual(x.outfile.getvalue(), 'ášŧŋđžčøåæ ¶\n')

    def testProcessFileAllpSet(self):
        x = XMLPrinter(allP=True)

        for types in ['',
                      ' type="text"',
                      ' type="title"',
                      ' type="listitem"',
                      ' type="tablecell"']:
            x.eTree = etree.parse(io.BytesIO('<document id="no_id" xml:lang="sme"><body><p' + types + '>ášŧŋđžčøåæ</p></body></document>'))
            x.setOutfile(cStringIO.StringIO())
            x.processFile('barabbas/p.xml')
            self.assertEqual(x.outfile.getvalue(), 'ášŧŋđžčøåæ ¶\n')

    def testProcessFileOneWordPerLineErrorlex(self):
        x = XMLPrinter(     oneWordPerLine=True,
                            errorlex=True)

        x.eTree = etree.parse(io.BytesIO('<document id="no_id" xml:lang="sme"><body><p>livččii <errorort correct="makkárge" errtype="á" pos="adv">makkarge</errorort> politihkka, muhto rahpasit baicca muitalivčče <errorlex correct="man soga"><errorort correct="makkár" errtype="á" pos="interr">makkar</errorort>soga</errorlex>sii</p></body></document>'))

        x.setOutfile(cStringIO.StringIO())
        x.processFile('barabbas/p.xml')
        self.assertEqual(x.outfile.getvalue(), 'livččii\nmakkarge\npolitihkka,\nmuhto\nrahpasit\nbaicca\nmuitalivčče\nmakkár soga\tman soga\nsii\n')

    def testProcessFileOneWordPerLineErrorort(self):
        x = XMLPrinter(     oneWordPerLine=True,
                            errorort=True)

        x.eTree = etree.parse(io.BytesIO('<document id="no_id" xml:lang="sme"><body><p>livččii <errorort correct="makkárge" errtype="á" pos="adv">makkarge</errorort> politihkka, muhto rahpasit baicca muitalivčče <errorlex correct="man soga"><errorort correct="makkár" errtype="á" pos="interr">makkar</errorort>soga</errorlex>sii</p></body></document>'))

        x.setOutfile(cStringIO.StringIO())
        x.processFile('barabbas/p.xml')
        self.assertEqual(x.outfile.getvalue(), 'livččii\nmakkarge\tmakkárge\t#errtype=á,pos=adv\npolitihkka,\nmuhto\nrahpasit\nbaicca\nmuitalivčče\nmakkar\tmakkár\t#errtype=á,pos=interr\nsoga\nsii\n')

    def testProcessFileTypos(self):
        x = XMLPrinter(typos=True)

        x.eTree = etree.parse(io.BytesIO('<document id="no_id" xml:lang="sme"><body><p>livččii <errorort correct="makkárge" errtype="á" pos="adv">makkarge</errorort> politihkka, muhto rahpasit baicca muitalivčče <errorlex correct="man soga"><errorort correct="makkár" errtype="á" pos="interr">makkar</errorort>soga</errorlex>sii</p></body></document>'))

        x.setOutfile(cStringIO.StringIO())
        x.processFile('barabbas/p.xml')
        self.assertEqual(x.outfile.getvalue(), 'makkarge\tmakkárge\t#errtype=á,pos=adv\nmakkár soga\tman soga\nmakkar\tmakkár\t#errtype=á,pos=interr\n')

    def testProcessFileTyposErrorlex(self):
        x = XMLPrinter(     typos=True,
                            errorlex=True)

        x.eTree = etree.parse(io.BytesIO('<document id="no_id" xml:lang="sme"><body><p>livččii <errorort correct="makkárge" errtype="á" pos="adv">makkarge</errorort> politihkka, muhto rahpasit baicca muitalivčče <errorlex correct="man soga"><errorort correct="makkár" errtype="á" pos="interr">makkar</errorort>soga</errorlex>sii</p></body></document>'))

        x.setOutfile(cStringIO.StringIO())
        x.processFile('barabbas/p.xml')
        self.assertEqual(x.outfile.getvalue(), 'makkár soga\tman soga\n')

    def testProcessFileTyposErrorort(self):
        x = XMLPrinter(     typos=True,
                            oneWordPerLine=True,
                            errorort=True)

        x.eTree = etree.parse(io.BytesIO('<document id="no_id" xml:lang="sme"><body><p>livččii <errorort correct="makkárge" errtype="á" pos="adv">makkarge</errorort> politihkka, muhto rahpasit baicca muitalivčče <errorlex correct="man soga"><errorort correct="makkár" errtype="á" pos="interr">makkar</errorort>soga</errorlex>sii</p></body></document>'))
        x.setOutfile(cStringIO.StringIO())

        x.processFile('barabbas/p.xml')
        self.assertEqual(x.outfile.getvalue(), 'makkarge\tmakkárge\t#errtype=á,pos=adv\nmakkar\tmakkár\t#errtype=á,pos=interr\n')

    def testGetLang(self):
        x = XMLPrinter()
        x.eTree = etree.parse(io.BytesIO('<document id="no_id" xml:lang="sme"/>'))

        self.assertEqual(x.getLang(),  'sme')

    def testGetElementLanguageSameAsParent(self):
        x = XMLPrinter()

        element = etree.fromstring('<p/>')
        self.assertEqual(x.getElementLanguage(element, 'sme'), 'sme')

    def testGetElementLanguageDifferentFromParent(self):
        x = XMLPrinter()

        element = etree.fromstring('<p xml:lang="nob"/>')
        self.assertEqual(x.getElementLanguage(element, 'sme'), 'nob')

    def testProcessFileLanguageNob(self):
        x = XMLPrinter(lang='nob')
        x.eTree = etree.parse(io.BytesIO('<document id="no_id" xml:lang="nob"><body><p>nob1 <span type="quote" xml:lang="dan">dan1</span>nob2</p></body></document>'))

        x.setOutfile(cStringIO.StringIO())
        x.processFile('barabbas/p.xml')
        self.assertEqual(x.outfile.getvalue(), 'nob1 nob2 ¶\n')

    def testProcessFileLanguageDan(self):
        x = XMLPrinter(lang='dan')
        x.eTree = etree.parse(io.BytesIO('<document id="no_id" xml:lang="nob"><body><p>nob1 <span type="quote" xml:lang="dan">dan1</span>nob2</p></body></document>'))

        x.setOutfile(cStringIO.StringIO())
        x.processFile('barabbas/p.xml')
        self.assertEqual(x.outfile.getvalue(), 'dan1 ¶\n')

    def testProcessTwoParagraphs(self):
        x = XMLPrinter()
        x.eTree = etree.parse(io.BytesIO('<document id="no_id" xml:lang="nob"><body><p>nob1</p><p>nob2</p></body></document>'))

        x.setOutfile(cStringIO.StringIO())
        x.processFile('barabbas/p.xml')
        self.assertEqual(x.outfile.getvalue(), 'nob1 ¶\nnob2 ¶\n')

    def testProcessMinusLSme(self):
        x = XMLPrinter(lang='sme')
        x.eTree = etree.parse(io.BytesIO('<document id="no_id" xml:lang="nob"><body><p type="text">men <errormorphsyn cat="x" const="spred" correct="skoledagene er så vanskelige" errtype="agr" orig="x" pos="adj">skoledagene er så<errorort correct="vanskelig" errtype="nosilent" pos="adj">vanskerlig</errorort></errormorphsyn>å komme igjennom,</p></body></document>'))
        x.setOutfile(cStringIO.StringIO())
        x.processFile('barabbas/p.xml')

        self.assertEqual(x.outfile.getvalue(), '')

    def testForeign(self):
        x = XMLPrinter(errorlang=True)
        x.eTree = etree.parse(io.BytesIO('<document id="no_id" xml:lang="nob"><body><p>Vijmak bierjjedak!<errorlang correct="nor">Pjuh</errorlang>vijmak de bierjjedak<errorort correct="sjattaj" errorinfo="vowlat,á-a">sjattáj</errorort>.</p></body></document>'))
        x.setOutfile(cStringIO.StringIO())
        x.processFile('barabbas/p.xml')

        self.assertEqual(x.outfile.getvalue(), 'Vijmak bierjjedak! nor vijmak de bierjjedak sjattáj . ¶\n')

    def testNoForeign(self):
        x = XMLPrinter(noforeign=True)
        x.eTree = etree.parse(io.BytesIO('<document id="no_id" xml:lang="nob"><body><p>Vijmak bierjjedak!<errorlang correct="nor">Pjuh</errorlang>vijmak de bierjjedak<errorort correct="sjattaj" errorinfo="vowlat,á-a">sjattáj</errorort>.</p></body></document>'))
        x.setOutfile(cStringIO.StringIO())
        x.processFile('barabbas/p.xml')

        self.assertEqual(x.outfile.getvalue(), 'Vijmak bierjjedak! vijmak de bierjjedak sjattáj . ¶\n')

    def testNoForeignTypos(self):
        x = XMLPrinter(noforeign=True, typos=True)
        x.eTree = etree.parse(io.BytesIO('<document id="no_id" xml:lang="nob"><body><p>Vijmak bierjjedak!<errorlang correct="nor">Pjuh</errorlang>vijmak de bierjjedak<errorort correct="sjattaj" errorinfo="vowlat,á-a">sjattáj</errorort>.</p></body></document>'))
        x.setOutfile(cStringIO.StringIO())
        x.processFile('barabbas/p.xml')

        self.assertEqual(x.outfile.getvalue(), '')

    def testTyposErrordepth3(self):
        x = XMLPrinter(typos=True)
        x.eTree = etree.parse(io.BytesIO('<document id="no_id" xml:lang="nob"><body><p><errormorphsyn cat="genpl" const="obj" correct="čoggen ollu joŋaid ja sarridiid" errtype="case" orig="nompl" pos="noun"><errormorphsyn cat="genpl" const="obj" correct="čoggen ollu joŋaid" errtype="case" orig="nompl" pos="noun"><errorort correct="čoggen" errtype="mono" pos="verb">čoaggen</errorort> ollu jokŋat</errormorphsyn>ja sarridat</errormorphsyn></p></body></document>'))
        x.setOutfile(cStringIO.StringIO())
        x.processFile('barabbas/p.xml')

        self.assertEqual(x.outfile.getvalue(), 'čoggen ollu joŋaid ja sarridat\tčoggen ollu joŋaid ja sarridiid\t#cat=genpl,const=obj,errtype=case,orig=nompl,pos=noun\nčoggen ollu jokŋat\tčoggen ollu joŋaid\t#cat=genpl,const=obj,errtype=case,orig=nompl,pos=noun\nčoaggen\tčoggen\t#errtype=mono,pos=verb\n')

    def testTyposErrormorphsynTwice(self):
        x = XMLPrinter(typos=True, errormorphsyn=True)
        x.eTree = etree.parse(io.BytesIO('<document id="no_id" xml:lang="nob"><body><p><errormorphsyn cat="sg3prs" const="v" correct="lea okta mánná" errtype="agr" orig="pl3prs" pos="v">leat <errormorphsyn cat="nomsg" const="spred" correct="okta mánná" errtype="case" orig="gensg" pos="n">okta máná</errormorphsyn></errormorphsyn></p></body></document>'))
        x.setOutfile(cStringIO.StringIO())
        x.processFile('barabbas/p.xml')

        self.assertEqual(x.outfile.getvalue(), 'leat okta mánná\tlea okta mánná\t#cat=sg3prs,const=v,errtype=agr,orig=pl3prs,pos=v\nokta máná\tokta mánná\t#cat=nomsg,const=spred,errtype=case,orig=gensg,pos=n\n')

    def testSetOutfileString(self):
        x = XMLPrinter()
        x.setOutfile('abc.xml')

        self.assertTrue(os.path.exists('abc.xml'))
        os.remove('abc.xml')

if __name__ == '__main__':
    unittest.main()
