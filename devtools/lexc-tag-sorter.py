#!/usr/bin/env python3
# -*- coding: utf-8 -*-

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
#   Copyright © 2016-2018 The University of Tromsø &
#                         the Norwegian Sámi Parliament
#   http://giellatekno.uit.no & http://divvun.no
#
"""Sort tags in lexc lines.

We are only interested in lexc lines that have two or more tags. Other
lines should go untouched.
"""

import fileinput
import glob
import os
import re
from collections import defaultdict

LEXC_LINE_RE = re.compile(r'''
    (?P<exclam>^\s*!\s*)?       #  optional comment
    (?P<content>(<.+>)|(.+))?   #  optional content
    (?P<contlex_space>\s+)      #  space between content and contlex
    (?P<contlex>\S+)            #  any nonspace
    (?P<translation>\s+".*")?   #  optional translation, might be empty
    (?P<semicolon>\s*;\s*)      #  semicolon and space surrounding it
    (?P<comment>!.*)?           #  followed by an optional comment
    $
''', re.VERBOSE | re.UNICODE)

TAG = re.compile(r'''\+[^+]+''')


def is_interesting_line(line):
    lexc_match = LEXC_LINE_RE.match(line.replace('% ', '%¥'))

    if lexc_match:
        groupdict = lexc_match.groupdict()
        if not groupdict.get('exclam') and groupdict.get('content'):
            content = groupdict.get('content').replace('%¥', '% ')
            lexc_line_match = content.find(':')

            if (not (content.startswith('<') and content.endswith('>'))
                    and lexc_line_match != -1):
                upper = content[:lexc_line_match]
                lower = content[lexc_line_match:]

                tags = TAG.findall(upper)
                if len(tags) > 1:

                    new_parts = [TAG.sub('', upper), sort_tags(tags), lower]
                    new_parts.extend([
                        groupdict[key]
                        for key in [
                            'contlex_space', 'contlex', 'translation',
                            'semicolon', 'comment'
                        ] if groupdict.get(key)
                    ])

                    return ''.join(new_parts)

    return line


def sort_tags(tags):
    tagsets = defaultdict(list)

    for tag in tags:
        if tag in ['+NomAg', '+G3'] or tag.startswith('+Hom'):
            tagsets['Hom'].append(tag)
        elif tag.startswith('+v'):
            tagsets['v'].append(tag)
        elif tag.startswith('+Cmp'):
            tagsets['Cmp'].append(tag)
        elif tag.startswith('+Sem'):
            tagsets['Sem'].append(tag)
        else:
            tagsets['resten'].append(tag)

    if len(tagsets['v']) > 1:
        raise ValueError('too many v')
    if len(tagsets['Hom']) > 1:
        raise ValueError('too many hom')

    return ''.join(valid_tags(tagsets))


def valid_tags(tagsets):
    for tug in ['Hom', 'v', 'Cmp', 'Sem', 'resten']:
        if tagsets.get(tug):
            for tog in tagsets[tug]:
                yield tog


def stemroots():
    for lang in [
            'chp', 'cor', 'deu', 'est', 'fin', 'hdn', 'kal', 'koi', 'kpv',
            'mdf', 'mhr', 'myv', 'nob', 'olo', 'sje', 'sma', 'sme', 'smj',
            'smn', 'sms', 'som', 'vro'
    ]:
        yield os.path.join(
            os.getenv('GTHOME'), 'langs', lang, 'src/morphology/stems/')


def filenames():
    for stemroot in stemroots():
        for filename in glob.glob(stemroot + '*.lexc'):
            yield filename


def main():
    for filename in filenames():
        print(filename)
        for line in fileinput.input(filename, inplace=True):
            print(is_interesting_line(line[:-1]))


if __name__ == '__main__':
    main()
