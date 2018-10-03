#!/usr/bin/env python3
"""Copy semtag from sme to other languages."""

import fileinput
import os
import re
import sys
from collections import defaultdict

from lxml import etree

LEXC_LINE_RE = re.compile(
    r'''
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
COUNTER = 0


def lexc_name(lang, pos):
    filename = 'nouns.lexc' if pos == 'n' else 'adjectives.lexc'
    return os.path.join(
        os.getenv('GTHOME'), 'langs', lang, 'src/morphology/stems/', filename)


def lexc_matches(lang, pos):
    for line in open(lexc_name(lang, pos)):
        lexc_match = LEXC_LINE_RE.match(line.replace('% ', '%¥'))
        if lexc_match:
            yield lexc_match


def valid_upper_lower(lang, pos):
    for lexc_match in lexc_matches(lang, pos):
        groupdict = lexc_match.groupdict()

        if not groupdict.get('exclam') and groupdict.get('content'):
            content = groupdict.get('content').replace('%¥', '% ')
            lexc_line_match = content.find(':')

            if (not (content.startswith('<') and content.endswith('>'))
                    and lexc_line_match != -1):
                yield (content[:lexc_line_match], content[lexc_line_match:])


def lang_tags(lang, pos):
    for upper, lower in valid_upper_lower(lang, pos):
        sem_tags = [
            tag for tag in TAG.findall(upper)
            if tag.startswith('+Sem') and tag != '+Sem/Dummytag'
        ]
        if sem_tags:
            new_upper = TAG.sub('', upper)
            yield new_upper, sem_tags


def possible_smx_tags(lang1, pos, tree):
    sme_sem_tag = {word: sem_tags for word, sem_tags in lang_tags(lang1, pos)}

    for s in tree.xpath('.//p/l/s[@n="{}"]'.format(pos)):
        p = s.getparent().getparent()
        sem_tags = sme_sem_tag.get(p.find('l').text)
        if sem_tags:
            yield (p.find('r').text, sorted(sem_tags))


def is_interesting_line(line, smx):
    global COUNTER

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

                tags = [
                    tag for tag in TAG.findall(upper) if tag != '+Sem/Dummytag'
                ]
                sem_tags = [tag for tag in tags if tag.startswith('+Sem')]

                tag_free_upper = TAG.sub('', upper)
                if sem_tags and smx.get(
                        tag_free_upper
                ) and sem_tags != smx.get(tag_free_upper):
                    print(
                        line,
                        sem_tags,
                        smx.get(tag_free_upper),
                        file=sys.stderr)

                if smx.get(tag_free_upper) and not len(sem_tags):
                    COUNTER += 1
                    tags.extend(smx.get(tag_free_upper))

                    new_parts = [tag_free_upper, ''.join(tags), lower]
                    new_parts.extend([
                        groupdict[key] for key in [
                            'contlex_space', 'contlex', 'translation',
                            'semicolon', 'comment'
                        ] if groupdict.get(key)
                    ])

                    return ''.join(new_parts)

    return line


def main():
    path = sys.argv[1]

    lang1, lang2 = os.path.basename(path).split('.')[1].split('-')
    tree = etree.parse(path)

    print(lang1, lang2)

    total = 0
    for pos in ['n', 'adj']:
        smx = {
            smx_lemma: tags
            for smx_lemma, tags in possible_smx_tags(lang1, pos, tree)
        }
        total += len(smx)
        for line in fileinput.input(lexc_name(lang2, pos), inplace=True):
            print(
                is_interesting_line(line[:-1] if line[-1] == '\n' else line,
                                    smx))

    print('hits', COUNTER, 'of', total)


if __name__ == '__main__':
    main()
