import re,traceback
from exceptions import KeyboardInterrupt

nb_ngrams = 400

class _NGram:
    def __init__ (self,arg={}):
        t = type(arg)
        if t == type(""):
            self.addText(arg)
            self.normalise()
        elif t == type({}):
            self.ngrams = arg
            self.normalise()
        else:
            self.ngrams = dict()
            self.ngramskeyset = set()

    def addText (self,text):
        ngrams = dict()
        words = text.split()
        for word in words:
            word = '_'+word+'_'
            size = len(word)
            for i in range(size):
                for s in (1,2,3,4):
                    sub = word[i:i+s]
                    ngrams[sub] = ngrams.get(sub, 0) + 1
                    if i+s >= size:
                        break
        self.ngrams = ngrams
        return self

    def sorted (self):
        sorted = [(v,k) for k,v in self.ngrams.items()]
        sorted.sort()
        sorted.reverse()
        sorted = sorted[:nb_ngrams]
        return sorted

    def normalise (self):
        count = 0
        ngrams = dict()
        for v,k in self.sorted():
            ngrams[k] = count
            count += 1
        self.ngramskeyset = set(ngrams.keys())
        self.ngrams = ngrams
        return self

    def addValues (self,key,value):
        self.ngrams[key] = value
        return self

    def compare (self,ngram):
        settolookout = self.ngramskeyset.intersection(ngram.ngramskeyset)
        missingcount = len(self.ngramskeyset) - len(settolookout)
        d = missingcount * nb_ngrams
        for k in settolookout:
            d += (ngram.ngrams[k] - self.ngrams[k])
        return d


import os
import glob
import sys

class NGram:
    def __init__ (self,folder,ext='.lm',langs=[]):
        self.ngrams = dict()

        size = len(ext)
        count = 0

        fnames = []
        if len(langs) == 0:
            folder = os.path.join(folder,'*'+ext)
            fnames = glob.glob(os.path.normcase(folder))
        else:
            for lang in langs:
                fnames.append(os.path.join(folder,lang+ext))

        for fname in fnames:
            count += 1
            lang = os.path.split(fname)[-1][:-size]
            ngrams = dict()
            try:
                file = open(fname,'r')

                for line in file.readlines():
                    parts = line.strip().split('\t ')
                    if len(parts) != 2:
                        raise ValueError("invalid language file %s line : %s" % (fname,parts))
                    try:
                        ngrams[parts[0]] = int(parts[1])
                    except KeyboardInterrupt:
                        raise
                    except:
                        traceback.print_exc()
                        raise ValueError("invalid language file %s line : %s" % (fname,parts))

                if len(ngrams.keys()):
                    self.ngrams[lang] = _NGram(ngrams)

                file.close()
            except IOError:
                sys.stderr.write("Unknown language: " + os.path.basename(fname)[:-len(ext)] + ' (Language recognition)\n')


        if not count:
            raise ValueError("no language files found")

    def classify (self,text):
        ngram = _NGram(text)
        r = 'guess'
        langs = self.ngrams.keys()
        r = langs.pop()
        min = self.ngrams[r].compare(ngram)
        for lang in langs:
            d = self.ngrams[lang].compare(ngram)
            if d < min:
                min = d
                r = lang
        return r

class Generate:
	def __init__ (self,folder,ext='.txt'):
		self.ngrams = dict()
		folder = os.path.join(folder,'*'+ext)
		size = len(ext)
		count = 0

		for fname in glob.glob(os.path.normcase(folder)):
			count += 1
			lang = os.path.split(fname)[-1][:-size]
			n = _NGram()

			file = open(fname,'r')
			for line in file.readlines():
				n.addText(line)
			file.close()

			n.normalise()
			self.ngrams[lang] = n

	def save (self,folder,ext='.lm'):
		for lang in self.ngrams.keys():
			fname = os.path.join(folder,lang+ext)
			file = open(fname,'w')
			for v,k in self.ngrams[lang].sorted():
				file.write("%s\t %d\n" % (k,v))
			file.close()

#ng = _NGram()
#lg = NGram('/home/vsk/Desktop/Langdet/san/ngram_language/LM/')

#def detectLanguage(text):
    #global lg
    #text = text.encode("ascii", "ignore")
    #return lg.classify(text)
