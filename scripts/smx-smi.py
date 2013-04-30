#!/usr/bin/env python
# -*- coding: utf-8 -*-

#
#   Script that prints out lemmas in
#   $GTHOME/langs/sma/src/morphology/stems/sm[x]-propernouns.lexc that are found
#   in both $GTHOME/langs/sma/src/morphology/stems/sm[x]-propernouns.lexc and
#   $GTHOME//gtcore/templates/smi/src/morphology/stems/smi-propernouns.lexc
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
import re
import fileinput
import sys

smiwords = []
possiblesmxduplicates = []
myre = re.compile(r" .*;")

def addSmxLines(line):
    if not (line.startswith("!") or line.startswith("\n") or line.startswith(" ")):
        line = line.strip()
        if ":" in line and line[:line.find(":")] in smiwords:
            possiblesmxduplicates.append(line)
        elif myre.search(line) and line[:myre.search(line).start()] in smiwords:
            possiblesmxduplicates.append(line)

def readSmi():
    with open(os.getenv("GTHOME") + "/gtcore/templates/smi/src/morphology/stems/smi-propernouns.lexc", 'r') as content_file:
        for line in content_file:
            if line.startswith("!"):
                pass
            elif line.startswith("\n"):
                pass
            elif ":" in line:
                smiwords.append(line[:line.find(":")])
            elif myre.search(line):
                smiwords.append(line[:myre.search(line).start()])

def readSmx(lang):
    smxname = os.getenv("GTHOME") + "/langs/" + lang + "/src/morphology/stems/" + lang + "-propernouns.lexc"

    for line in fileinput.FileInput(smxname):
        addSmxLines(line)

def printConclusion():
    for line in possiblesmxduplicates:
        print line

    print "There are", len(possiblesmxduplicates), "possible duplexes printed above"

def main():
    if len(sys.argv) == 2:
        readSmi()
        readSmx(sys.argv[1])
        printConclusion()
    else:
        print "State the name of the language that you would like to check, e.g:"
        print "smx-smi.py sme"
        sys.exit(1)

if __name__ == "__main__":
    main()
