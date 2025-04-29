#!/usr/bin/env -o python3
"""Script to convert ud to giellalt stuffs."""

import sys
from argparse import ArgumentParser, FileType


def print_lexc_preamble(f):
    """Print lexc stuff that is required in the beginning of the file."""
    print("Multichar_Symbols", file=f)
    for tag in ["+N", "+V", "+A", "+Adv", "+Pcle", "+Adp", "+X", "+CC", "+CS",
                "+Interj", "+Punct", "+Sym", "+Prn", "+Det"]:
        print(tag, file=f)
    print(file=f)
    print("LEXICON Root", file=f)


def ud2giella(lemma, upos, xpos, feats):
    """Convert UD to giellalt tags for morphosyntax."""
    giellatags = []
    if upos == "NOUN":
        giellatags.append("+N")
    elif upos == "VERB":
        giellatags.append("+V")
    elif upos == "ADJ":
        giellatags.append("+A")
    elif upos == "ADV":
        giellatags.append("+Adv")
    elif upos == "ADP":
        giellatags.append("+Adp")
    elif upos == "CCONJ":
        giellatags.append("+CC")
    elif upos == "SCONJ":
        giellatags.append("+CS")
    elif upos == "PUNCT":
        giellatags.append("+Punct")
    elif upos == "SYM":
        giellatags.append("+Sym")
    elif upos == "PRON":
        giellatags.append("+Prn")
    elif upos == "DET":
        giellatags.append("+Det")
    elif upos == "NUM":
        giellatags.append("+Num")
    elif upos == "INTJ":
        giellatags.append("+Interj")
    elif upos == "PROPN":
        giellatags.append("+N")
        giellatags.append("+Prop")
    elif upos == "AUX":
        giellatags.append("+V")
        giellatags.append("+Aux")
    elif upos == "PART":
        giellatags.append("+Pcle")
    elif upos == "X":
        giellatags.append("+X")
    elif upos == "_":
        pass
    else:
        print(f"Unhandled upos {upos}")
        sys.exit(1)
    for featstruct in feats.split("|"):
        if featstruct == "_":
            continue
        feat, val = featstruct.split("=")
        if featstruct == "Case=Nom":
            giellatags.append("+Nom")
        elif featstruct == "Case=Gen":
            giellatags.append("+Gen")
        elif featstruct == "Case=Dat":
            giellatags.append("+Dat")
        elif featstruct == "Case=Par":
            giellatags.append("+Par")
        elif featstruct == "Case=Ins":
            giellatags.append("+Ins")
        elif featstruct == "Case=Ill":
            giellatags.append("+Ill")
        elif featstruct == "Case=Abl":
            giellatags.append("+Abl")
        elif featstruct == "Case=Tra":
            giellatags.append("+Tra")
        elif featstruct == "Case=All":
            giellatags.append("+All")
        elif featstruct == "Case=Abe":
            giellatags.append("+Abe")
        elif featstruct == "Case=Ade":
            giellatags.append("+Ade")
        elif featstruct == "Case=Ine":
            giellatags.append("+Ine")
        elif featstruct == "Case=Ela":
            giellatags.append("+Ela")
        elif featstruct == "Case=Loc":
            giellatags.append("+Loc")
        elif featstruct == "Case=Ess":
            giellatags.append("+Ess")
        elif featstruct == "Case=Com":
            giellatags.append("+Com")
        elif featstruct == "Case=Voc":
            giellatags.append("+Voc")
        elif featstruct == "Case=Del":
            giellatags.append("+Del")
        elif featstruct == "Case=Sbl":
            giellatags.append("+Sub")
        elif featstruct == "Case=Sup":
            giellatags.append("+Super")
        elif featstruct == "Case=Cau":
            giellatags.append("+Cau")
        elif featstruct == "Case=Lat":
            giellatags.append("+Lat")
        elif featstruct == "Case=Dis":
            giellatags.append("+Dis")
        elif featstruct == "Case=Abs":
            giellatags.append("+Abs")
        elif featstruct == "Case=Tem":
            giellatags.append("+Tem")
        elif featstruct == "Case=Ter":
            giellatags.append("+Ter")
        elif featstruct == "Case=Acc":
            giellatags.append("+Acc")
        elif featstruct == "Case=Prl":
            giellatags.append("+Prl")
        elif featstruct == "Case=Ben":
            giellatags.append("+Ben")
        elif featstruct == "Case=Cmp":
            giellatags.append("+Compa")
        elif featstruct == "Case=Acc,Nom":
            giellatags.append("+AccNom")
        elif featstruct == "Case=Gen,Nom":
            giellatags.append("+GenNom")
        elif featstruct == "Gender=Masc":
            giellatags.append("+Masc")
        elif featstruct == "Gender=Fem,Masc":
            giellatags.append("+Ut")
        elif featstruct == "Gender=Fem":
            giellatags.append("+Fem")
        elif featstruct == "Gender=Neut":
            giellatags.append("+Neut")
        elif featstruct == "Gender[psor]=Fem":
            giellatags.append("+Fem")
        elif featstruct == "Gender[psor]=Masc":
            giellatags.append("+Masc")
        elif featstruct == "Animacy=Anim":
            giellatags.append("+Sem/Animate")
        elif featstruct == "Animacy=Inan":
            giellatags.append("+Sem/Inanimate")
        elif featstruct == "Animacy=Hum":
            giellatags.append("+Sem/Hum")
        elif featstruct == "Mood=Ind":
            giellatags.append("+Ind")
        elif featstruct == "Mood=Imp":
            giellatags.append("+Imp")
        elif featstruct == "Mood=Cnd":
            giellatags.append("+Cond")
        elif featstruct == "Mood=Pot":
            giellatags.append("+Pot")
        elif featstruct == "Mood=CndSub":
            giellatags.append("+CndSubj")
        elif featstruct == "Mood=Sub":
            giellatags.append("+Subj")
        elif featstruct == "Mood=Opt":
            giellatags.append("+Opt")
        elif featstruct == "Mood=Jus":
            giellatags.append("+Jus")
        elif featstruct == "Mood=Proh":
            giellatags.append("+Proh")
        elif featstruct == "Mood=Prec":
            giellatags.append("+Prec")
        elif featstruct == "Mood=Nec":
            giellatags.append("+Nec")
        elif featstruct == "Mood=Des":
            giellatags.append("+Des")
        elif featstruct == "Mood=Imp,Ind":
            giellatags.append("+Imp")
            giellatags.append("+Ind")
        elif featstruct == "Mood=Imp,Pot":
            giellatags.append("+Imp")
            giellatags.append("+Pot")
        elif featstruct == "Mood=Cnd,Pot":
            giellatags.append("+Eve")
        elif featstruct == "Aspect=Compl":
            continue
        elif featstruct == "Aspect=Frus":
            continue
        elif featstruct == "Aspect=Freq":
            giellatags.append("+Freq")
        elif featstruct == "Aspect=Aor":
            giellatags.append("+Past")
        elif featstruct == "Aspect=Imp":
            giellatags.append("+Imp")
        elif featstruct == "Aspect=Hab":
            giellatags.append("+Hab")
        elif featstruct == "Aspect=Prog":
            giellatags.append("+Prog")
        elif featstruct == "Aspect=ProgNeg":
            giellatags.append("+Prog")
            giellatags.append("+Neg")
        elif featstruct == "Aspect=ProgBkg":
            giellatags.append("+Prog")  # XXX
        elif featstruct == "Aspect=ProgLocBkg":
            giellatags.append("+Prog")  # XXX
        elif featstruct == "Aspect=PerfNeg":
            giellatags.append("+Perf")
            giellatags.append("+Neg")
        elif featstruct == "Aspect=Perf":
            giellatags.append("+Perf")
        elif featstruct == "Aspect=PerfBkg":
            giellatags.append("+Perf")  # XXX
        elif featstruct == "Aspect=Iter":
            giellatags.append("+Iter")
        elif featstruct == "Number=Sing":
            if "Person=" not in feats:
                giellatags.append("+Sg")
        elif featstruct == "Number=Dual":
            if "Person=" not in feats:
                giellatags.append("+Du")
        elif featstruct == "Number=Plur":
            if "Person=" not in feats:
                giellatags.append("+Pl")
        elif featstruct == "Number=Ptan":
            giellatags.append("+Pl")  # XXX
        elif featstruct == "Number=Plur,Sing":
            continue  # ???
        elif featstruct == "Number[psor]=Sing":
            continue  # c.f. Person[psor]
        elif featstruct == "Number[psor]=Plur":
            continue  # c.f. Person[psor]
        elif featstruct == "Number[psed]=Sing":
            giellatags.append("+Der/PxSg")
        elif featstruct == "Number[psed]=Plur":
            giellatags.append("+Der/PxPl")
        elif featstruct == "Number[subj]=Sing":
            continue  # c.f. Person[subj]
        elif featstruct == "Number[subj]=Plur":
            continue  # c.f. Person[subj]
        elif featstruct == "Number[subj]=Plur,Sing":
            continue  # c.f. Person[subj]
        elif featstruct == "Number[obj]=Sing":
            continue  # c.f. Person[obj]
        elif featstruct == "Number[obj]=Plur":
            continue  # c.f. Person[obj]
        elif featstruct == "Number[grnd]=Sing":
            continue  # c.f. Person[grnd]
        elif featstruct == "NumType=Card":
            giellatags.append("+Card")
        elif featstruct == "NumType=Ord":
            giellatags.append("+Ord")
        elif featstruct == "NumType=OrdSets":
            continue
        elif featstruct == "NumType=OrdMult":
            continue
        elif featstruct == "NumType=Mult":
            continue
        elif featstruct == "NumType=Frac":
            continue
        elif featstruct == "NumType=Dist":
            continue
        elif featstruct == "NumType=Appr":
            continue
        elif featstruct == "NumType=Sets":
            continue
        elif featstruct == "AdvType=Cau":
            continue
        elif featstruct == "AdvType=Con":
            continue
        elif featstruct == "AdvType=Sta":
            continue
        elif featstruct == "AdvType=Mod":
            continue
        elif featstruct == "AdvType=Loc":
            continue
        elif featstruct == "AdvType=Deg":
            continue
        elif featstruct == "AdvType=Tim":
            continue
        elif featstruct == "AdvType=Man":
            continue
        elif featstruct == "AdvType=Ideoph":
            continue
        elif featstruct == "Person=1":
            if "Number=Sing" in feats:
                giellatags.append("+Sg1")
            elif "Number=Plur" in feats:
                giellatags.append("+Pl1")
            elif "Number=Dual" in feats:
                giellatags.append("+Du1")
            else:
                giellatags.append("+1")
        elif featstruct == "Person=2":
            if "Number=Sing" in feats:
                giellatags.append("+Sg2")
            elif "Number=Plur" in feats:
                giellatags.append("+Pl2")
            elif "Number=Dual" in feats:
                giellatags.append("+Du2")
            else:
                giellatags.append("+2")
        elif featstruct == "Person=3":
            if "Number=Sing" in feats:
                giellatags.append("+Sg3")
            elif "Number=Plur" in feats:
                giellatags.append("+Pl3")
            elif "Number=Dual" in feats:
                giellatags.append("+Du3")
            else:
                giellatags.append("+3")
        elif featstruct == "Person=4":
            giellatags.append("+Impersonal")  # FIXME
        elif featstruct == "Person=0":
            giellatags.append("+Impersonal")  # FIXME
        elif featstruct == "Person[psor]=1":
            if "Number[psor]=Sing" in feats:
                giellatags.append("+PxSg1")
            elif "Number[psor]=Plur" in feats:
                giellatags.append("+PxPl1")
            elif "Number[psor]=Dual" in feats:
                giellatags.append("+PxDu1")
            else:
                giellatags.append("+Px1")
        elif featstruct == "Person[psor]=2":
            if "Number[psor]=Sing" in feats:
                giellatags.append("+PxSg2")
            elif "Number[psor]=Plur" in feats:
                giellatags.append("+PxPl2")
            elif "Number[psor]=Dual" in feats:
                giellatags.append("+PxDu2")
            else:
                giellatags.append("+Px2")
        elif featstruct == "Person[psor]=3":
            if "Number[psor]=Sing" in feats:
                giellatags.append("+PxSg3")
            elif "Number[psor]=Plur" in feats:
                giellatags.append("+PxPl3")
            elif "Number[psor]=Dual" in feats:
                giellatags.append("+PxDu3")
            else:
                giellatags.append("+Px3")
        elif featstruct == "Person[subj]=1":
            if "Number[subj]=Sing" in feats:
                giellatags.append("+Sg1")
            elif "Number[subj]=Plur" in feats:
                giellatags.append("+Pl1")
        elif featstruct == "Person[subj]=2":
            if "Number[subj]=Sing" in feats:
                giellatags.append("+Sg2")
            elif "Number[subj]=Plur" in feats:
                giellatags.append("+Pl2")
        elif featstruct == "Person[subj]=3":
            if "Number[subj]=Sing" in feats:
                giellatags.append("+Sg3")
            elif "Number[subj]=Plur" in feats:
                giellatags.append("+Pl3")
            else:
                giellatags.append("+3")
        elif featstruct == "Person[obj]=1":
            if "Number[obj]=Sing" in feats:
                giellatags.append("+o_Sg1")
            elif "Number[obj]=Plur" in feats:
                giellatags.append("+o_Pl1")
        elif featstruct == "Person[obj]=2":
            if "Number[obj]=Sing" in feats:
                giellatags.append("+o_Sg2")
            elif "Number[obj]=Plur" in feats:
                giellatags.append("+o_Pl2")
        elif featstruct == "Person[obj]=3":
            if "Number[obj]=Sing" in feats:
                giellatags.append("+o_Sg3")
            elif "Number[obj]=Plur" in feats:
                giellatags.append("+o_Pl3")
        elif featstruct == "Person[grnd]=3":
            if "Number[grnd]=Sing" in feats:
                giellatags.append("+g_Sg3")
            elif "Number[grnd]=Plur" in feats:
                giellatags.append("+g_Pl3")
        elif featstruct == "PronType=Ind,Prs":
            giellatags.append("+Indef")
            giellatags.append("+Pers")
        elif featstruct == "PronType=Ind":
            giellatags.append("+Indef")
        elif featstruct == "PronType=Prs":
            giellatags.append("+Pers")
        elif featstruct == "PronType=Prs,Tot":
            giellatags.append("+Pers")
        elif featstruct == "PronType=Rel":
            giellatags.append("+Rel")
        elif featstruct == "PronType=Dem":
            giellatags.append("+Dem")
        elif featstruct == "PronType=Dem,Ind":
            giellatags.append("+Dem")
            giellatags.append("+Ind")
        elif featstruct == "PronType=Int":
            giellatags.append("+Interr")
        elif featstruct == "PronType=Int,Rel":
            giellatags.append("+Interr")
            giellatags.append("+Rel")
        elif featstruct == "PronType=Rcp":
            giellatags.append("+Recipr")
        elif featstruct == "PronType=Art":
            giellatags.append("+Art")
        elif featstruct == "PronType=Art,Prs":
            giellatags.append("+Art")
            giellatags.append("+Pers")
        elif featstruct == "PronType=Tot":
            continue
        elif featstruct == "PronType=Emp":
            continue
        elif featstruct == "PronType=Neg":
            giellatags.append("+Neg")
        elif featstruct == "AdpType=Prep":
            giellatags.remove("+Adp")
            giellatags.insert(0, "+Pr")
        elif featstruct == "AdpType=Post":
            giellatags.remove("+Adp")
            giellatags.insert(0, "+Po")
        elif featstruct == "Polarity=Pos":
            continue
        elif featstruct == "Polarity=Neg":
            giellatags.append("+Neg")
        elif featstruct == "Tense=Pres":
            giellatags.append("+Prs")
        elif featstruct == "Tense=Past":
            giellatags.append("+Prt")
        elif featstruct == "Tense=Fut":
            giellatags.append("+Fut")
        elif featstruct == "Tense=Pred":
            giellatags.append("+Pred")
        elif featstruct == "Voice=Act":
            giellatags.append("+Act")
        elif featstruct == "Voice=Pass":
            giellatags.append("+Pass")
        elif featstruct == "Voice=Rcp":
            giellatags.append("+Rcp")
        elif featstruct == "Voice=Cau":
            giellatags.append("+Cau")
        elif featstruct == "Voice=Mid":
            giellatags.append("+Mid")
        elif featstruct == "Voice=Mid,Pass":
            giellatags.append("+Mid")
            giellatags.append("+Pass")
        elif featstruct == "Voice=Stat":
            giellatags.append("+Stat")
        elif featstruct == "Degree=Pos":
            continue  # ?
        elif featstruct == "Degree=Cmp":
            giellatags.append("+Comp")
        elif featstruct == "Degree=Sup":
            giellatags.append("+Sup")
        elif featstruct == "Degree=Aug":
            giellatags.append("+Aug")
        elif featstruct == "Degree=Dim":
            giellatags.append("+Dim")
        elif featstruct == "VerbType=Aux":
            giellatags.append("+Aux")
        elif featstruct == "PartForm=Pres":
            giellatags.append("+PrsPrc")
        elif featstruct == "PartForm=Past":
            giellatags.append("+PrtPrc")
        elif featstruct == "PartForm=Agt":
            giellatags.append("+AgPrc")
        elif featstruct == "PartForm=Neg":
            giellatags.append("+NegPrc")
        elif featstruct == "PartForm=NegConvPrc":
            giellatags.append("+NegConvPrc")
        elif featstruct == "PartForm=PastDyn":
            continue
        elif featstruct == "PartForm=PrsDet":
            continue
        elif featstruct == "PartForm=PrsTra":
            continue
        elif featstruct == "Definite=Ind":
            giellatags.append("+Indef")
        elif featstruct == "Definite=2":
            giellatags.append("+Def2")
        elif featstruct == "Definite=Def":
            giellatags.append("+Def")
        elif featstruct == "Definite=Spec":
            giellatags.append("+Spec")  # XXX
        elif featstruct == "Definite=Cons":
            giellatags.append("+Cons")  # XXX
        elif featstruct == "Definite=Def,Ind":
            continue  # ???
        elif featstruct == "Deixis=Prox":
            giellatags.append("+Prox")
        elif featstruct == "Deixis=Remt":
            giellatags.append("+Dist")
        elif featstruct == "Valency=1":
            giellatags.append("+IV")
        elif featstruct == "Valency=2":
            giellatags.append("+TV")
        elif featstruct == "Abbr=Yes":
            giellatags.append("+Abbr")
        elif featstruct == "Poss=Yes":
            giellatags.append("+Poss")
        elif featstruct == "Reflex=Yes":
            giellatags.append("+Reflex")
        elif featstruct == "Connegative=Yes":
            giellatags.append("+ConNeg")
        elif featstruct == "Typo=Yes":
            giellatags.append("+Err/Orth")
        elif featstruct == "Style=Slng":
            giellatags.append("+Use/Nonstd")
        elif featstruct == "Style=Coll":
            giellatags.append("+Use/Nonstd")
        elif featstruct == "Style=Vrnc":
            giellatags.append("+Use/Nonstd")
        elif featstruct == "Style=Rare":
            giellatags.append("+Use/Nonstd")
        elif featstruct == "Style=Expr":
            giellatags.append("+Use/Nonstd")
        elif featstruct == "Style=Arch":
            giellatags.append("+Use/Arch")
        elif featstruct == "Rel=Abs":
            continue
        elif featstruct == "Rel=NCont":
            continue
        elif featstruct == "Rel=Cont":
            continue
        elif featstruct == "NumForm=Word":
            continue
        elif featstruct == "NumForm=Combi":
            continue  # XXX
        elif featstruct == "NumForm=Roman":
            giellatags.append("+Roman")
        elif featstruct == "NumForm=Digit":
            giellatags.append("+Arab")
        elif featstruct == "PartType=Prs":
            giellatags.append("+PrsPrc")
        elif featstruct == "PartType=Neg":
            giellatags.append("+NegPrc")
        elif featstruct == "PartType=Emp":
            giellatags.append("+Foc")
        elif featstruct == "PartType=Int":
            giellatags.append("+Interr")
        elif featstruct == "PartType=Mod":
            continue
        elif featstruct == "PartType=Exs":
            continue
        elif featstruct == "Foreign=Yes":
            giellatags.append("+Lang/Und")
        elif featstruct == "Variant=Short":
            giellatags.append("+Allegro")
        elif featstruct == "Variant=Long":
            giellatags.append("+Adagio")
        elif featstruct == "Evident=Nfh":
            continue
        elif featstruct == "Evident=Fh":
            continue
        elif featstruct == "NounType=Relat":
            continue
        elif featstruct == "NegationType=Contrastive":
            continue
        elif featstruct == "PunctType=Elip":
            continue
        elif featstruct == "PunctSide=Ini":
            continue
        elif featstruct == "PunctSide=Fin":
            continue
        elif featstruct == "Red=Yes":
            continue
        elif featstruct == "Modality=Proh":
            continue
        elif featstruct == "Modality=Cond":
            giellatags.append("+Cond")
        elif featstruct == "Foc=Yes":
            giellatags.append("+Foc")
        elif featstruct == "Compound=Yes":
            continue  # XXX #+cmp should go in the middle?
        # hacks that use feat and val separately
        elif feat == "InfForm":
            giellatags.append("+Inf" + val)
        elif feat == "Clitic":
            giellatags.append("+Foc/" + val)
        elif feat == "NameType":
            continue  # ?
        elif feat == "VerbForm":
            continue  # ?
        elif feat == "ExtPos":
            continue
        elif feat == "Derivation":
            giellatags.append("+Drv/" + val)
        else:
            print(f"Unhandled UFeat {featstruct}")
            sys.exit(1)
    return giellatags


