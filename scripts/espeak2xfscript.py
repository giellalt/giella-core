#!/usr/bin/env python3
# -*- coding:utf-8 -*-
# Copyright © 2021 UiT The Arctic University of Norway
# License: GPL3
'''Convert espeak pronunciation stuff to Xerox Finite State Morphology.'''

from argparse import ArgumentParser, FileType
import sys


def parse_center(s):
    '''parse center and return Xerox Regexp.'''
    xre = ' ' + ' '.join(s) + ' '
    xre = xre.replace(' - ', ' %- ')
    return xre


def parse_repl(s):
    '''parse replacement and return Xerox Regexp in IPA.'''
    xre = ' ' + ' '.join(s) + ' '
    xre = xre.replace(' | ', ' . ')  # prevent digraphs?
    xre = xre.replace(' % ', ' . ')  # unstressed syllable
    # SAMPA to IPA
    xre = xre.replace(' : ', ' ː ')  # IPA length mark
    xre = xre.replace(' & ', ' ɶ ')
    xre = xre.replace(' Y ', ' ʏ ')
    xre = xre.replace(' @ ', ' ə ')
    xre = xre.replace(' S ', ' ʃ ')
    xre = xre.replace(' R ', ' ʀ ')
    xre = xre.replace(' Z ', ' ʒ ')
    xre = xre.replace(' Y ', ' ʏ ')
    xre = xre.replace(' O ', ' ɔ ')
    xre = xre.replace(' P ', ' ʋ ')
    xre = xre.replace(' N ', ' ŋ ')
    xre = xre.replace(' I ', ' ɪ ')
    xre = xre.replace(' E ', ' ɛ ')
    xre = xre.replace(' A ', ' ɑ ')
    xre = xre.replace(' J \ ', ' ɟ ')
    return xre


def parse_context(s):
    '''parse context expression and return Xerox Regexp.'''
    xre = ' ' + ' '.join(s) + ' '
    xre = xre.replace(' _ ', ' .#. ')
    xre = xre.replace(' K ', ' NVOW ')
    xre = xre.replace(' C ', ' CONS ')
    xre = xre.replace(' C ', ' CONS ')
    xre = xre.replace(' @ ', ' SYLL ')
    xre = xre.replace(' X ', ' CGROUP ')
    xre = xre.replace(' A ', ' VOW ')
    xre = xre.replace(' D ', ' DIGIT ')
    xre = xre.replace(' _ ', ' .#. ')
    return xre


def parse_left(s):
    '''parse left context expression and return Xerox Regexp.'''
    xre = parse_context(s)
    xre = xre.replace(' @ ', ' USYLL ')
    xre = xre.replace(')', '')
    return xre


def parse_right(s):
    '''parse left context expression and return Xerox Regexp.'''
    xre = parse_context(s)
    xre = xre.replace('(', '')
    return xre


