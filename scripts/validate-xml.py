#!/usr/bin/env python3
'''Check if forrest docs are wellformed and that the addresses are correct'''
import os
import re
import sys

import lxml.etree as etree

from corpustools import util


def is_correct_link(link_content, filename, xdocs_dir):
    return (
        re.match('''\d+''', link_content) or
        'static_files' in link_content or
        link_content.startswith('http://') or
        link_content.startswith('https://') or
        link_content.startswith('mailto:') or
        link_content.startswith('news:') or
        link_content.startswith('ftp://') or
        link_content.startswith('svn://') or
        link_content.startswith('see://') or
        jspwiki_file_exists(link_content, filename, xdocs_dir)
    )


def jspwiki_file_exists(link_content, filename, xdocs_dir):
    #util.print_frame(link_content)
    link_content = link_content.split('#')[0].strip()
    link_content = link_content.replace('slidy/', '')
    if link_content and link_content != '/' and not link_content.startswith('cgi'):
        #util.print_frame(link_content)
        dirname = os.path.dirname(os.path.abspath(filename))
        if link_content.startswith('/'):
            dirname = xdocs_dir
            link_content = link_content[1:]

        return is_forrest_file(os.path.normpath(os.path.join(dirname, link_content)))
    else:
        return True


def is_forrest_file(normpath):
    ext_replacements = []
    #util.print_frame(normpath)

    (normpath, ext) = os.path.splitext(normpath)
    #util.print_frame(normpath, '\n')
    ext_replacements.append(ext)
    if ext in ['.html', '.pdf']:
        ext_replacements.append('.jspwiki')
        ext_replacements.append('.xml')
        ext_replacements.append('.pdf')
        ext_replacements.append('.en' + ext)
        ext_replacements.append('.en' + '.jspwiki')
        ext_replacements.append('.en' + '.xml')
        ext_replacements.append('.en' + '.pdf')


    for r in ext_replacements:
        if os.path.exists(normpath + r):
            return True
    else:
        return False


def check_xml_file(filename, xdocs_dir):
    '''Check if xml file is wellformed and valid'''
    errors = 0
    for a in get_tree(filename).iter('a'):
        if not is_correct_link(a.get('href').strip(), filename, xdocs_dir):
            errors += 1
            util.print_frame('{} :#{}: wrong address {}\n'.format(filename, a.sourceline, a.get('href')))

    return errors


def get_tree(filename):
    try:
        return etree.parse(filename)
    except etree.XMLSyntaxError as e:
        util.print_frame(filename, 'is not wellformed\nError:', e)


def parse_site(xdocs_dir):
    filename = os.path.join(xdocs_dir, 'site.xml')
    site = get_tree(filename)
    get_site_href(site.getroot(), xdocs_dir, filename)


def get_site_href(element, directory, filename):
    href = element.get('href')

    if href is not None:
        if element.tag == '{http://www.w3.org/2001/XInclude}include':
            parts = href.split('#')
            site_dirname = os.path.dirname(filename)
            site_filename = os.path.join(site_dirname, parts[0])
            try:
                site = get_tree(site_filename)
                if len(parts) == 2:
                    for element in site.xpath(re.match('xpointer\((.+)\)', parts[1]).group(1)):
                        get_tabs_href(element, directory, site_filename)
                elif len(parts) == 1:
                    get_site_href(site.getroot(), directory, site_filename)
            except OSError as e:
                util.print_frame('{}: #{}: {} {} does not exist'.format(filename, element.sourceline, etree.tostring(element, encoding='unicode'), site_filename))
        else:
            if href.endswith('.html') and not href.startswith('cgi') and not href.startswith('http'):
                if not is_forrest_file(os.path.join(directory, href)):
                    util.print_frame('{} :#{}: wrong address {}\n'.format(filename, element.sourceline, os.path.join(directory, href)))
            else:
                directory = os.path.join(directory, href)

    if len(element):
        for node in element:
            get_site_href(node, directory, filename)


def get_tabs_href(element, directory, filename):
    try:
        href = os.path.join(directory, element.get('dir'),
                            element.get('indexfile'))
        if not is_forrest_file(href):
            util.print_frame('{} :#{}: {} wrong address {}\n'.format(filename, element.sourceline, etree.tostring(element, encoding='unicode'), os.path.join(directory, href)))
    except TypeError as e:
        try:
            element.attrib['href']
        except KeyError:
            util.print_frame(e, etree.tostring(element, encoding='unicode'), element.sourceline, filename)

def parse_tabs(xdocs_dir):
    filename = os.path.join(xdocs_dir, 'tabs.xml')
    tabs = get_tree(filename)
    for element in tabs.getroot().iter('tab'):
        get_tabs_href(element, xdocs_dir, filename)
    for element in tabs.getroot().iter('{http://www.w3.org/2001/XInclude}include'):
        parts = element.get('href').split('#')
        include_name = os.path.join(xdocs_dir, parts[0])
        tabs = etree.parse(os.path.join(xdocs_dir, parts[0]))
        if len(parts) == 2:
            for element in tabs.xpath(re.match('xpointer\((.+)\)', parts[1]).group(1)):
                get_tabs_href(element, xdocs_dir, include_name)
        elif len(parts) == 1:
            for element in tabs.getroot().iter('tab'):
                get_tabs_href(element, xdocs_dir, include_name)


def main():
    sites = {
        'divvun': 'xtdoc/divvun/src/documentation/content/xdocs',
        'gtuit': 'xtdoc/gtuit/src/documentation/content/xdocs',
        'techdoc': 'xtdoc/techdoc/src/documentation/content/xdocs',
        'ped': 'ped/userdoc',
        'dicts': 'xtdoc/dicts/src/documentation/content/xdocs',
        'divvun.org': 'xtdoc/divvun.org/src/documentation/content/xdocs',
    }
    errors = 0
    no_files = 0

    sites_to_check = sites if len(sys.argv) == 1 else sys.argv[1:]

    for site in sites_to_check:
        fullpath = os.path.join(os.getenv('GTHOME'), sites[site])
        parse_site(fullpath)
        parse_tabs(fullpath)
        for root, dirs, files in os.walk(fullpath, followlinks=True):
            for f in files:
                no_files += 1
                path = os.path.join(root, f)
                if f.endswith('.xml') and 'obsolete' not in path and '/cgi' not in path and 'uped/' not in path:
                    errors += check_xml_file(path, fullpath)

    util.print_frame(errors)
    return errors


if __name__ == "__main__":
    sys.exit(main())
