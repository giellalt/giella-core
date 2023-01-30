#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Test unimorph compatibility with giellalt analyser. Reads a unimorph database
and checks how many analyses of giellalt analyser are compatible with it using
a custom tag mapping function.
"""


from argparse import ArgumentParser, FileType
from sys import stderr, stdout, stdin
from time import perf_counter, process_time

import sys
import libhfst
import re

def remove_flags(s):
    return re.sub('@[^@]*@', '', s)

def load_hfst(f):
    try:
        his = libhfst.HfstInputStream(f)
        return his.read()
    except libhfst.NotTransducerStreamException:
        raise IOError(2, f) from None

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
            unimorphtags += ['AT+ALL']  # XXX: ALL?
        elif giella == 'Loc':
            unimorphtags += ['PRP']
        elif giella == 'Inst':
            unimorphtags += ['INST']
        elif giella == 'Tra':
            unimorphtags += ['TRANS']
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
            unimorphtags += ['SG']
        elif giella == 'Du':
            unimorphtags += ['DU']
        elif giella == 'Pl':
            unimorphtags += ['PL']
        elif giella == 'Indic':
            unimorphtags += ['IND']
        elif giella == 'Ind':
            unimorphtags += ['IND']  # XXX: can sometimes be indef?
        elif giella == 'Prs':
            unimorphtags += ['PRS']
        elif giella == 'Prt':
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
        elif giella == 'VGen':
            continue  # FIXME
        elif giella == 'VAbess':
            continue  # FIXME
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
            continue  # NB: handle SOME ders before this
        elif giella == 'Allegro':
            continue
        elif giella == 'ACR':
            continue
        elif giella == 'Coll':
            continue
        elif giella == 'Qst':
            continue
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
            continue  # ?
        elif giella == 'South':
            unimorphtags += ['DIAL?']
        elif giella == 'ConNeg':
            unimorphtags += ['NEG']  # XXX
        elif giella == 'ConNegII':
            unimorphtags += ['NEG']  # XXX
        elif giella == 'IV':
            continue  # not marked in current unimorph
            # unimorphtags += ['INTR']
        elif giella == 'TV':
            continue  # not marked in current unimorph
            unimorphtags += ['TR']
        elif giella == 'Recipr':
            unimorphtags += ['RECP']
        elif giella == 'Dem':
            continue  #  FIXME
        elif giella == 'Pers':
            continue  #  FIXME
        elif giella.startswith('Foc/'):
            unimorphtags += ['LGSPEC1/' + giella[5:]]
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
    a.add_argument('-a', '--analyser', metavar='FSAFILE', required=True,
                   help="load analyser from FSAFILE")
    a.add_argument('-i', '--input', metavar="INFILE", type=open,
                   dest="infile", help="source of analysis data")
    a.add_argument('-o', '--output', metavar="OUTFILE",
                   type=FileType('w'),
                   dest="outfile", help="log outputs to OUTFILE")
    a.add_argument('-X', '--statistics', metavar="STATFILE",
                   type=FileType('w'),
                   dest="statfile", help="statistics")
    a.add_argument('-v', '--verbose', action="store_true", default=False,
                   help="Print verbosely while processing")
    a.add_argument('-C', '--no-casing', action="store_true", default=False,
                   help="Do not try to recase input and output when matching")
    a.add_argument('-t', '--threshold', metavar="THOLD", default=99,
                   help="if coverage is less than THOLD exit with error")
    options = a.parse_args()
    analyser = None
    try:
        if options.analyser:
            if options.verbose:
                print("reading analyser from", options.analyser)
            analyser = load_hfst(options.analyser)
        if not options.infile:
            options.infile = stdin
            print("reading from <stdin>")
        if not options.statfile:
            options.statfile = stdout
        if not options.outfile:
            options.outfile = stdout
    except IOError:
        print("Could not process file", options.analyser, file=stderr)
        exit(2)
    # basic statistics
    covered = 0
    full_matches = 0
    lemma_matches = 0
    anal_matches = 0
    no_matches = 0
    no_results = 0
    only_permuted = 0
    accfails = 0
    lines = 0
    # for make check target
    threshold = options.threshold
    realstart = perf_counter()
    cpustart = process_time()
    for line in options.infile:
        fields = line.strip().split('\t')
        if line.strip() == '':
            continue
        if len(fields) < 3:
            print("ERROR: Skipping line", fields, file=stderr)
            continue
        if ' ' in fields[1] or ' ' in fields[0]:
            continue
        lines += 1
        if options.verbose and lines % 1000 == 0:
            print(lines, '...')
        lemma = fields[0]
        unimorph = fields[2]
        # if LGSPEC in unimorph...
        unimorph = unimorph.replace(';LGSPEC', '')
        # replace known bugs unimorph 4
        if unimorph == 'N;PSS1S':
            unimorph = 'N;NOM;SG;PSS1S'
        elif unimorph == 'N;PSS2S':
            unimorph = 'N;NOM;SG;PSS2S'
        elif unimorph == 'N;PSS3':
            unimorph = 'N;NOM;SG;PSS3'
        elif unimorph == 'N;PSS1P':
            unimorph = 'N;NOM;SG;PSS1P'
        elif unimorph == 'N;PSS2P':
            unimorph = 'N;NOM;SG;PSS2P'
        surf = fields[1]
        anals = analyser.lookup(surf)
        if len(anals) > 0:
            covered += 1
        else:
            no_results += 1
            print(1, 'OOV', surf, sep='\t', file=options.outfile)
        found_anals = False
        found_lemma = False
        permuted = True
        accfail = False
        for anal in anals:
            giella = remove_flags(anal[0])
            giella_anal = giella[giella.find('+'):]
            analhyp = giella2unimorph(giella_anal)
            lemmahyp = giella[:giella.find('+')]
            if analhyp == unimorph:
                found_anals = True
                permuted = False
            elif set(analhyp.split(';')) == set(unimorph.split(';')):
                found_anals = True
                if options.verbose:
                    print('PERMUTAHIT', analhyp, unimorph, sep='\t',
                          file=options.outfile)
            else:
                if options.verbose:
                    print('ANALMISS', analhyp, unimorph, sep='\t',
                          file=options.outfile)
            if lemma == lemmahyp:
                found_lemma = True
            elif lemma == lemmahyp.replace('š', 's'):
                found_lemma = True
            else:
                pass
                # print("LEMMAMISS", lemmahyp, lemma, sep='\t',
                #      file=options.outfile)
        if not found_anals and not found_lemma:
            no_matches += 1
            print('NOHITS!', surf, lemma, unimorph,
                  [remove_flags(x[0]) for x in anals],
                  file=options.outfile)
        elif found_anals and found_lemma:
            full_matches += 1
        elif not found_anals:
            anal_matches += 1
            print('LEMMANOANAL', surf, lemma, unimorph,
                  [remove_flags(x[0]) for x in anals],
                  file=options.outfile)
        elif not found_lemma:
            lemma_matches += 1
            print('ANALNOLEMMA', surf, lemma, unimorph,
                  [remove_flags(x[0]) for x in anals],
                  file=options.outfile)
        else:
            print('Logical error, kill everyone')
            exit(13)
        if permuted:
            only_permuted += 1
        if accfail:
            accfails += 1
    realend = perf_counter()
    cpuend = process_time()
    print('CPU time:', cpuend - cpustart, 'real time:', realend - realstart)
    if lines == 0:
        print('Needs more than 0 lines to determine something',
              file=stderr)
        exit(2)
    print('Lines', 'Covered', 'OOV', sep='\t', file=options.statfile)
    print(lines, covered, lines - covered, sep='\t', file=options.statfile)
    print(lines / lines * 100 if lines != 0 else 0,
          covered / lines * 100 if lines != 0 else 0,
          (lines - covered) / lines * 100 if lines != 0 else 0,
          sep="\t", file=options.statfile)
    print('Lines', 'Matches', 'Lemma', 'Anals', 'Mismatch',
          'No results', sep='\t', file=options.statfile)
    print(lines, full_matches, lemma_matches, anal_matches, no_matches,
          no_results,
          sep='\t', file=options.statfile)
    print(lines / lines * 100 if lines != 0 else 0,
          full_matches / lines * 100 if lines != 0 else 0,
          lemma_matches / lines * 100 if lines != 0 else 0,
          anal_matches / lines * 100 if lines != 0 else 0,
          no_matches / lines * 100 if lines != 0 else 0,
          no_results / lines * 100 if lines != 0 else 0,
          sep='% \t', file=options.statfile)
    print('Of which', 'Tag permuations', sep='\t',
          file=options.statfile)
    print(lines / lines * 100 if lines != 0 else 0,
          only_permuted / lines * 100 if lines != 0 else 0, sep='\t',
          file=options.statfile)
    if full_matches / lines * 100 <= int(options.threshold):
        print('needs to have', threshold, '% matches to pass regress test\n',
              'please examine', options.outfile.name, 'for regressions',
              file=stderr)
        exit(1)
    elif covered / lines * 100 <= int(options.threshold):
        print('needs to have', threshold, '% coverage to pass regress test\n',
              'please examine', options.outfile.name, 'for regressions',
              file=stderr)
        exit(1)
    else:
        exit(0)


if __name__ == '__main__':
    main()
