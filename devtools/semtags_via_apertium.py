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
from typing import Dict, Iterator, List, Tuple

from lxml import etree
from lxml.etree import _ElementTree

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
"""Regex that catches lexc lines."""

TAG = re.compile(r'''\+[^+]+''')
COUNTER = defaultdict(int)


def lexc_name(lang: str, pos: str) -> str:
    """Compile lexc name.

    Args:
        lang: the wanted language.
        pos: the wanted part of speech.

    Returns:
        Path to the wanted lexc file.
    """
    filename = 'nouns.lexc' if pos == 'n' else 'adjectives.lexc'
    return os.path.join(
        os.getenv('GTHOME'), 'langs', lang, 'src/morphology/stems/', filename)


def extract_sem_tags(upper: str) -> List[str]:
    """Extract semantic tags from the upper part of a lexc line.

    Args:
        upper: the string to the left of the colon of a lexc line

    Returns:
        A list of strings containing the semantic tags.
    """
    return [
        tag for tag in TAG.findall(upper)
        if tag.startswith('+Sem') and tag != '+Sem/Dummytag'
    ]


def extract_nonsem_tags(upper: str) -> List[str]:
    """Extract non semantic tags from the upper part of a lexc line.

    Args:
        upper: the string to the left of the colon of a lexc line

    Returns:
        A list of strings containing the non semantic tags.
    """
    return [tag for tag in TAG.findall(upper) if not tag.startswith('+Sem')]


def lang_tags(lang: str, pos: str) -> Iterator[Tuple[str, List[str]]]:
    """Extract lemma and tags from the upper part of a lexc expression.

    Args:
        lang: the language where the lemma and semtags is extracted.
        pos: the part of speech of the wanted lemmas and semtags

    Yields:
        A tuple containing the lemma and its semtags.
    """
    for line in open(lexc_name(lang, pos)):
        lexc_match = LEXC_LINE_RE.match(line.replace('% ', '%¥'))
        if lexc_match:
            upper = lexc_match.group('upper').replace('%¥', '% ')
            sem_tags = extract_sem_tags(upper)

            if sem_tags:
                new_upper = TAG.sub('', upper)
                yield new_upper, sem_tags


def possible_smx_tags(lang1: str, pos: str,
                      tree: _ElementTree) -> Iterator[Tuple[str, List[str]]]:
    """Transfer sme semtags to smX lemma.

    Args:
        lang1: the language where the semtags should be fetched.
        pos: part of speech of the lemmas.
        tree: an etree containing the content of a apertium bidix file.

    Yields:
        A tuple containing a lemma of the other language and the
        semtags of the corresponding lang1 lemma.
    """
    # TODO: Merge semtags
    # Extract lemma: tags from sme .lexc file
    sme_sem_tag = {word: sem_tags for word, sem_tags in lang_tags(lang1, pos)}

    # Iterate through all lemmas in bidix where n = pos
    for symbol in tree.xpath('.//p/l/s[@n="{}"]'.format(pos)):
        # Get the bidix p element
        pair = symbol.getparent().getparent()
        # Extract sem_tags for the sme word
        sem_tags = sme_sem_tag.get(pair.find('l').text)
        if sem_tags and pair.find('r').text is not None:
            # Extract the smX lemma, add the sme semtags to it
            yield (pair.find('r').text, sorted(sem_tags))


def groupdict_to_line(groupdict: Dict[str, str]) -> str:
    """Turn the lexc groupdict into a lexc line.

    Args:
        groupdict: the dict produced in add_semtags

    Returns:
        A lexc string
    """
    return ''.join([
        groupdict[key] for key in [
            'upper', 'colon', 'lower', 'contlex_space', 'contlex',
            'translation', 'semicolon', 'comment'
        ] if groupdict.get(key)
    ])


def add_semtags(line: str, smx: Dict[str, List[str]]):
    """Add semtags to non sme languages.

    Args:
        line: a lexc line.
        smx: the smx lemma: semtags from sme dictionary

    Returns:
        Either the amended line or the original one.
    """
    global COUNTER

    lexc_match = LEXC_LINE_RE.match(line.replace('% ', '%¥'))

    if lexc_match:
        # TODO: If tags_via_apertium exists, update sem tags
        COUNTER['possible_lines'] += 1
        groupdict = lexc_match.groupdict()
        upper = groupdict['upper']

        tags = extract_nonsem_tags(upper)
        sem_tags = extract_sem_tags(upper)
        tag_free_upper = TAG.sub('', upper).replace('%¥', '% ')
        if groupdict.get('lower'):
            groupdict['lower'] = groupdict['lower'].replace('%¥', '% ')
        else:
            groupdict['colon'] = ':'
            groupdict['lower'] = tag_free_upper

        if sem_tags and smx.get(
                tag_free_upper) and sem_tags != smx.get(tag_free_upper):
            COUNTER['conflicting_semtags'] += 1
            if groupdict.get('comment'):
                groupdict['comment'] = groupdict.get(
                    'comment') + ' tags_via_apertium northsami was {}'.format(
                        ''.join(smx.get(tag_free_upper)))
            else:
                groupdict[
                    'comment'] = ' ! tags_via_apertium northsami was {}'.format(
                        ''.join(smx.get(tag_free_upper)))

            return groupdict_to_line(groupdict)

        if sem_tags:
            COUNTER['already_has_semtags'] += 1
            return groupdict_to_line(groupdict)

        if smx.get(tag_free_upper) and not sem_tags:
            COUNTER['added_semtags'] += 1
            tags.extend(smx.get(tag_free_upper))

            groupdict['upper'] = ''.join([tag_free_upper, ''.join(tags)])

            if groupdict.get('comment'):
                groupdict['comment'] = groupdict.get(
                    'comment') + ' tags_via_apertium'
            else:
                groupdict['comment'] = ' ! tags_via_apertium'

            return groupdict_to_line(groupdict)

        if '+Sem/Dummytag' not in line:
            COUNTER['added_dummy'] += 1
            tags.append('+Sem/Dummytag')
            groupdict['upper'] = ''.join([tag_free_upper, ''.join(tags)])

            return groupdict_to_line(groupdict)

        if '+Sem/Dummytag' in line:
            COUNTER['has_dummy_nothing_added'] += 1
            return groupdict_to_line(groupdict)

    return line


def main() -> None:
    """Via apertium bidix files, add semtags found in sme to smx."""
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
    main()
