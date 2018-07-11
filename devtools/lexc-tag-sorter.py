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
"""Script to sort and align lexc entries."""


import fileinput
import glob
import os
import re
from collections import defaultdict

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
        line_dict['exclam'] = '!'

    line_dict['contlex'] = old_match.get('contlex')
    if old_match.get('translation'):
        line_dict['translation'] = old_match.get(
            'translation').strip().replace('%¥', '% ')

    if old_match.get('comment'):
        line_dict['comment'] = old_match.get('comment').strip().replace(
            '%¥', '% ')

    line = old_match.get('content')
    if line:
        line = line.replace('%¥', '% ')
        if line.startswith('<') and line.endswith('>'):
            line_dict['upper'] = line
        else:
            lexc_line_match = line.find(':')

            if lexc_line_match != -1:
                line_dict['upper'] = line[:lexc_line_match].strip()
                line_dict['divisor'] = ':'
                line_dict['lower'] = line[lexc_line_match + 1:].strip()
                if line_dict['lower'].endswith('%'):
                    line_dict['lower'] = line_dict['lower'] + ' '
            else:
                if line.strip():
                    line_dict['upper'] = line.strip()

    return line_dict


def line2dict(line):
    """Parse a valid line.

    Args:
        line: a lexc line
    """
    line = line.replace('% ', '%¥')
    lexc_line_match = LEXC_LINE_RE.search(line)
    if lexc_line_match:
        content = lexc_line_match.groupdict()
        content.update(
            LEXC_CONTENT_RE.match(LEXC_LINE_RE.sub('', line)).groupdict())
        return parse_line(content)

    return {}


def sort_tags(line_dict):
    tagsets = defaultdict(list)
    tags = [tag for tag in line_dict['upper'].split('+') if tag.strip()]

    if tags:
        if tags[0] and not re.search('\w+', tags[0], flags=re.UNICODE):
            raise ValueError(tags[0])

        tagsets['lemma'].append(tags[0])

        for tag in tags[1:]:
            if tag in ['NomAg', 'G3'] or tag.startswith('Hom'):
                tagsets['Hom'].append(tag)
            elif tag.startswith('v'):
                tagsets['v'].append(tag)
            elif tag.startswith('Cmp'):
                tagsets['Cmp'].append(tag)
            elif tag.startswith('Sem'):
                tagsets['Sem'].append(tag)
            else:
                tagsets['resten'].append(tag)

        if len(tagsets['v']) > 1:
            raise ValueError('too many v')
        if len(tagsets['Hom']) > 1:
            raise ValueError('too many hom')

        haff = '+'.join(valid_tags(tagsets))
        if haff != line_dict['upper']:
            line_dict['upper'] = haff
            return compact_line(line_dict)


def valid_tags(tagsets):
    for tug in ['lemma', 'Hom', 'v', 'Cmp', 'Sem', 'resten']:
        if tagsets.get(tug):
            for tog in tagsets[tug]:
                yield tog


def compact_line(line_dict):
    """Remove unneeded white space from a lexc entry."""
    string_buffer = []

    if line_dict.get('exclam'):
        string_buffer.append(line_dict['exclam'])

    if line_dict.get('upper'):
        string_buffer.append(line_dict['upper'])

    if line_dict.get('divisor'):
        string_buffer.append(line_dict['divisor'])

    if line_dict.get('lower'):
        string_buffer.append(line_dict['lower'])

    if string_buffer:
        string_buffer.append(' ')

    string_buffer.append(line_dict['contlex'])

    if line_dict.get('translation'):
        string_buffer.append(' ')
        string_buffer.append(line_dict['translation'])

    string_buffer.append(' ;')

    if line_dict.get('comment'):
        string_buffer.append(' ')
        string_buffer.append(line_dict['comment'])

    return ''.join(string_buffer)


def parse_file(lexc_line):
    if not lexc_line.startswith('LEXICON') and not lexc_line.startswith('+'):
        line_dict = line2dict(lexc_line)
        if line_dict and '<' not in line_dict['upper'] and not line_dict.get(
                'exclam') and not line_dict['upper'].endswith('+') and '+' in line_dict['upper']:
            return sort_tags(line_dict)


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
        for line in fileinput.input(filename, inplace=True):
            try:
                huff = parse_file(line.rstrip())
                if huff is not None:
                    print(huff)
                else:
                    print(line, end='')
            except ValueError:
                print(line, end='')


if __name__ == '__main__':
    main()
