# -*- coding: utf-8 -*-
import sys
import re
import unittest
import sys

ctypes = [

    # mac-sami converted as iconv -f mac -t utf8
    # mac-sami á appears at the same place as latin1 á
    # 0
    {
        u"ª": u"š",
        u"¥": u"Š",
        u"º": u"ŧ",
        u"µ": u"Ŧ",
        u"∫": u"ŋ",
        u"±": u"Ŋ",
        u"¸": u"Ŋ",
        u"π": u"đ",
        u"∞": u"Đ",
        u"Ω": u"ž",
        u"∑": u"Ž",
        u"∏": u"č",
        u"¢": u"Č"
    },

    # iso-ir-197 converted as iconv -f mac -t utf8
    # 1
    {
        u"·": u"á",
        u"¡": u"Á",
        u"≥": u"š",
        u"≤": u"Š",
        u"∏": u"ŧ",
        u"µ": u"Ŧ",
        u"±": u"ŋ",
        u"Ø": u"Ŋ",
        u"§": u"đ",
        u"£": u"Đ",
        u"∫": u"ž",
        u"π": u"Ž",
        u"¢": u"č",
        u"°": u"Č",
        u"Ê": u"æ",
        u"Δ": u"Æ",
        u"¯": u"ø",
        u"ÿ": u"Ø",
        u"Â": u"å",
        u"≈": u"Å",
        u"‰": u"ä",
        u"ƒ": u"Ä",
        u"ˆ": u"ö",
        u"÷": u"Ö",
    },

    # á, æ, å, ø, ö, ä appear as themselves
    # 2
    {
        u"ƒ": u"š",    #
        u"√": u"ŋ",    #
        u"∂": u"đ",    #
        u"π": u"ž",    #
        u"ª": u"č",    #
        u"º": u"Č",    #
    },

    # winsami2 converted as iconv -f latin1 -t utf8
    # á, æ, å, ø, ö, ä appear as themselves
    # 3
    {
        u"": u"š",
        u"": u"Š",
        u"¼": u"ŧ",
        u"º": u"Ŧ",
        u"¹": u"ŋ",
        u"¸": u"Ŋ",
        u"": u"đ",
        u"": u"Đ",
        u"¿": u"ž",
        u"¾": u"Ž",
        u"": u"č",
        u"": u"Č",
    },

    # iso-ir-197 converted as iconv -f latin1 -t utf8
    # á, æ, å, ø, ö, ä appear as themselves
    # 4
    {
        u"³": u"š",
        u"²": u"Š",
        u"¸": u"ŧ",
        u"µ": u"Ŧ",
        u"±": u"ŋ",
        u"¯": u"Ŋ",
        u"¤": u"đ",
        u"£": u"Đ",
        u"º": u"ž",
        u"¹": u"Ž",
        u"¢": u"č",
        u"¡": u"Č",
    },

    # mac-sami to latin1
    # 5
    {
        u"": u"á",
        u"‡": u"á",
        u"ç": u"Á",
        u"»": u"š",
        u"´": u"Š",
        u"¼": u"ŧ",
        u"µ": u"Ŧ",
        u"º": u"ŋ",
        u"±": u"Ŋ",
        u"¹": u"đ",
        u"°": u"Đ",
        u"½": u"ž",
        u"·": u"Ž",
        u"¸": u"č",
        u"¢": u"Č",
        u"¾": u"æ",
        u"®": u"Æ",
        u"¿": u"ø",
        u"¯": u"Ø",
        u"": u"å",
        u"": u"é",
        u"Œ": u"å",
        u"": u"Å",
        u"": u"ä",
        u"": u"Ä",
        u"": u"ö",
        u"": u"Ö",
        u"Ê": u" ",
        u"¤": u"§",
        u"Ò": u"“",
        u"Ó": u"”",
        u"ª ": u"™ ",
        u"ªÓ": u"™”",
        u"Ã": u"√",
        u"Ð": u"–",
        #"Ç": u"«",
        #"È": u"»",
    },

    # found in boundcorpus/goldstandard/orig/sme/facta/GIEHTAGIRJI.correct.doc
    # and boundcorpus/goldstandard/orig/sme/facta/learerhefte_-_vaatmarksfugler.doc
    # á, æ, å, ø, ö, ä appear as themselves
    # 6
    {
        u"ð": u"đ",
        u"Ç": u"Č",
        u"ç": u"č",
        u"ó": u"š",
        u"ý": u"ŧ",
        u"þ": u"ž",
    },

    # found in freecorpus/orig/sme/admin/sd/other_files/dc_00_1.doc
    # and freecorpus/orig/sme/admin/guovda/KS_02.12.99.doc
    # found in boundcorpus/orig/sme/bible/other_files/vitkan.pdf
    # latin4 as latin1
    # á, æ, å, ø, ö, ä appear as themselves
    # 7
    {
        u"ð": u"đ",
        u"È": u"Č",
        u"è": u"č",
        u"¹": u"š",
        u"¿": u"ŋ",
        u"¾": u"ž",
        u"¼": u"ŧ",
        u"‚": u"Č",
        u"„": u"č",
        #"¹": u"ŋ",
        u"˜": u"đ",
        #"¿": u"ž",
    },

    # á, æ, å, ø, ö, ä appear as themselves
    # 8
    {
        u"t1": u"ŧ",
        u"T1": u"Ŧ",
        u"s1": u"š",
        u"S1": u"Š",
        u"n1": u"ŋ",
        u"N1": u"Ŋ",
        u"d1": u"đ",
        u"D1": u"Đ",
        u"z1": u"ž",
        u"Z1": u"Ž",
        u"c1": u"č",
        u"C1": u"Č",
        u"ï¾«": u"«",
        u"ï¾»": u"»",
    }
]

