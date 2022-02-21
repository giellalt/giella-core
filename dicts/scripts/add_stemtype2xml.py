# -*- encoding: utf-8 -*-
"""
    Add stem type to xml dict (nds).
        Ex.
        Entry in input dict:
        <e>
            <lg>
               <l pos="A">sovkken</l>
            </lg>
            <mg>
               <tg xml:lang="nob">
                  <t pos="A">blind</t>
               </tg>
            </mg>
        </e>
        Entry in output dict:
        <e>
            <lg>
               <l pos="A" stem="3syll">sovkken</l>
            </lg>
            <mg>
               <tg xml:lang="nob">
                  <t pos="A">blind</t>
               </tg>
            </mg>
        </e>

    How to use the script:
    python add_stemtype2xml <PoS> <PATH_TO_STEMTYPE_FILE> <PATH_TO_DICT> <PATH_TO_LEXC_FILE>

        Ex.
        python add_stemtype2xml.py ~/main/words/dicts/smenob/scripts/nouns_stemtypes.txt ~/main/apps/dicts/nds/src/neahtta/dicts/sme-nob.all.xml ~/all-gut/giellalt/lang-sme/src/fst/stems/nouns.lexc

        Ex. (gtdict)
        python add_stemtype2xml.py $GTHOME/words/dicts/smenob/scripts/nouns_stemtypes.txt /home/neahtta/neahtta/dicts/sme-nob.all.xml $HOME/giellalt/lang-sme/src/fst/stems/nouns.lexc

    The output file is created as <PATH_TO_DICT>.stem.xml

        Ex.
        ~/main/apps/dicts/nds/src/neahtta/dicts/sme-nob.all.xml.stem.xml
"""

import sys
from fabric.colors import cyan, green, red
from subprocess import Popen, PIPE

try:
    pos_name = sys.argv[1]
    stem_file = sys.argv[2]
    dict_file_in = sys.argv[3]
    if len(sys.argv) == 5:
        lexc_file = sys.argv[4]
    else:
        lexc_file = sys.argv[4:]
    if pos_name == "nouns":
        pos = "N"
    if pos_name == "adjectives":
        pos = "A"
    if pos_name == "verbs":
        pos = "V"
    if pos_name == "prop":
        pos = "Prop"
except IndexError:
    print(red("** You forgot one of the input parameters!"))
    print(
        red(
            "** You need to pass paths for the lexc file, the stemtype file and the dict file."
        )
    )
    quit()


if type(lexc_file) is not list:
    try:
        lf = open(lexc_file, "r")
    except IOError:
        print(red("** The path/name you entered for the lexc file is wrong!"))
        quit()
else:
    all_lexc = " ".join(lexc_file)
    cmd = "cat " + all_lexc + "> all_lexc.lexc"
    p = Popen(cmd, shell=True, stdout=PIPE, stderr=PIPE)
    out, err = p.communicate()
    try:
        lf = open("all_lexc.lexc", "r")
    except IOError:
        print(red("** The path/name you entered for the lexc file is wrong!"))
        quit()


try:
    sf = open(stem_file, "r")
except IOError:
    print(red("** The path/name you entered for the stemtype file is wrong!"))
    quit()

try:
    dfi = open(dict_file_in, "r")
except IOError:
    print(red("** The path/name you entered for the dict file is wrong!"))
    quit()

dict_file_out = sys.argv[3] + ".stem.xml"
dfo = open(dict_file_out, "w+")

stem_2syll = False
stem_3syll = False
stem_Csyll = False
list_2syll = []
list_3syll = []
list_Csyll = []


print(cyan("** Creating 2syll, 3syll, Csyll lists"))
line = sf.readline()
cnt = 0
while line:
    cnt += 1
    l = line.strip()
    if cnt > 16 and l != "":
        if 'stem="2syll"' in l:
            stem_2syll = True
        if 'stem="3syll"' in l:
            stem_3syll = True
            stem_2syll = False
        if 'stem="Csyll"' in l:
            stem_Csyll = True
            stem_2syll = False
            stem_3syll = False
        if stem_2syll and not stem_3syll and not "stem=" in l:
            list_2syll.append(l)
        if stem_3syll and not stem_Csyll and not "stem=" in l:
            list_3syll.append(l)
        if stem_Csyll and not "stem=" in l:
            list_Csyll.append(l)
    line = sf.readline()
print(green("** Done"))


print(cyan("** Creating python dict with lexc and stems"))
dict_lex_stem = {}

line = lf.readline()
while line:
    l = line.strip()
    l_split_right_p = l.split("+")
    l_split_right_c = l.split(":")
    if len(l_split_right_p) > 1 or len(l_split_right_c) > 1:
        l_split = l.split(" ")
        stem = ""
        if len(l_split) > 1 and not "Err/" in l_split[0]:
            if "-" in l_split[1] and "prop" in stem_file:
                idx = l_split[1].index("-")
                l_split[1] = l_split[1][0:idx]
            if l_split[1] in list_2syll:
                stem = "2syll"
            else:
                if l_split[1] in list_3syll:
                    stem = "3syll"
                else:
                    if l_split[1] in list_Csyll:
                        stem = "Csyll"
            if "%" in l_split[0]:
                lemma_p = l.split("+")[0]
                lemma = ""
                for word in lemma_p.split("%"):
                    lemma += word
                dict_lex_stem.update({lemma: stem})
            elif "+" in l_split[0]:
                dict_lex_stem.update({l_split[0].split("+")[0]: stem})
            else:
                dict_lex_stem.update({l_split[0].split(":")[0]: stem})
    line = lf.readline()
lf.close()
sf.close()
print(green("** Done"))


print(cyan("** Adding stem type to xml dict"))
line_dd = dfi.readline()

import re

while line_dd:
    if "<l" in line_dd and not "stem=" in line_dd:
        match = re.search(">.+<", line_dd)
        match_pos = re.search('pos="[a-zA-Z]"', line_dd)
        pos_dict = ""
        if match_pos:
            pos_dict = match_pos.group(0).replace('pos="', "").replace('"', "")
        if match:
            if pos_dict == pos:
                lemma = match.group(0).replace(">", "").replace("<", "")
                if lemma in dict_lex_stem:
                    line_dd = line_dd.replace(
                        match.group(0),
                        ' stem="' + dict_lex_stem[lemma] + '"' + match.group(0),
                    )
                    dfo.write(line_dd)
                else:
                    dfo.write(line_dd)
            else:
                dfo.write(line_dd)
        else:
            dfo.write(line_dd)
    else:
        dfo.write(line_dd)

    line_dd = dfi.readline()

dfi.close()
dfo.close()
print(green("** Done"))
