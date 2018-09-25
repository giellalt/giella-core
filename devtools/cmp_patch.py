#!/usr/bin/python
"""Print only Cmp parts of diffs

Usage:
cmp_patch.py < input.patch
cat input.patch | cmp_patch.py
"""
from __future__ import absolute_import, print_function, unicode_literals
import sys
import re

part = []
found_cmp = False

for line in sys.stdin:
    if re.match('.+Cmp$', line):
        found_cmp = True
    if part and re.match("\d", line):
        if found_cmp:
            print(''.join(part), end='')
            found_cmp = False
        part = []
    part.append(line.decode('utf8'))

if found_cmp:
    print(''.join(part), end='')