limits = { 0: 1, 1: 1, 2: 3, 3: 3, 4: 3, 5: 3, 6: 1, 7: 1, 8: 3}


class TestEncodingGuesser(unittest.TestCase):
    def testEncodingGuesser(self):
        eg = EncodingGuesser()
        for i in range(0, len(ctypes)):
            self.assertEqual(eg.guessFileEncoding('parallelize_data/decode-' + str(i) + '.txt'), i)

    def roundTripX(self, x):
        eg = EncodingGuesser()

        f = open('parallelize_data/decode-utf8.txt')
        utf8_content = f.read()
        f.close()

        f = open('parallelize_data/decode-' + str(x) + '.txt')
        content = f.read()
        f.close()

        test_content = eg.decodePara(x, content)

        self.assertEqual(utf8_content, test_content)

    def testRoundTripping0(self):
        self.roundTripX(0)

    def testRoundTripping1(self):
        self.roundTripX(1)

    def testRoundTripping2(self):
        self.roundTripX(2)

    def testRoundTripping3(self):
        self.roundTripX(3)

    def testRoundTripping4(self):
        self.roundTripX(4)

    def testRoundTripping5(self):
        self.roundTripX(5)

    def testRoundTripping6(self):
        self.roundTripX(6)

    def testRoundTripping7(self):
        self.roundTripX(7)

    def testRoundTripping8(self):
        self.roundTripX(8)

    def testRoundTrippingFalsePositive(self):
        eg = EncodingGuesser()
        self.assertEqual(eg.guessFileEncoding('parallelize_data/decode-falsepositive.txt'), -1)

