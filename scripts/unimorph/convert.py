#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Test unimorph compatibility
"""


from argparse import ArgumentParser, FileType
from sys import stderr, stdout, stdin
from time import perf_counter, process_time

import sys


def giella2unimorph(tags):
    unimorphtags = []
    for giella in tags.split('+'):
        if giella == '':
            continue
        elif giella == 'N':
            if 'Prop' in tags:
                unimorphtags += ['PROPN']
            else:
                unimorphtags += ['N']
        elif giella == 'Pcle':
            unimorphtags += ['PART']
        elif giella == 'Adv':
            unimorphtags += ['ADV']
        elif giella == 'Num':
            unimorphtags += ['NUM']
        elif giella == 'Po':
            unimorphtags += ['ADP']
        elif giella == 'Pr':
            unimorphtags += ['ADP']
        elif giella == 'A':
            unimorphtags += ['ADJ']
        elif giella == 'Interj':
            unimorphtags += ['INTJ']
        elif giella == 'CC':
            unimorphtags += ['CONJ']
        elif giella == 'CS':
            unimorphtags += ['CONJ']
        elif giella == 'Pron':
            unimorphtags += ['PRO']
        elif giella == 'Neu':
            unimorphtags += ['NEUT']
        elif giella == 'Fem':
            unimorphtags += ['FEM']
        elif giella == 'Msc':
            unimorphtags += ['MASC']
        elif giella == 'Common':
            unimorphtags += ['MASC+FEM']
        elif giella == 'Gen':
            unimorphtags += ['GEN']
        elif giella == 'Com':
            unimorphtags += ['COM']
        elif giella == 'Com/Sh':
            unimorphtags += ['COM', 'XXXhyphen']
        elif giella == 'Ses':
            unimorphtags += ['ON+ESS']
        elif giella == 'Ess':
            unimorphtags += ['FRML']  # XXX: ESS?
        elif giella == 'Inan':
            unimorphtags += ['INAN']
        elif giella == 'Anim':
            unimorphtags += ['ANIM']
        elif giella == 'Abe':
            unimorphtags += ['PRIV']  # XXX: ABE?
        elif giella == 'Par':
            unimorphtags += ['PRT']
        elif giella == 'Ins':
            unimorphtags += ['INS']
        elif giella == 'Ine':
            unimorphtags += ['IN+ESS']
        elif giella == 'Nom':
            unimorphtags += ['NOM']
        elif giella == 'Sub':
            unimorphtags += ['ON+ALL']
        elif giella == 'All':
            unimorphtags += ['AT+ALL']  # XXX: ALL? C.f. Lat
        elif giella == 'Lat':
            unimorphtags += ['ALL']     # XXX: C.f. All
        elif giella == 'Loc':
            unimorphtags += ['PRP']
        elif giella == 'Inst':
            unimorphtags += ['INST']
        elif giella == 'Tra':
            unimorphtags += ['TRANS']
        elif giella == 'Prl':
            unimorphtags += ['PROL']
        elif giella == 'Temp':
            unimorphtags += ['LGSPEC3']
        elif giella == 'Del':
            unimorphtags += ['ON+ABL']
        elif giella == 'Ela':
            unimorphtags += ['IN+ABL']
        elif giella == 'Ill':
            unimorphtags += ['IN+ALL']
        elif giella == 'Dat':
            unimorphtags += ['DAT']
        elif giella == 'Acc':
            unimorphtags += ['ACC']
        elif giella == 'Ade':
            unimorphtags += ['AT+ESS']
        elif giella == 'Abl':
            unimorphtags += ['AT+ABL']
        elif giella == 'Sg':
            unimorphtags += ['SG']  # XXX: we want to generate one at least
        elif giella == 'Du':
            unimorphtags += ['DU']
        elif giella == 'Pl':
            unimorphtags += ['PL']
        elif giella == 'SP':
            unimorphtags += ['SG']
        elif giella == 'Indic':
            unimorphtags += ['IND']
        elif giella == 'Ind':
            unimorphtags += ['IND']  # XXX: can sometimes be indef?
        elif giella == 'Prs':
            unimorphtags += ['PRS']
        elif giella == 'Prt':
            unimorphtags += ['PST']
        elif giella == 'Prt1':
            unimorphtags += ['PST']
        elif giella == 'Prt2':
            unimorphtags += ['PST']
        elif giella == 'Perf':
            unimorphtags += ['PRF']
        elif giella == 'Fut':
            unimorphtags += ['FUT']
        elif giella == 'Sg1':
            unimorphtags += ['1', 'SG']
        elif giella == 'Sg2':
            unimorphtags += ['2', 'SG']
        elif giella == 'Sg3':
            unimorphtags += ['3', 'SG']
        elif giella == 'Du1':
            unimorphtags += ['1', 'DU']
        elif giella == 'Du2':
            unimorphtags += ['2', 'DU']
        elif giella == 'Du3':
            unimorphtags += ['3', 'DU']
        elif giella == 'Pl1':
            unimorphtags += ['1', 'PL']
        elif giella == 'Pl2':
            unimorphtags += ['2', 'PL']
        elif giella == 'Pl3':
            unimorphtags += ['3', 'PL']
        elif giella == 'ScSg1':
            unimorphtags += ['ARGNO1S']
        elif giella == 'ScSg2':
            unimorphtags += ['ARGNO2S']
        elif giella == 'ScSg3':
            unimorphtags += ['ARGNO3S']
        elif giella == 'ScPl1':
            unimorphtags += ['ARGNO1S']
        elif giella == 'ScPl2':
            unimorphtags += ['ARGNO2S']
        elif giella == 'ScPl3':
            unimorphtags += ['ARGNO3S']
        elif giella == 'OcSg1':
            unimorphtags += ['ARGAC1S']
        elif giella == 'OcSg2':
            unimorphtags += ['ARGAC2S']
        elif giella == 'OcSg3':
            unimorphtags += ['ARGAC3S']
        elif giella == 'OcPl1':
            unimorphtags += ['ARGAC1S']
        elif giella == 'OcPl2':
            unimorphtags += ['ARGAC2S']
        elif giella == 'OcPl3':
            unimorphtags += ['ARGAC3S']
        elif giella == 'PxSg1':
            unimorphtags += ['PSS1S']
        elif giella == 'PxSg2':
            unimorphtags += ['PSS2S']
        elif giella == 'PxSg3':
            unimorphtags += ['PSS3S']
        elif giella == 'PxDu1':
            unimorphtags += ['PSS1D']
        elif giella == 'PxDu2':
            unimorphtags += ['PSS2D']
        elif giella == 'PxDu3':
            unimorphtags += ['PSS3D']
        elif giella == 'PxPl1':
            unimorphtags += ['PSS1P']
        elif giella == 'PxPl2':
            unimorphtags += ['PSS2P']
        elif giella == 'PxPl3':
            unimorphtags += ['PSS3P']
        elif giella == 'PxSP3':
            unimorphtags += ['PSS3']
        elif giella == 'Def':
            unimorphtags += ['DEF']
        elif giella == 'Indef':
            unimorphtags += ['NDEF']
        elif giella == 'V':
            if '+PrsPrc' in tags:
                unimorphtags += ['V.PTCP']
            elif '+PrtPrc' in tags:
                unimorphtags += ['V.PTCP']
            elif '+PrfPrc' in tags:
                unimorphtags += ['V.PTCP']
            else:
                unimorphtags += ['V']
        elif giella == 'PrsPrc':
            unimorphtags += ['PRS']
        elif giella == 'PrtPrc':
            unimorphtags += ['PST']
        elif giella == 'PrfPrc':
            unimorphtags += ['PRFV']
        elif giella == 'Prc/Telic':
            unimorphtags += ['LFSPEC4/telic']  # myv
        elif giella == 'VGen':
            unimorphtags += ['V.GEN']
        elif giella == 'VAbess':
            unimorphtags += ['V.ABE']
        elif giella == 'NomAg':
            continue  # FIXME
        elif giella == 'Inf':
            unimorphtags += ['NFIN']
        elif giella == 'Ger':
            unimorphtags += ['NFIN']  # XXX: GER?
        elif giella == 'Actio':
            unimorphtags += ['GER']  # XXX: ???
        elif giella == 'Actv':
            unimorphtags += ['ACT']
        elif giella == 'Pasv':
            unimorphtags += ['PASS']
        elif giella == 'Cond':
            unimorphtags += ['COND']
        elif giella == 'Pot':
            unimorphtags += ['POT']
        elif giella == 'Imprt':
            unimorphtags += ['IMP']
        elif giella == 'Subj':
            unimorphtags += ['SBJV']
        elif giella == 'Opt':
            unimorphtags += ['OPT']  # Desiderative optative
        elif giella == 'Des':
            unimorphtags += ['OPT']  # Desiderative optative
        elif giella == 'Oblig':
            unimorphtags += ['OBGLIG']  # Desiderative optative
        elif giella == 'Interr':
            unimorphtags += ['INT']  # XXX: ABE?
        elif giella == 'Der/Comp':
            unimorphtags += ['CMPR']
        elif giella == 'Comp':
            unimorphtags += ['CMPR']
        elif giella == 'Sup':
            unimorphtags += ['SPRL']
        elif giella == 'Der/Superl':
            unimorphtags += ['SPRL']
        elif giella == 'Der/PassS':
            unimorphtags += ['PASS']
        elif giella == 'Attr':
            unimorphtags += ['ATTR']
        elif giella == 'Neg':
            unimorphtags += ['NEG']
        elif giella == 'Pos':
            unimorphtags += ['POS']
        elif giella.startswith('Err/'):
            unimorphtags += ['TYPO']
        elif giella.startswith('Der/'):
            unimorphtags += ['XXXDER' + giella[4:]]
            continue  # NB: handle SOME ders before this
        elif giella == 'Allegro':
            continue
        elif giella == 'ACR':
            continue
        elif giella == 'Coll':
            continue
        elif giella == 'Qst':
            unimorphtags += ['LGSPEC1/?']
        elif giella == 'Subqst':
            continue
        elif giella == 'Rel':
            continue  # is not: Relative case or Relative comparator
        elif giella == 'Ord':
            continue
        elif giella in ['v1', 'v2', 'v3']:
            continue
        elif giella in ['G3', 'G7']:
            continue
        elif giella.startswith('Sem'):
            continue
        elif giella == 'Prop':
            continue  # handled elsehwere
        elif giella.startswith('Cmp'):
            unimorphtags += ['XXXCOMPOUND']
            continue  # ?
        elif giella == 'Dial':
            unimorphtags += ['DIAL']
        elif giella == 'South':
            unimorphtags += ['DIAL?']
        elif giella == 'ConNeg':
            unimorphtags += ['NEG']  # XXX
        elif giella == 'ConNegII':
            unimorphtags += ['NEG']  # XXX
        elif giella == 'IV':
            # continue  # not marked in current unimorph
            unimorphtags += ['INTR']
        elif giella == 'TV':
            # continue  # not marked in current unimorph
            unimorphtags += ['TR']
        elif giella == 'Recipr':
            unimorphtags += ['RECP']
        elif giella == 'Bahuvrihi':
            # myv
            continue
        elif giella == 'Adn':
            # myv
            continue
        elif giella == 'Conj':
            # myv
            continue
        elif giella == 'Prec':
            # myv
            continue
        elif giella == 'Dem':
            continue  #  FIXME
        elif giella == 'Pers':
            continue  #  FIXME
        elif giella.startswith('Foc/'):
            unimorphtags += ['LGSPEC1/' + giella[5:]]
        elif giella.startswith('Clt/'):
            unimorphtags += ['LGSPEC2/' + giella[5:]]
        elif giella.startswith('OLang/'):
            continue
        elif giella.startswith('Gram/3syll'):
            continue
        elif giella.startswith('Gram/Comp'):
            continue
        elif giella.startswith('Genmiessi'):
            print("SOmething broken here½!")
        else:
            print("missing giella mapping for", giella, "in tags")
            sys.exit(2)
    # shuffle and patch
    CASESWITHOUTNUMBERS = ['FRML', 'COM']
    for casetag in CASESWITHOUTNUMBERS:
        if casetag in unimorphtags and 'SG' not in unimorphtags and\
                'PL' not in unimorphtags:
            unimorphtags += ['SG']
    MOODSWITHEXTRATENSE = ['COND', 'POT']
    for mood in MOODSWITHEXTRATENSE:
        if mood in unimorphtags and 'PRS' in unimorphtags:
            unimorphtags.remove('PRS')
        elif mood in unimorphtags and 'PST' in unimorphtags:
            unimorphtags.remove('PST')
    return ';'.join(unimorphtags)


def main():
    """Command-line interface for omorfi's sort | uniq -c tester."""
    a = ArgumentParser()
    a.add_argument('-i', '--input', metavar='INFILE', type=open,
                   dest='infile', help='source of analysis data')
    a.add_argument('-o', '--output', metavar='OUTFILE',
                   type=FileType('w'),
                   dest='outfile', help='log outputs to OUTFILE')
    a.add_argument('-v', '--verbose', action='store_true', default=False,
                   help='Print verbosely while processing')
    a.add_argument('-C', '--no-casing', action='store_true', default=False,
                   help='Do not try to recase input and output when matching')
    a.add_argument('-t', '--threshold', metavar='THOLD', default=99,
                   help='if coverage is less than THOLD exit with error')
    options = a.parse_args()
    if not options.infile:
        options.infile = stdin
        print('reading from <stdin>')
    if not options.outfile:
        options.outfile = stdout
    lines = 0
    # for make check target
    realstart = perf_counter()
    cpustart = process_time()
    skip_lgspec = True
    skip_typo = True
    skip_xxx = True
    for line in options.infile:
        fields = line.strip().split(':')
        if line.strip() == '':
            continue
        if len(fields) < 2:
            print('ERROR: Skipping line', fields, file=stderr)
            continue
        if ' ' in fields[1] or ' ' in fields[0]:
            continue
        lines += 1
        if options.verbose and lines % 1000 == 0:
            print(lines, '...')
        giella = fields[0]
        lemma = giella.split('+')[0]
        giellatags = giella[giella.find('+'):]
        surf = fields[1]
        unimorph = giella2unimorph(giellatags)
        if skip_lgspec and 'LGSPEC' in unimorph:
            continue
        if skip_typo and 'TYPO' in unimorph:
            continue
        if skip_xxx and 'XXX' in unimorph:
            continue
        print(lemma, surf, unimorph, sep='\t', file=options.outfile)
    realend = perf_counter()
    cpuend = process_time()
    print('CPU time:', cpuend - cpustart, 'real time:', realend - realstart)
    sys.exit(0)


if __name__ == '__main__':
    main()
