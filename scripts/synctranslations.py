#!/usr/bin/env python3
# -*- coding:utf-8 -*-

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
#   Copyright © 2017 The University of Tromsø
#   http://divvun.no & http://giellatekno.uit.no
#

"""Synchronise translation files from site.xml and tabs.xml."""

import os

from lxml import etree


class TranslationFile(object):

    """Represent a forrest translation file."""

    def __init__(self, category, lang):
        divvun_translations = os.path.join(
            os.getenv('GTHOME'), 'xtdoc/divvun/src/documentation/translations')
        name = category if category == 'tabs' else 'menu'
        self.filename = os.path.join(
            divvun_translations, '{}_{}.xml'.format(name, lang))
        self.translation_tree = etree.parse(self.filename)

    @property
    def keys(self):
        return [key.get('key')
                for key in self.translation_tree.xpath('.//message')]

    @property
    def catalogue(self):
        return self.translation_tree.getroot()

    def write(self):
        for message in self.translation_tree.getroot().iter('message'):
            message.tail = '\n  '
        self.translation_tree.getroot()[-1].tail = '\n'

        with open(self.filename, 'wb') as translations:
            translations.write(etree.tostring(self.translation_tree,
                                              encoding='UTF-8',
                                              pretty_print='True',
                                              xml_declaration=True))

    def add_keys(self, main_keys):
        """Add new translation keys to the message catalogue."""
        for key in main_keys:
            if key not in self.keys:
                message = etree.SubElement(self.catalogue, 'message')
                message.text = key
                message.set('key', key)

    def comment_out_keys(self, main_keys):
        """Keep old translations in the message catalogue, but outcommented."""
        for message in self.catalogue.iter('message'):
            if message.get('key') not in main_keys:
                comment = etree.Comment(etree.tostring(message).strip())
                comment.tail = '\n  '
                message.getparent().replace(message, comment)


def synchronise(category):
    keys = get_keys(category)

    for lang in ['en', 'fi', 'no', 'se', 'sma', 'smj', 'sv']:
        menu_file = TranslationFile(category, lang)
        menu_file.comment_out_keys(keys)
        menu_file.add_keys(keys)
        menu_file.write()


def get_keys(category):
    tree = etree.parse(
        os.path.join(
            os.getenv('GTHOME'),
            'xtdoc/divvun/src/documentation/content/xdocs/{}.xml'.format(
                category)))

    if category == 'site':
        return [key.get('label')
                for key in tree.xpath('.//*[@label]')]
    else:
        return [key.get('id')
                for key in tree.xpath('.//tab[@id]')]


if __name__ == '__main__':
    for category in ['site', 'tabs']:
        synchronise(category)
