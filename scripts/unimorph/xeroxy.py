#!/usr/bin/env python3
'''CLI program to turn unimorph data to GiellaLT.'''
import sys


def main():
    lemmas = 0
    tokens = 0
    suspicious = 0
    for line in sys.stdin:
        if not line or line.strip() == '':
            print()
            continue
        # gravitáció      gravitáción     N;ON+ESS;SG
        fields = line.strip().split('\t')
        tokens += 1
        if len(fields) != 3:
            print('Datoissa virhe!', fields)
            sys.exit(1)
        elif fields[0] == '----' and fields[1] == '----' and\
                fields[2] == '----':
            # this is the kind bs that unimorph is full of
            suspicious += 1
            continue
        lemma = fields[0]
        surf = fields[1]
        unimorphs = fields[2]
        if 'intransitive verb' in surf:
            suspicious += 1
        elif 'subjunctive forms' in surf:
            suspicious += 1
        elif '|' in surf:
            suspicious += 1
        giellatags = []
        for unimorph in unimorphs.split(';'):
            if unimorph == 'N':
                giellatags += ['+N']
            elif unimorph == 'V':
                giellatags += ['+V']
            elif unimorph == 'ADJ':
                giellatags += ['+A']
            elif unimorph == 'NEUT':
                giellatags += ['+Neu']
            elif unimorph == 'MASC':
                giellatags += ['+Msc']
            elif unimorph == 'FEM':
                giellatags += ['+Fem']
            elif unimorph == 'MASC+FEM':
                giellatags += ['+Common']
            elif unimorph == 'GEN':
                giellatags += ['+Gen']
            elif unimorph == 'COM':
                giellatags += ['+Com']
            elif unimorph == 'ON+ESS':
                giellatags += ['+Ses']
            elif unimorph == 'FRML':
                giellatags += ['+Ess']
            elif unimorph == 'ESS':
                giellatags += ['+Ess']
            elif unimorph == 'INAN':
                giellatags += ['+Inan']
            elif unimorph == 'ANIM':
                giellatags += ['+Anim']
            elif unimorph == 'PRIV':
                giellatags += ['+Abe']
            elif unimorph == 'PRT':
                giellatags += ['+Par']
            elif unimorph == 'INS':
                giellatags += ['+Ins']
            elif unimorph == 'IN+ESS':
                giellatags += ['+Ine']
            elif unimorph == 'NOM':
                giellatags += ['+Nom']
            elif unimorph == 'ON+ALL':
                giellatags += ['+Sub']
            elif unimorph == 'AT+ALL':
                giellatags += ['+All']
            elif unimorph == 'PRP':
                giellatags += ['+Loc']
            elif unimorph == 'INST':
                giellatags += ['+Inst']
            elif unimorph == 'TRANS':
                giellatags += ['+Tra']
            elif unimorph == 'TERM':
                giellatags += ['+Term']
            elif unimorph == 'ON+ABL':
                giellatags += ['+Del']
            elif unimorph == 'IN+ABL':
                giellatags += ['+Ela']
            elif unimorph == 'IN+ALL':
                giellatags += ['+Ill']
            elif unimorph == 'DAT':
                giellatags += ['+Dat']
            elif unimorph == 'ACC':
                giellatags += ['+Acc']
            elif unimorph == 'AT+ESS':
                giellatags += ['+Ade']
            elif unimorph == 'AT+ABL':
                giellatags += ['+Abl']
            elif unimorph == 'SG':
                giellatags += ['+Sg']
            elif unimorph == 'DU':
                giellatags += ['+Du']
            elif unimorph == 'PL':
                giellatags += ['+Pl']
            elif unimorph == 'SG+PL':
                # giellatags += ['+Sg/Pl']
                pass
            elif unimorph == 'IND':
                giellatags += ['+Ind']
            elif unimorph == 'PRS':
                giellatags += ['+Prs']
            elif unimorph == 'PST':
                giellatags += ['+Prt']
            elif unimorph == 'PRF':
                giellatags += ['+Perf']
            elif unimorph == 'FUT':
                giellatags += ['+Fut']
            elif unimorph == '1':
                giellatags += ['+1']
            elif unimorph == '2':
                giellatags += ['+2']
            elif unimorph == '3':
                giellatags += ['+3']
            elif unimorph == 'INDF':
                pass  # unmarked in giellatags
            elif unimorph == 'GEADJ':
                giellatags += ['+Gen']
                suspicious += 1
            elif unimorph == 'DEF':
                giellatags += ['+Def']
            elif unimorph == 'NDEF':
                giellatags += ['+Ind']
            elif unimorph == 'V.PTCP':
                giellatags += ['+V']
                if 'PRS' in unimorphs:
                    giellatags += ['+PrsPrc']
                elif 'PST' in unimorphs:
                    giellatags += ['+PrtPrc']
                elif 'FUT' in unimorphs:
                    giellatags += ['+Fut']
                else:
                    giellatags += ['+Drv/Ptcp']
            elif unimorph == 'NFIN':
                giellatags += '+Ger'
            elif unimorph == 'ACT':
                giellatags += ['+Actv']
            elif unimorph == 'PASS':
                giellatags += ['+Pasv']
            elif unimorph == 'COND':
                giellatags += ['+Cond']
            elif unimorph == 'POT':
                giellatags += ['+Pot']
            elif unimorph == 'IMP':
                giellatags += ['+Imprt']
            elif unimorph == 'SBJV':
                giellatags += ['+Subj']
            elif unimorph == 'V.CVB':
                giellatags += ['+V']
                giellatags += ['+Der/Adv']
            elif unimorph == 'CMPR':
                giellatags += ['+Comp']
            elif unimorph == 'SPRL':
                giellatags += ['+Sup']
            elif unimorph == 'NEG':
                giellatags += ['+Neg']
            elif unimorph == 'POS':
                # giellatags += ['+Pos']
                pass
            elif unimorph == 'LGSPEC':
                pass
            elif unimorph == 'LGSPEC1':
                pass
            else:
                print('missing unimorph mapping for:', unimorph)
                sys.exit(2)
        reorg = []
        for ape in giellatags:
            if ape in ['+N', '+V', '+A']:
                reorg += [ape]
                break
        if reorg == ['+N']:
            for ape in giellatags:
                if ape in ['+Sg', '+Pl', '+Du']:
                    reorg += [ape]
            for ape in giellatags:
                if ape not in reorg:
                    reorg += [ape]
        elif reorg == ['+V']:
            for ape in giellatags:
                if ape not in reorg:
                    reorg += [ape]
            if '+1' in reorg and '+Sg' in reorg:
                reorg += ['+Sg1']
                reorg.remove('+1')
                reorg.remove('+Sg')
            elif '+2' in reorg and '+Sg' in reorg:
                reorg += ['+Sg2']
                reorg.remove('+2')
                reorg.remove('+Sg')
            elif '+3' in reorg and '+Sg' in reorg:
                reorg += ['+Sg3']
                reorg.remove('+3')
                reorg.remove('+Sg')
            elif '+1' in reorg and '+Du' in reorg:
                reorg += ['+Du1']
                reorg.remove('+1')
                reorg.remove('+Du')
            elif '+2' in reorg and '+Du' in reorg:
                reorg += ['+Du2']
                reorg.remove('+2')
                reorg.remove('+Du')
            elif '+3' in reorg and '+Du' in reorg:
                reorg += ['+Du3']
                reorg.remove('+3')
                reorg.remove('+Du')
            elif '+1' in reorg and '+Pl' in reorg:
                reorg += ['+Pl1']
                reorg.remove('+1')
                reorg.remove('+Pl')
            elif '+2' in reorg and '+Pl' in reorg:
                reorg += ['+Pl2']
                reorg.remove('+2')
                reorg.remove('+Pl')
            elif '+3' in reorg and '+Pl' in reorg:
                reorg += ['+Pl3']
                reorg.remove('+3')
                reorg.remove('+Pl')
        elif reorg == ['+A']:
            for ape in giellatags:
                if ape not in reorg:
                    reorg += [ape]
        else:
            print('REORG FAIL', reorg)
            sys.exit(1)
        giellatags = reorg
        print(surf, '\t', lemma, ''.join(giellatags), sep='')

    print()
    print('# tokens\tlemmas\tsuspicious')
    print('# ', tokens, '\t', lemmas, '\t', suspicious, sep='')
    print('# ', tokens / tokens * 100, '\t',
          lemmas / tokens * 100, '\t',
          suspicious / tokens * 100, '\t', sep='')


if __name__ == '__main__':
    main()
