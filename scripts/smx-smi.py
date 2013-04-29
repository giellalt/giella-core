#!/usr/bin/env python
# -*- coding: utf-8 -*-

#
#   Script that removes the lemmas from
#   $GTHOME/langs/sma/src/morphology/stems/sma-propernouns.lexc that are found
#   in both $GTHOME/langs/sma/src/morphology/stems/sma-propernouns.lexc and
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

lang = sys.argv[1]

myre = re.compile(r" .*;")

def lineInSmi(line):
    inSmiwords = False
    line = line.strip()
    if ":" in line and line[:line.find(":")] in content:
        inSmiwords = True
    elif myre.search(line) and line[:myre.search(line).start()] in content:
        inSmiwords = True

    return inSmiwords

with open(os.getenv("GTHOME") + "/gtcore/templates/smi/src/morphology/stems/smi-propernouns.lexc", 'r') as content_file:
    content = content_file.read()

smaname = os.getenv("GTHOME") + "/langs/" + lang + "/src/morphology/stems/" + lang + "-propernouns.lexc"

print smaname
for line in fileinput.FileInput(smaname, inplace=1):
    if line.startswith("!"):
        print line[:-1]
    elif line.startswith("\n"):
        print line[:-1]
    elif not lineInSmi(line):
        print line[:-1]