def main():
    '''CLI for espeak conversion script.'''
    a = ArgumentParser()
    a.add_argument('-i', '--input', metavar='INFILE', type=open,
                   dest='infile', help='source of analysis data')
    a.add_argument('-v', '--verbose', action='store_true',
                   help='print verbosely while processing')
    a.add_argument('-o', '--output', metavar='OUTFILE', dest='outfile',
                   help='print output into OUTFILE', type=FileType('w'))
    options = a.parse_args()
    if not options.infile:
        options.infile = sys.stdin
    if not options.outfile:
        options.outfile = sys.stdout
    print('! automatically converted espeak -> xfscript: ',
          options.infile.name, file=options.outfile)
    print('define toLower = [ A -> a,  B -> b, C -> c ] ;',
          file=options.outfile)
    print('define CONS = [b | c | d | f | g | h | j | k | l | m ' +
          '| n | p | q | r | s | t | v | w | x | z ] ; ! C in espeak',
          file=options.outfile)
    print('define VOW = [ a | e | i | o | u | y ] ; ! A in espeak',
          file=options.outfile)
    print('define SYLL = CONS* VOW+ CONS* ; ! @ in espeak',
          file=options.outfile)
    print('define USYLL = CONS* VOW+ CONS* ; ! & in espeak',
          file=options.outfile)
    print('define NVOW = \\VOW ; ! K in espeak', file=options.outfile)
    print('define DIGIT = [ %0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 ] ; ' +
          '! D in espeak', file=options.outfile)
    print('define CGROUP = [ .#. CONS* | CONS* .#. ] ; ! X in espeak',
          file=options.outfile)
    output = ''
    groups = list()
    first = True
    for line in options.infile:
        line = line.strip()
        if not line or line == '':
            print(file=options.outfile)
        elif line.startswith('.group'):
            if output:
                print(output, ';', file=options.outfile)
            groupname = line[1:].replace(' ', '')
            output = 'define ' + groupname + ' = '
            groups += [groupname]
            first = True
        elif line.startswith('//'):
            print(line.replace('//', '!'), file=options.outfile)
        elif line.startswith('.L'):
            comment = ''
            if '//' in line:
                comment = '! ' + line[line.find('//'):].strip()
                line = line[:line.find('//')]
            else:
                line = line.strip()
            print('define ' + line[1:4] + ' =  [ ' +
                  ' | '.join(line[4:].split()) + ' ] ; ' + comment,
                  file=options.outfile)
        elif len(line.split()) > 1:
            fields = line.split()
            left = ''
            right = ''
            center = '?'
            repl = '?'
            comment = ''
            if fields[0].endswith(')'):
                left = parse_left(fields[0])
                center = parse_center(fields[1])
                if len(fields) > 2 and fields[2].startswith('('):
                    right = parse_right(fields[2])
                    if len(fields) > 3:
                        repl = parse_repl(fields[3])
                        if len(fields) > 4 and fields[4].startswith('//'):
                            comment = '! ' + ' '.join(fields[5:])
                        elif len(fields) > 4:
                            print('unknown field 5:', fields[4], fields)
                            sys.exit(1)
                    else:
                        print('expecting more stuff 3:', fields)
                        sys.exit(1)
                elif len(fields) > 2:
                    right = ''
                    repl = parse_repl(fields[2])
                    if len(fields) > 3 and fields[3].startswith('//'):
                        comment = '! ' + ' '.join(fields[4:])
                    elif len(fields) > 3:
                        print('unknown field 3:', fields[3], fields)
                else:
                    print('expecting more stuff 2:', fields)
                    sys.exit(1)
            else:
                left = ''
                center = parse_center(fields[0])
                if len(fields) > 1 and fields[1].startswith('('):
                    right = parse_right(fields[1])
                    if len(fields) > 2:
                        repl = parse_repl(fields[2])
                        if len(fields) > 3 and fields[3].startswith('//'):
                            comment = '! ' + ' '.join(fields[4:])
                        elif len(fields) > 3:
                            print('unknown field 4:', fields[3], fields)
                            sys.exit(1)
                    else:
                        print('expecitng more stuff 1:', fields)
                elif len(fields) > 1:
                    repl = parse_repl(fields[1])
                else:
                    print('logic error')
                    sys.exit(1)
            if not first:
                output += '.o.\n'
            if left or right:
                output += '[ ' + center + ' -> ' + repl \
                    + ' || ' + left + ' _ ' + right + \
                    ' ]  ' + comment + '\n'
            else:
                output += '[ ' + center + ' -> ' + repl \
                    + ' ]  ' + comment + '\n'
            first = False
        else:
            print('unexpected:', line.strip())
            sys.exit(1)
    if output:
        print(output, ';', file=options.outfile)
    print('read regex [', file=options.outfile)
    print('    toLower', file=options.outfile)
    for group in groups:
        print('.o.', group, file=options.outfile)
    print('] ;', file=options.outfile)
    sys.exit(0)


if __name__ == '__main__':
    main()