def lexc_escape(s: str) -> str:
    """Escape lexc reserved symbols."""
    s = s.replace("%", "@PERCENT@")
    s = s.replace(" ", "% ")
    s = s.replace(";", "%;")
    s = s.replace("#", "%#")
    s = s.replace(":", "%:")
    s = s.replace("\"", "%\"")
    s = s.replace("<", "%<")
    s = s.replace(">", "%>")
    s = s.replace("!", "%!")
    s = s.replace("@PERCENT@", "%%")
    return s


def main():
    """CLI for UD to gielalt confersion."""
    ap = ArgumentParser()
    ap.add_argument("-i", "--input", metavar="INFILE", type=open,
                    dest="infile", help="read CONLL-U data from INFILE")
    ap.add_argument("-L", "--lexc", metavar="LEXCFILE", type=FileType("w"),
                    dest="lexcfile", help="write lexc to LEXCFILE",
                    required=True)
    ap.add_argument("-v", "--verbose", action="store_true", default=False,
                    help="print verbosely while processing")
    opts = ap.parse_args()
    if not opts.infile:
        opts.infile = sys.stdin
        print("reading from <stdin>")
    print_lexc_preamble(opts.lexcfile)
    for line in opts.infile:
        if line.startswith("#"):
            continue
        elif line.strip() == "":
            continue
        fields = line.rstrip("\n").split("\t")
        if len(fields) != 10:
            print("Datoissa virhe {len(fields)} != 10:", fields)
            continue
        position = fields[0]
        surf = fields[1]
        lemma = fields[2]
        upos = fields[3]
        xpos = fields[4]
        feats = fields[5]
        deptarget = fields[6]
        depname = fields[7]
        endeps = fields[8]
        misc = fields[9]
        giellatags = ud2giella(lemma, upos, xpos, feats)
        lexclemma = lexc_escape(lemma)
        lexctags = lexc_escape("".join(giellatags))
        lexcsurf = lexc_escape(surf)
        print(f"{lexclemma}{lexctags}:{lexcsurf}  # ;", file=opts.lexcfile)



if __name__ == "__main__":
    main()
