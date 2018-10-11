#!/usr/bin/env python3
"""Copy semtag from sme to other languages.

Clone apertium:
git clone git@github.com:apertium/apertium-sme-sma.git
git clone git@github.com:apertium/apertium-sme-smj.git
git clone git@github.com:apertium/apertium-sme-smn.git

Run it like this:

for lang in sma smj smn;
do
    $GTHOME/giella-core/devtools/tags_via_apertium.py apertium-sme-$lang/apertium-sme-$lang.sme-$lang.dix ;
done
"""

import fileinput
import os
import re
import sys
from collections import defaultdict

from lxml import etree

LEXC_LINE_RE = re.compile(
    r'''
    (?P<start>\s*)?       #  optional space
    (?P<upper>[\w\d%¥+/-]+)   #  optional upper
    (?P<colon>:)? #  optional colon
    (?P<lower>\S+)? # optional lower
    (?P<contlex_space>\s+)      #  space between content and contlex
    (?P<contlex>\S+)            #  any nonspace
    (?P<translation>\s+".*")?   #  optional translation, might be empty
    (?P<semicolon>\s*;\s*)      #  semicolon and space surrounding it
    (?P<comment>!.*)?           #  followed by an optional comment
    $
''', re.VERBOSE | re.UNICODE)

TAG = re.compile(r'''\+[^+]+''')
COUNTER = defaultdict(int)


def test_re():
    lines = [
        'al+Cmp/Sh+Err/CmpSub:al        Rreal ;',
        'al:al        Rreal ;',
        'al        Rreal ;',
        'a% l:a% l        Rreal ;',
        '!al:al        Rreal ;',
        '  !al:al        Rreal ;',
        '<al:al>        Rreal ;',
    ]

    for line in lines:
        lexc_match = LEXC_LINE_RE.match(line.replace('% ', '%¥'))
        if lexc_match:
            print(lexc_match.groupdict())
            print()
        else:
            print(line, 'failed')


def lexc_name(lang, pos):
    filename = 'nouns.lexc' if pos == 'n' else 'adjectives.lexc'
    return os.path.join(
        os.getenv('GTHOME'), 'langs', lang, 'src/morphology/stems/', filename)


def extract_sem_tags(upper):
    return [
        tag for tag in TAG.findall(upper)
        if tag.startswith('+Sem') and tag != '+Sem/Dummytag'
    ]


def extract_nonsem_tags(upper):
    return [tag for tag in TAG.findall(upper) if tag != '+Sem/Dummytag']


def lang_tags(lang, pos):
    """Extract lemma and tags from the upper part of a lexc expression."""
    for line in open(lexc_name(lang, pos)):
        lexc_match = LEXC_LINE_RE.match(line.replace('% ', '%¥'))
        if lexc_match:
            upper = lexc_match.group('upper').replace('%¥', '% ')
            sem_tags = extract_sem_tags(upper)

            if sem_tags:
                new_upper = TAG.sub('', upper)
                yield new_upper, sem_tags


def possible_smx_tags(lang1, pos, tree):
    """Transfer sme semtags to smX lemma.

    """
    # Extract lemma: tags from sme .lexc file
    sme_sem_tag = {word: sem_tags for word, sem_tags in lang_tags(lang1, pos)}

    # Iterate through all lemmas in bidix where n = pos
    for s in tree.xpath('.//p/l/s[@n="{}"]'.format(pos)):
        # Get the bidix p element
        p = s.getparent().getparent()
        # Extract sem_tags for the sme word
        sem_tags = sme_sem_tag.get(p.find('l').text)
        if sem_tags:
            # Extract the smX lemma, add the sme semtags to it
            yield (p.find('r').text, sorted(sem_tags))


def add_semtags(line, smx):
    global COUNTER

    lexc_match = LEXC_LINE_RE.match(line.replace('% ', '%¥'))

    if lexc_match:
        COUNTER['possible_lines'] += 1
        groupdict = lexc_match.groupdict()
        upper = groupdict['upper']
        if groupdict.get('lower'):
            groupdict['lower'] = groupdict['lower'].replace('%¥', '% ')

        tags = extract_nonsem_tags(upper)
        sem_tags = extract_sem_tags(upper)
        tag_free_upper = TAG.sub('', upper).replace('%¥', '% ')

        if sem_tags and smx.get(
                tag_free_upper) and sem_tags != smx.get(tag_free_upper):
            print(line, sem_tags, smx.get(tag_free_upper), file=sys.stderr)

        if sem_tags:
            COUNTER['already_has_semtags'] += 1

        if smx.get(tag_free_upper) and not len(sem_tags):
            COUNTER['changed_lines'] += 1
            tags.extend(smx.get(tag_free_upper))

            new_parts = [tag_free_upper, ''.join(tags)]
            new_parts.extend([
                groupdict[key] for key in [
                    'colon', 'lower', 'contlex_space', 'contlex',
                    'translation', 'semicolon'
                ] if groupdict.get(key)
            ])

            if groupdict.get('comment'):
                new_parts.append(groupdict.get('comment'))
            else:
                new_parts.append(' !')

            new_parts.append(' tags_via_apertium')
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
            print(add_semtags(line[:-1] if line[-1] == '\n' else line, smx))

    for key, value in COUNTER.items():
        print(key, value)
    print()


if __name__ == '__main__':
    #test_re()
    main()
