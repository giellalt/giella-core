#!/usr/bin/env python
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
"""Script to sort and align lexc entries."""

from __future__ import absolute_import, print_function

import argparse
import codecs
import glob
import io
import os
import re
import sys
import unittest
from collections import defaultdict

import yaml

LEXC_LINE_RE = re.compile(r'''
    (?P<contlex>\S+)            #  any nonspace
    (?P<translation>\s+".*")?   #  optional translation, might be empty
    \s*;\s*                     #  skip space and semicolon
    (?P<comment>!.*)?           #  followed by an optional comment
    $
''', re.VERBOSE | re.UNICODE)

LEXC_CONTENT_RE = re.compile(r'''
    (?P<exclam>^\s*!\s*)?          #  optional comment
    (?P<content>(<.+>)|(.+))?      #  optional content
''', re.VERBOSE | re.UNICODE)


def parse_line(old_match):
    """Parse a lexc line.

    Args:
        old_match: the output of LEXC_LINE_RE.groupdict.

    Returns:
        defaultdict: The entries inside the lexc line expressed as
            a defaultdict
    """
    line_dict = defaultdict(str)

    if old_match.get('exclam'):
        line_dict[u'exclam'] = u'!'

    line_dict[u'contlex'] = old_match.get(u'contlex')
    if old_match.get(u'translation'):
        line_dict[u'translation'] = old_match.get(
            u'translation').strip().replace(u'%¥', u'% ')

    if old_match.get(u'comment'):
        line_dict[u'comment'] = old_match.get(u'comment').strip().replace(
            u'%¥', u'% ')

    line = old_match.get('content')
    if line:
        line = line.replace(u'%¥', u'% ')
        if line.startswith(u'<') and line.endswith(u'>'):
            line_dict[u'upper'] = line
        else:
            lexc_line_match = line.find(u":")

            if lexc_line_match != -1:
                line_dict[u'upper'] = line[:lexc_line_match].strip()
                line_dict[u'divisor'] = u':'
                line_dict[u'lower'] = line[lexc_line_match + 1:].strip()
                if line_dict[u'lower'].endswith('%'):
                    line_dict[u'lower'] = line_dict[u'lower'] + u' '
            else:
                if line.strip():
                    line_dict[u'upper'] = line.strip()

    return line_dict


def line2dict(line):
    """Parse a valid line.

    Args:
        line: a lexc line
    """
    line = line.replace(u'% ', u'%¥')
    lexc_line_match = LEXC_LINE_RE.search(line)
    if lexc_line_match:
        content = lexc_line_match.groupdict()
        content.update(
            LEXC_CONTENT_RE.match(LEXC_LINE_RE.sub('', line)).groupdict())
        return parse_line(content)

    return {}


def sort_tags(line_dict, tagsets):
    tags = line_dict['upper'].split('+')

    if not re.search('\w+', tags[0], flags=re.UNICODE):
        raise ValueError(tags[0])

    for tag in tags[1:]:
        for start in [
                'Cmp', 'Sem', 'v', 'Err', 'Der', 'Use', 'OLang', 'Dial',
                'Pref', 'Foc', 'Hom', 'Area'
        ]:
            if tag.startswith(start):
                tagsets[start].add(tag)
                break
        else:
            tagsets['resten'].add(tag)


def parse_file(filename, tagsets):
    with io.open(filename) as lexc:
        for lexc_line in lexc:
            if not lexc_line.startswith('LEXICON'):
                line_dict = line2dict(lexc_line.rstrip())
                if line_dict and '<' not in line_dict['upper'] and not line_dict.get(
                        'exclam'):
                    try:
                        sort_tags(line_dict, tagsets)
                    except ValueError as error:
                        print(u'Strange line {}: {}'.format(lexc_line.rstrip(), filename))


def main():
    for lang in [
            'chp', 'cor', 'deu', 'est', 'fin', 'hdn', 'kal', 'koi', 'kpv',
            'mdf', 'mhr', 'myv', 'nob', 'olo', 'sje', 'sma', 'sme', 'smj',
            'smn', 'sms', 'som', 'vro'
    ]:
        tagsets = defaultdict(set)
        stemroot = os.path.join(
            os.getenv('GTHOME'), 'langs', lang, 'src/morphology')
        for filename in glob.glob(stemroot + '/stems/*.lexc'):
            parse_file(filename, tagsets)

        with open(os.path.join(stemroot, 'tags.yaml'), 'w') as outfile:
            yaml.dump(tagsets, outfile, default_flow_style=False)


if __name__ == '__main__':
    main()