class EncodingGuesser:
    """Try to find out if some text or a file has faultily encoded (northern)
    sami letters
    """

    def guessFileEncoding(self, filename):
        """ @brief Guess the encoding of a file

        @param filename name of an utf-8 encoded file
        @return winner is an int, pointing to a position in ctypes, or -1
        """

        f = open(filename)
        content = f.read()
        f.close()
        winner = self.guessBodyEncoding(content)

        return winner

    def getSamiLetterFrequency(self, content):
        """@brief Get the frequency of real "sami" letters in content

        @param content is a unicode text (not utf8 str)
        #return samiLetterFrequency is a dict of letters and their frequencies
        """
        samiLetterFrequency = {}

        for sami_letter in [u'á', u'š', u'ŧ', u'ŋ', u'đ', u'ž', u'č', u'æ', u'ø', u'å', u'ä', u'ö' ]:
            samiLetterFrequency[sami_letter] = len(re.compile(sami_letter).findall(content.lower()))

        #print len(content)
        #for (key, value) in sami_letter_frequency.items():
            #print key + ":", value

        return samiLetterFrequency

    def getEncodingFrequency(self, content, position):
        """@ brief Get the frequency of the letters found at position "position" in ctypes

        @param content is a unicode text (not utf8 str)
        @param position is the position in ctypes
        @return encodingFrequency is a dict of letters from ctypes[position]
        and their frequencies
        """

        encodingFrequency = {}

        for key in ctypes[position].viewkeys():

            if len(re.compile(key).findall(content)) > 0:
                encodingFrequency[key] = len(re.compile(key).findall(content))
                #print key + ":", ctypes[position][key], len(re.compile(key).findall(content))

        return encodingFrequency

    def guessBodyEncoding(self, content):
        """@brief guess the encoding of the string content

        First get the frequencies of the "sami letters"
        Then get the frequencies of the letters in the encodings in ctypes

        If "sami letters" that the encoding tries to fix exist in "content",
        disregard the encoding

        @param content a utf-8 encoded string
        @return winner is an int pointing to a position in ctypes or -1
        to tell that no known encoding is found
        """
        content = content.decode('utf8')
        samiLetterFrequency = self.getSamiLetterFrequency(content)

        maxhits = 0
        winner = -1
        for position in range(0, len(ctypes)):
            encodingFrequency = self.getEncodingFrequency(content, position)

            num = len(encodingFrequency)
            hits = 0
            hitter = False
            for key in encodingFrequency.keys():
                try:
                    if not samiLetterFrequency[ctypes[position][key].lower()]:
                        hitter = True
                except KeyError:
                    pass
                hits += encodingFrequency[key]

            #if hits > 0:
                #print "position", position, "hits", hits, "num", num

            if hits > maxhits and limits[position] < num and hitter:
                winner = position
                maxhits = hits
                #print "winner", winner, "maxhits", maxhits

        #print "the winner is", winner

        return winner

    def guessPersonEncoding(self, person):
        """@brief guess the encoding of the string person

        This is a little simplified version of guessBodyEncoding because the person string is short

        @param content a utf-8 encoded string
        @return winner is an int pointing to a position in ctypes or -1
        to tell that no known encoding is found
        """

        f = open(filename)
        content = f.read()
        content = content.decode('utf8')
        content = content.lower()
        f.close()

        maxhits = 0
        for position in range(0, len(ctypes)):
            hits = 0
            num = 0
            for key in ctypes[position].viewkeys():

                #print len(re.compile(key).findall(content)), key
                if len(re.compile(key).findall(content)) > 0:
                    num = num + 1

                hits = hits + len(re.compile(key).findall(content))

            #print "position", position, "hits", hits, "num", num


            if hits > maxhits:
                winner = position
                maxhits = hits
                #print "winner", winner, "maxhits", maxhits

            # 8 always wins over 5 as long as there are any hits for 8
            if winner == 5 and num > 1:
                winner = 8

        #print "the winner is", winner
        return winner

    def decodePara(self, position, text):
        """@brief Replace letters in text with the ones from the dict at position position in ctypes

        @param position which place the encoding has in the ctypes list
        @param text utf8 encoded str
        @return utf8 encoded str
        """
        text = text.decode('utf8')
        encoding = ctypes[position]

        for key, value in encoding.items():
            text = text.replace(key, value)

        if position == 5:
            text = text.replace(u"Ç", u"«")
            text = text.replace(u"È", u"»")

        return text.encode('utf8')

if __name__ == '__main__':
    eg = EncodingGuesser()
    print eg.guessFileEncoding(sys.argv[1])
