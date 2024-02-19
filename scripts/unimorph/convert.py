#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Test unimorph compatibility
"""


import sys
from argparse import ArgumentParser, FileType
from sys import stderr, stdin, stdout
from time import perf_counter, process_time


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
        elif giella == 'Det':
            unimorphtags += ['DET']
        elif giella == 'Part':
            unimorphtags += ['PART']
        elif giella == 'Pcle':
            unimorphtags += ['PART']
        elif giella == 'Adv':
            unimorphtags += ['ADV']
        elif giella == 'Num':
            unimorphtags += ['NUM']
        elif giella == 'Adp':
            unimorphtags += ['ADP']
        elif giella == 'Po':
            unimorphtags += ['ADP']
        elif giella == 'Pr':
            unimorphtags += ['ADP']
        elif giella == 'A':
            unimorphtags += ['ADJ']
        elif giella == 'Adj':
            unimorphtags += ['ADJ']
        elif giella == 'Intj':
            unimorphtags += ['INTJ']
        elif giella == 'Interj':
            unimorphtags += ['INTJ']
        elif giella == 'CC':
            unimorphtags += ['CONJ']
        elif giella == 'CS':
            unimorphtags += ['CONJ']
        elif giella == 'Punct':
            unimorphtags += ['PUNCT']
        elif giella == 'PUNCT':
            unimorphtags += ['PUNCT']
        elif giella == 'Symbol':
            continue
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
        elif giella == 'GenAttr':
            unimorphtags += ['GEN']
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
        elif giella == 'Instr':
            unimorphtags += ['INST']
        elif giella == 'Tra':
            unimorphtags += ['TRANS']
        elif giella == 'Exe':
            unimorphtags += ['LGSPEC/EXE']
        elif giella == 'Prl':
            unimorphtags += ['PROL']
        elif giella == 'Cmt':
            unimorphtags += ['COM']
        elif giella == 'Trm':
            unimorphtags += ['TERM']
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
        elif giella == 'SG':
            unimorphtags += ['SG']
        elif giella == 'Sg':
            unimorphtags += ['SG']
        elif giella == 'Du':
            unimorphtags += ['DU']
        elif giella == 'Pl':
            unimorphtags += ['PL']
        elif giella == 'SP':
            unimorphtags += ['SG']  # XXX: we want to generate one at least
        elif giella == 'Indic':
            unimorphtags += ['IND']
        elif giella == 'Ind':
            unimorphtags += ['IND']  # XXX: can sometimes be indef?
        elif giella == 'Prs':
            unimorphtags += ['PRS']
        elif giella == 'Past':
            unimorphtags += ['PST']
        elif giella == 'Prt':
            unimorphtags += ['PST']
        elif giella == 'Prt1':
            unimorphtags += ['PST']
        elif giella == 'Prt2':
            unimorphtags += ['PST']
        elif giella == 'Perf':
            unimorphtags += ['PRF']
        elif giella == 'Prog':
            unimorphtags += ['PROG']
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
        elif giella == 'Sg4':
            unimorphtags += ['4', 'SG']
        elif giella == '4':
            unimorphtags += ['4']
        elif giella == 'Pe4':
            unimorphtags += ['4']
        elif giella == 'Ips':
            unimorphtags += ['IMPRS']
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
        elif giella == 'Px3':
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
            elif '+ActPrsPrc' in tags:
                unimorphtags += ['V.PTCP']
            elif '+Prc' in tags:
                unimorphtags += ['V.PTCP']
            elif '+Ptcp' in tags:
                unimorphtags += ['V.PTCP']
            elif '+Cop' in tags:
                unimorphtags += ['AUX']
            else:
                unimorphtags += ['V']
        elif giella == 'Aux':
            unimorphtags += ['AUX']
        elif giella == 'PrsPrc':
            unimorphtags += ['PRS']
        elif giella == 'ActPrsPrc':
            unimorphtags += ['ACT', 'PRS']
        elif giella == 'PrtPrc':
            unimorphtags += ['PST']
        elif giella == 'PrfPrc':
            unimorphtags += ['PRFV']
        elif giella == 'Cop':
            continue  # AUX
        elif giella == 'Prc':
            continue  # V.PTCP before
        elif giella == 'Ptcp':
            continue  # V.PTCP before
        elif giella == 'Prc/Telic':
            unimorphtags += ['LGSPEC4/telic']  # myv
        elif giella == 'VGen':
            unimorphtags += ['V.MSDR', 'GEN']
        elif giella == 'VAbess':
            unimorphtags += ['V.CVB', 'ABE']
        elif giella == 'NomAg':
            unimorphtags += ['V.MSDR', 'LGSPEC/agent']
        elif giella == 'AgPrc':
            unimorphtags += ['V.PTCP', 'LGSPEC/agent']
        elif giella == 'NegPrc':
            unimorphtags += ['V.PTCP', 'NEG']
        elif giella == 'NomAct':
            unimorphtags += ['V.MSDR']
        elif giella == 'INF':
            unimorphtags += ['NFIN']
        elif giella == 'Inf':
            unimorphtags += ['NFIN']
        elif giella == 'Ger':
            unimorphtags += ['V.CVB', 'LGSPEC/ger']  # XXX: GER?
        elif giella == 'Actio':
            unimorphtags += ['V.MSDR', 'LGSPEC/actio']  # XXX: ???
        elif giella == 'Sup':
            unimorphtags += ['V.CVB', 'LGSPEC/sup']  # Supine, not superlative or superessive
        elif giella == 'InfA':
            unimorphtags += ['NFIN']  # fin
        elif giella == 'InfE':
            unimorphtags += ['V.CVB']  # fin
        elif giella == 'Inf3':
            unimorphtags += ['V.CVB']  # fkv
        elif giella == 'InfMa':
            unimorphtags += ['V.CVB']  # fin
        elif giella == 'A_Hum':
            unimorphtags += ['ADJ']  # fin?
        elif giella == 'Adv-':
            unimorphtags += ['ADV']
        elif giella == 'Actv':
            unimorphtags += ['ACT']
        elif giella == 'Act':
            unimorphtags += ['ACT']
        elif giella == 'Pasv':
            unimorphtags += ['PASS']
        elif giella == 'Pass':
            unimorphtags += ['PASS']
        elif giella == 'Pss':
            unimorphtags += ['PASS']
        elif giella == 'Cond':
            unimorphtags += ['COND']
        elif giella == 'Pot':
            unimorphtags += ['POT']
        elif giella == 'Imp':
            unimorphtags += ['IMP']
        elif giella == 'Imprt':
            unimorphtags += ['IMP']
        elif giella == 'ImprtII':
            unimorphtags += ['IMP']
        elif giella == 'Cau':
            unimorphtags += ['CAUS']
        elif giella == 'Subj':
            unimorphtags += ['SBJV']
        elif giella == 'Opt':
            unimorphtags += ['OPT']  # Desiderative optative
        elif giella == 'Des':
            unimorphtags += ['OPT']  # Desiderative optative
        elif giella == 'Oblig':
            unimorphtags += ['OBGLIG']
        elif giella == 'Interr':
            unimorphtags += ['INT']  # XXX: ABE?
        elif giella in ['Der1', 'Der2']:
            continue
        elif giella == 'Der/Comp':
            unimorphtags += ['CMPR']
        elif giella == 'Comp':
            unimorphtags += ['CMPR']
        elif giella == 'Compar':
            unimorphtags += ['CMPR']  # fkv
        elif giella == 'Superl':
            unimorphtags += ['SPRL']
        elif giella == 'Der/Superl':
            unimorphtags += ['SPRL']
        elif giella == 'Der/PassS':
            unimorphtags += ['PASS']
        elif giella == 'Attr':
            unimorphtags += ['LGSPEC9/ATTR']
        elif giella == 'Pred':
            unimorphtags += ['LGSPEC9/PRED']
        elif giella == 'Aff':
            unimorphtags += ['POS']
        elif giella == 'Neg':
            unimorphtags += ['NEG']
        elif giella == 'NegCnd':
            unimorphtags += ['NEG', 'COND']
        elif giella == 'NegCndSub':
            unimorphtags += ['NEG', 'COND']
        elif giella == 'Pos':
            unimorphtags += ['POS']
        elif giella.startswith('Err/'):
            unimorphtags += ['TYPO']
        elif giella.startswith('Errr/'):
            unimorphtags += ['TYPO']
        elif giella.startswith('Der/'):
            unimorphtags += ['XXXDER' + giella[4:]]
            continue  # NB: handle SOME ders before this
        elif giella == 'Long':
            continue
        elif giella == 'Allegro':
            continue
        elif giella == 'Sh':
            continue
        elif giella == 'Largo':
            continue
        elif giella == 'ABBR-':
            continue
        elif giella == 'ABBR':
            continue
        elif giella == 'ACRO':
            continue
        elif giella == 'ACR':
            continue
        elif giella == 'LEFT':
            continue
        elif giella == 'RIGHT':
            continue
        elif giella == 'Coll':
            continue
        elif giella == 'Qu':
            unimorphtags += ['LGSPEC1/?']
        elif giella == 'Qst':
            unimorphtags += ['LGSPEC1/?']
        elif giella.startswith('Qst/'):
            unimorphtags += ['LGSPEC1/?' + giella[4:]]
        elif giella == 'Subqst':
            continue
        elif giella == 'Rel':
            continue  # is not: Relative case or Relative comparator
        elif giella == 'Dim/ke':
            continue
        elif giella == 'Ord':
            continue
        elif giella in ['v1', 'v2', 'v3', 'v4', 'v5', 'v6']:
            continue
        elif giella in ['G3', 'G7']:
            continue
        elif giella.startswith('Sem'):
            continue
        elif giella == 'Dummytag':
            continue
        elif giella == 'S':
            continue
        elif giella == 'Quote':
            continue
        elif giella == 'CLB':
            continue
        elif giella == 'Prop':
            continue  # handled elsehwere
        elif giella.startswith('Cmp'):
            unimorphtags += ['XXXCOMPOUND']
            continue  # ?
        elif giella == 'Use/Rus':
            unimorphtags += ['DIAL']
        elif giella == 'Use/Circ':
            unimorphtags += ['XXXCIRC']
        elif giella == 'Use/Dial':
            unimorphtags += ['DIAL']
        elif giella.startswith('Use/'):
            unimorphtags += ['XXX' + giella[4:]]
        elif giella.startswith('Usage/'):
            unimorphtags += ['XXX' + giella[6:]]
        elif giella == 'Guess':
            unimorphtags += ['XXX']
        elif giella == '??':
            unimorphtags += ['XXX']
        elif giella == 'TODO':
            unimorphtags += ['XXX']
        elif giella == 'Dial':
            unimorphtags += ['DIAL']
        elif giella == 'South':
            unimorphtags += ['DIAL?']
        elif giella == 'Orth/Colloq':
            unimorphtags += ['DIAL?']
        elif giella == 'Conneg':
            unimorphtags += ['NEG']  # XXX
        elif giella == 'ConNeg':
            unimorphtags += ['NEG']  # XXX
        elif giella == 'ConNegII':
            unimorphtags += ['NEG']  # XXX
        elif giella == 'IV':
            unimorphtags += ['INTR']
        elif giella == 'TV':
            unimorphtags += ['TR']
        elif giella == 'Impers':
            unimorphtags += ['IMPRS']
        elif giella == 'Reflex':
            unimorphtags += ['REFL']
        elif giella == 'Refl':
            unimorphtags += ['REFL']
        elif giella == 'Recipr':
            unimorphtags += ['RECP']
        elif giella == 'Distr':
            unimorphtags += ['REM']
        elif giella == 'Dist':
            unimorphtags += ['REM']
        elif giella == 'Prox':
            unimorphtags += ['PROXM']
        elif giella == 'Bahuvrihi':
            # myv
            continue
        elif giella == 'AssocColl':
            # myv
            continue
        elif giella in ['0,0', '0,1']:
            continue
        elif giella in ['F1', 'F2', 'F3', 'F4', 'F5', 'F6', 'F7', 'F8', 'F9',
                        'F00', 'F01', 'F02', 'F03', 'F04', 'F05', 'F06', 'F07',
                        'F10', 'F11', 'F12', 'F13', 'F14', 'F15', 'F16', 'F08',
                        'F17', 'F18', 'F19', 'F20', 'F21', 'F22', 'F23', 'F24',
                        'F25', 'F26', 'F27', 'F28', 'F29', 'F30', 'F31', 'F09',
                        'F32', 'F33', 'F34', 'F35', 'F36', 'F37', 'F38', 'F0',
                        'F39', 'F40', 'F41', 'F42', 'F43', 'F44', 'F45',
                        'F46', 'F47', 'F48', 'F49', 'F50', 'F51', 'F52', 'F53',
                        'F54', 'F55', 'F56', 'F57', 'F58', 'F59', 'F60', 'F61',
                        'F62', 'F63', 'F64', 'F65', 'F66', 'F67', 'F68',
                        'F69', 'F70', 'F71', 'F72', 'F73', 'F74', 'F75', 'F76',
                        'F77', 'F78', 'F79', 'F80', 'F81', 'F82', 'F83', 'F84',
                        'F85', 'F86', 'F87', 'F88', 'F89', 'F90', 'F91', 'F92',
                        'F93', 'F94', 'F95', 'F96', 'F97', 'F98', 'F99',
                        'F100', 'Enter', 'Alt', 'Shift',
                        'B', 'C', 'E', 'D', 'F', 'G', 'H', 'I', 'J', 'K', 'L',
                        'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'W', 'X',
                        'Y', 'Z',
                        'Š', 'Ž', 'Ä', 'Õ', 'Ö', 'Ü', '0']:
            # est
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
        elif giella == 'Quot':
            # est
            continue
        elif giella == 'Prel':
            # fit
            continue
        elif giella == 'Dem':
            continue  # FIXME
        elif giella == 'Pers':
            continue  # FIXME
        elif giella == 'Disc':
            continue
        elif giella == 'Foc':
            unimorphtags += ['LGSPEC1/UnnamedFoc']
        elif giella.startswith('Foc/'):
            unimorphtags += ['LGSPEC1/' + giella[4:]]
        elif giella == 'Clit':
            unimorphtags += ['LGSPEC1/UnnamedClit']
        elif giella.startswith('Clit/'):
            unimorphtags += ['LGSPEC1/' + giella[5:]]
        elif giella == 'Clt':
            unimorphtags += ['LGSPEC2']
        elif giella.startswith('Clt/'):
            unimorphtags += ['LGSPEC2/' + giella[4:]]
        elif giella.startswith('OLang/'):
            continue
        elif giella.startswith('Gram/'):
            continue
        elif giella.startswith('Hom'):
            continue
        elif giella == 'TruncPrefix':
            unimorphtags += ['LGSPEC/prefix-']
        elif giella == 'Pref':
            unimorphtags += ['LGSPEC/prefix-']
        elif giella == 'Prefix':
            unimorphtags += ['LGSPEC/prefix-']
        elif giella.startswith('Pref-'):
            unimorphtags += ['LGSPEC/prefix-']
        elif giella.startswith('Genmiessi'):
            print('SOmething broken here½!', tags)
        elif '@' in giella:
            print('SOmething broken here½!', tags)
        elif giella.startswith('NErr/'):
            print('SOmething broken here½!', tags)
            unimorphtags += ['TYPO']
        elif giella.startswith('AErr/'):
            print('SOmething broken here½!', tags)
            unimorphtags += ['TYPO']
        elif '<cnjcoo>' in giella:
            print('SOmething broken here½!', tags)
        elif '<actv>' in giella:
            print('SOmething broken here½!', tags)
        elif '<gen>' in giella:
            print('SOmething broken here½!', tags)
        elif 'N224-1-9' in giella:
            print('SOmething broken here½!', tags)
        elif '#222-5-19' in giella:
            print('SOmething broken here½!', tags)
        elif '/-' in giella:
            print('SOmething broken here½!', tags)
        elif giella in ['a', 'b', 'i', 't', 'd', 's', 'n', 'ä', 'ö']:
            print('SOmething broken here½!', tags)
        elif giella in ['Ne', 'Ni', 'Nte', 'Ntee', 'Nt', 'Nti', 'Na', 'No',
                        'N-', 'c']:
            print('SOmething broken here½!', tags)
        elif 'elekriski' in giella:
            print('SOmething broken here½!', tags)
        else:
            print('missing giella mapping for', giella, 'in tags', tags)
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
    a.add_argument('-I', '--include-specs', metavar='INCSPEC',
                   help='include INCSPEC in generated data',
                   action='append', choices=['lgspec', 'typo', 'xxx', 'dial'])
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
    skip_dial = True
    if options.include_specs:
        for inclusive in options.include_specs:
            if inclusive == 'lgspec':
                skip_lgspec = False
            elif inclusive == 'typo':
                skip_typo = False
            elif inclusive == 'xxx':
                skip_xxx = False
            elif inclusive == 'dial':
                skip_dial = False
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
        if skip_dial and 'DIAL' in unimorph:
            continue
        print(lemma, surf, unimorph, sep='\t', file=options.outfile)
    realend = perf_counter()
    cpuend = process_time()
    print('CPU time:', cpuend - cpustart, 'real time:', realend - realstart)
    sys.exit(0)


if __name__ == '__main__':
    main()
