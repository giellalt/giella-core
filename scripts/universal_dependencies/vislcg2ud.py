#!/usr/bin/env python3
"""Simple converter from giellalt deps to universal deps."""

import sys
from argparse import ArgumentParser, FileType


def print_sent(sent: list, sent_id: str, orig: str, outfile):
    print(f"# sent_id = {sent_id}", file=outfile)
    print(f"# text = {orig}", file=outfile)
    for i, token in enumerate(sent):
        for cohort in token:
            print(i+1, cohort["surf"], cohort["lemma"], cohort["upos"],
                  cohort["xpos"], cohort["feats"],
                  cohort["depto"], cohort["dep"], "_", sep="\t", file=outfile)


def get_upos(tags: list, lemma: str = "", surf: str = ""):
    if "N" in tags:
        if "Prop" in tags:
            return "PROPN"
        elif "Symbol" in tags:
            return "SYM"
        else:
            return "NOUN"
    elif "V" in tags:
        if "<aux>" in tags:
            return "AUX"
        else:
            return "VERB"
    elif "A" in tags:
        return "ADJ"
    elif "Adv" in tags:
        return "ADV"
    elif "CC" in tags:
        return "CCONJ"
    elif "CS" in tags:
        return "SCONJ"
    elif "Pron" in tags:
        return "PRON"
    elif "Pr" in tags:
        return "ADP"
    elif "Po" in tags:
        return "ADP"
    elif "Num" in tags:
        return "NUM"
    elif "CLB" in tags:
        return "PUNCT"
    elif "Pcle" in tags:
        return "PART"
    elif "PUNCT" in tags:
        return "PUNCT"
    elif "Interj" in tags:
        return "INTJ"
    elif "URL" in tags:
        return "PROPN"  # c.f. standard docu
    elif "?" in tags:
        return "X"
    else:
        print(f"cannot find upos from {surf} → {lemma} {tags}")
        return "X"


def get_xpos(tags: list, lemma: str = "", surf: str = ""):
    rv = []
    for tag in tags:
        if tag.startswith("<"):
            continue
        elif ":" in tag:
            continue
        elif "@" in tag:
            continue
        elif "#" in tag:
            continue
        else:
            rv.append(tag)
    if len(rv) > 2:
        return " ".join(rv[:2])
    else:
        return " ".join(rv)


def get_ufeats(tags: list, lemma: str = "", surf: str = ""):
    feats = []
    for tag in tags:
        if tag in ["N", "V", "A", "CC", "CS", "Adv", "Pron", "Prop", "Punct",
                   "<aux>", "CLB", "Symbol", "?", "Num", "PUNCT", "Po", "Pr",
                   "Pcle", "Interj", "CLBfinal", "URL"]:
            continue
        elif tag == "Imprt":
            feats.append("Mood=Imp")
        elif tag == "Cond":
            feats.append("Mood=Cond")
        elif tag == "Pot":
            feats.append("Mood=Pot")
        elif tag == "Ind":
            feats.append("Mood=Ind")
        elif tag == "Opt":
            feats.append("Mood=Opt")
        elif tag == "Prs":
            feats.append("Tense=Pres")
        elif tag == "Prt":
            feats.append("Tense=Past")
        elif tag == "Sg":
            feats.append("Number=Sing")
        elif tag == "Pl":
            feats.append("Number=Plur")
        elif tag == "Du":
            feats.append("Number=Dual")
        elif tag == "Nom":
            feats.append("Case=Nom")
        elif tag == "Gen":
            feats.append("Case=Gen")
        elif tag == "Ela":
            feats.append("Case=Ela")
        elif tag == "Ine":
            feats.append("Case=Ine")
        elif tag == "Loc":
            feats.append("Case=Loc")
        elif tag == "Ess":
            feats.append("Case=Ess")
        elif tag == "Ill":
            feats.append("Case=Ill")
        elif tag == "Acc":
            feats.append("Case=Acc")
        elif tag == "Par":
            feats.append("Case=Par")
        elif tag == "Abe":
            feats.append("Case=Abe")
        elif tag == "Com":
            feats.append("Case=Com")
        elif tag == "Sg1":
            feats.append("Number=Sing")
            feats.append("Person=1")
        elif tag == "Sg2":
            feats.append("Number=Sing")
            feats.append("Person=2")
        elif tag == "Sg3":
            feats.append("Number=Sing")
            feats.append("Person=3")
        elif tag == "Du1":
            feats.append("Number=Dual")
            feats.append("Person=1")
        elif tag == "Du2":
            feats.append("Number=Dual")
            feats.append("Person=2")
        elif tag == "Du3":
            feats.append("Number=Dual")
            feats.append("Person=3")
        elif tag == "Pl1":
            feats.append("Number=Plur")
            feats.append("Person=1")
        elif tag == "Pl2":
            feats.append("Number=Plur")
            feats.append("Person=2")
        elif tag == "Pl3":
            feats.append("Number=Plur")
            feats.append("Person=3")
        elif tag == "PxSg1":
            feats.append("Number[psor]=Sing")
            feats.append("Person[psor]=1")
        elif tag == "PxSg2":
            feats.append("Number[psor]=Sing")
            feats.append("Person[psor]=2")
        elif tag == "PxSg3":
            feats.append("Number[psor]=Sing")
            feats.append("Person[psor]=3")
        elif tag == "PxDu1":
            feats.append("Number[psor]=Dual")
            feats.append("Person[psor]=1")
        elif tag == "PxDu2":
            feats.append("Number[psor]=Dual")
            feats.append("Person[psor]=2")
        elif tag == "PxDu3":
            feats.append("Number[psor]=Dual")
            feats.append("Person[psor]=3")
        elif tag == "PxPl1":
            feats.append("Number[psor]=Plur")
            feats.append("Person[psor]=1")
        elif tag == "PxPl2":
            feats.append("Number[psor]=Plur")
            feats.append("Person[psor]=2")
        elif tag == "PxPl3":
            feats.append("Number[psor]=Plur")
            feats.append("Person[psor]=3")
        elif tag == "PrsPrc":
            feats.append("VerbForm=Part")
            feats.append("Tense=Pres")
        elif tag == "PrfPrc":
            feats.append("VerbForm=Part")
            feats.append("Tense=Past")
        elif tag == "Indef":
            feats.append("PronType=Ind")
        elif tag == "Recipr":
            feats.append("PronType=Rec")
        elif tag == "Dem":
            feats.append("PronType=Dem")
        elif tag == "Interr":
            feats.append("PronType=Int")
        elif tag == "Rel":
            feats.append("PronType=Rel")
        elif tag == "Pers":
            feats.append("PronType=Pers")
        elif tag == "Refl":
            feats.append("Reflex=Yes")
        elif tag == "Ord":
            feats.append("NumType=Ord")
        elif tag == "Coll":
            feats.append("NumType=Sets")
        elif tag == "Neg":
            feats.append("Polarity=Neg")
        elif tag == "ConNeg":
            feats.append("Connegative=Yes")
        elif tag == "ABBR":
            feats.append("Abbr=Yes")
        elif tag == "ACR":
            feats.append("Abbr=Yes")
        elif tag == "Err/Orth":
            feats.append("Typo=Yes")
        elif tag == "Err/MissingSpace":
            feats.append("Typo=Yes")
        elif tag == "Err/Lex":
            continue
        elif tag.startswith("Foc/"):
            feats.append("Clitic=" + tag[4:])
        elif tag == "Qst":
            continue  # XXX: this should be something
        elif tag == "Inf":
            feats.append("VerbForm=Inf")
        elif tag == "Actio":
            feats.append("VerbForm=Inf?")
        elif tag == "VAbess":
            feats.append("VerbForm=Inf?")
            feats.append("Case=Abe")
        elif tag == "VGen":
            feats.append("VerbForm=Inf?")
            feats.append("Case=Gen")
        elif tag == "Ger":
            feats.append("VerbForm=Ger")
        elif tag == "Sup":
            feats.append("VerbForm=Sup")
        elif tag.startswith("Gram/TAbbr"):
            continue
        elif tag.startswith("Cmp"):
            continue
        elif tag.startswith("<") and tag.endswith(">"):
            continue
        elif tag in ["TV", "IV"]:
            continue
        elif tag.startswith("Ex/"):
            continue
        elif tag.startswith("Der/"):
            continue
        elif tag.startswith("Sem/"):
            continue
        elif tag.startswith("Gram/"):
            continue
        elif tag.startswith("LEFT"):
            continue  # XXX
        elif tag.startswith("RIGHT"):
            continue  # XXX
        elif tag in ["Rom", "Arab"]:
            continue
        elif tag.startswith("Dyn"):
            continue
        elif tag == "Attr":
            continue  # XXX: check if should be upd in ud standards?
        elif tag == "Sg1":
            feats.append("Number=Sing")
            feats.append("Person=1")
        elif tag == "Sg2":
            feats.append("Number=Sing")
            feats.append("Person=2")
        elif tag == "Sg3":
            feats.append("Number=Sing")
            feats.append("Person=3")
        elif tag == "Allegro":
            continue
        elif tag == "NomAg":
            continue
        elif tag == "Known":
            continue  # ???
        elif tag.startswith("@"):
            continue
        elif tag.startswith("SUBSTITUTE:") or tag.startswith("REMOVE:") or \
                tag.startswith("MAP:") or tag.startswith("SETPARENT:") or \
                tag.startswith("SELECT:") or tag.startswith("IFF:") or \
                tag.startswith("ADD:"):
            continue
        elif tag.startswith("#") and "->" in tag:
            continue
        elif tag.startswith("<W:"):
            continue
        else:
            print(f"Unhandled giella tag! {tag} in {surf} → {lemma} {tags}")
            exit(1)
    return "|".join(sorted(feats))


def get_dep(tags: list, lemma: str="", surf: str=""):
    depfrom = 0
    depto = 0
    dep = "dep"
    for tag in tags:
        if tag.startswith("#") and "->" in tag:
            arrow = tag.find("->")
            depfrom = int(tag[1:arrow])
            depto = int(tag[arrow+2:])
        elif tag.startswith("@"):
            if tag == "@>N" and "Pron" in tags and "Dem" in tags:
                dep = "det"
            elif tag == "@>N" and "Pron" in tags and "Indef" in tags:
                dep = "det"
            elif tag == "@>N" and "A" in tags:
                dep = "amod"
            elif tag == "@>N" and "PrsPrc" in tags:
                dep = "amod"
            elif tag == "@>N" and "PrfPrc" in tags:
                dep = "amod"
            elif tag == "@>N" and "Num" in tags:
                dep = "nummod"
            elif tag == "@>N" and "Gen" in tags:
                dep = "nmod:poss"
            elif tag == "@>N":
                dep = "obl"
            elif tag == "@N<" and "jieš" == lemma:
                dep = "advmod"
            elif tag == "@N<":
                dep = "obl"
            elif tag == "@>Num" and "N" in tags:
                dep = "nmod"
            elif tag == "@Num<" and "N" in tags:
                dep = "nmod"
            elif tag == "@>Num":
                dep = "amod"
            elif tag == "@Num<":
                dep = "amod?"
            elif tag == "@>A" and "Num" in tags:
                dep = "nummod"
            elif tag == "@>A":
                dep = "amod?"  # XXX
            elif tag == "@A<" and "V" in tags:
                dep = "xcomp"
            elif tag == "@SUBJ>":
                dep = "nsubj"
            elif tag == "@<SUBJ":
                dep = "nsubj"
            elif tag == "@OBJ>":
                dep = "obj"
            elif tag == "@<OBJ":
                dep = "obj"
            elif tag == "@-FSUBJ>":
                dep = "nsubj"
            elif tag == "@-F<SUBJ":
                dep = "nsubj"
            elif tag == "@ICLOBJ":
                dep = "ccomp"
            elif tag == "@-F<OBJ":
                dep = "obj"
            elif tag == "@-FOBJ>":
                dep = "obj"
            elif tag == "@FMV":
                dep = "root"
            elif tag == "@FMVdic":
                dep = "parataxis"
            elif tag == "@IMV":
                dep = "root?"
            elif tag == "@+FMAINV":
                dep = "root"
            elif tag == "@-FMAINV":
                dep = "root?"
            elif tag == "@FS-VFIN<":
                dep = "aux"
            elif tag == "@FS-OBJ":
                dep = "ccomp"
            elif tag == "@FS-N<":
                dep = "aux?"
            elif tag == "@FS-IMV":
                dep = "ccomp"
            elif tag == "@FS-N<IAUX":
                dep = "xcomp"
            elif tag == "@FS-N<IMV":
                dep = "xcomp"
            elif tag == "@S<":
                dep = "conj??"
            elif tag == "@ICL-OBJ":
                dep = "obj?"
            elif tag == "@FS-ADVL>":
                dep = "acl?"
            elif tag == "@P<":
                dep = "case"
            elif tag == "@>P":
                dep = "case"
            elif tag == "@ADVL":
                dep = "obl"
            elif tag == "@ADVL>":
                dep = "obl"
            elif tag == "@ADVL<":
                dep = "obl"
            elif tag == "@<ADVL":
                dep = "obl"
            elif tag == "@>ADVL":
                dep = "obl"
            elif tag == "@ADVL-ine>":
                dep = "obl"
            elif tag == "@<ADVL-ine":
                dep = "obl"
            elif tag == "@<ADVL-ela":
                dep = "obl"
            elif tag == "@-FADVL>":
                dep = "obl"
            elif tag == "@>N" and "Gen" in tags:
                dep = "nmod:poss"
            elif tag == "@>Num" and "Gen" in tags:
                dep = "nmod:poss"
            elif tag == "@>N" and "Prop" in tags:
                dep = "flat"
            elif tag == "@>N" and "N" in tags:
                dep = "compound"
            elif tag == "@>Pron":
                dep = "obl?"
            elif tag == "@Pron<":
                dep = "obl?"
            elif tag == "@APP-ADVL<":
                dep = "appos"
            elif tag == "@APP-Pron<":
                dep = "appos"
            elif tag == "@APP-N<":
                dep = "appos"
            elif tag in ["@CVP", "@CNP"]:
                dep = "cc"
            elif tag == "@FAUX":
                dep = "aux"
            elif tag == "@+FAUXV":
                dep = "aux"
            elif tag == "@-FAUXV":
                dep = "aux"
            elif tag == "@IAUX":
                dep = "aux"
            elif tag == "@FS-IAUX":
                dep = "aux?"
            elif tag == "@FS-<ADVL":
                dep = "acl"
            elif tag == "@SPRED>":
                dep = "obl"
            elif tag == "@OPRED>":
                dep = "obl?"
            elif tag == "@<OPRED":
                dep = "obl?"
            elif tag == "@-F<OPRED":
                dep = "obl?"
            elif tag == "@<SPRED":
                dep = "ccomp?"
            elif tag == "@HNOUN":
                dep = "nmod?"
            elif tag == "@ADVL>CS":
                dep = "advcl"
            elif tag == "@COMP-CS<":
                dep = "mark"
            elif tag == "@>CC":
                dep = "conj"
            elif tag == "@INTERJ":
                dep = "discourse"
            elif tag == "@VOC":
                dep = "vocative"
            elif tag == "@PCLE":
                dep = "discourse"
            elif tag == "@X":
                dep = "dep"
            else:
                print(f"Unhandled dep tag {tag} in {surf} → {lemma} {tags}")
                exit(1)
    if dep == "dep" and "CLB" in tags or "Punct" in tags:
        dep = "punct"
    return dep, depto


def main():
    """CLI for giellalt to ud conversion."""
    ap = ArgumentParser()
    ap.add_argument("-i", "--input", metavar="INFILE", type=open,
                    dest="infile", help="read vislcg3 data from INFILE")
    ap.add_argument("-o", "--output", metavar="OUTFILE", type=FileType("w"),
                    dest="outfile", help="write UD to OUTFILE")
    ap.add_argument("-v", "--verbose", action="store_true", default=False,
                    help="print verbosely while processing")
    opts = ap.parse_args()
    if not opts.infile:
        opts.infile = sys.stdin
        print("reading from <stdin>")
    if not opts.outfile:
        opts.outfile = sys.stdout
    sent = []
    cohorts = []
    orig = ""
    sentnum = 1
    sentprinted = True
    for line in opts.infile:
        if line.startswith("\"<") and line.strip().endswith(">\""):
            if "¶" in line:
                continue
            if cohorts:
                sent.append(cohorts)
                cohorts = []
            surf = line[2:-3]
            orig = orig + surf
            sentprinted = False
        elif line.startswith("\t") and line.count("\"") == 2:
            if "¶" in line:
                continue
            if "#1->" in line and not sentprinted:
                if cohorts:
                    sent.append(cohorts)
                    cohorts = []
                orig = orig[:-len(surf)]  # cause we already peeked it
                print_sent(sent, opts.infile.name + "." + str(sentnum), orig,
                           opts.outfile)
                sentnum = sentnum + 1
                sent = []
                orig = surf  # cause we already read one surf
                sentprinted = True
            elif "#1->" in line:
                pass
            elif "#" in line and "->" in line:
                sentprinted = False
            lemstart = line.find("\"")
            lemend = line.find("\"", lemstart+1)
            lemma = line[lemstart+1:lemend]
            tags = line.rstrip()[lemend+1:].split()
            upos = get_upos(tags, lemma, surf)
            xpos = get_xpos(tags, lemma, surf)
            feats = get_ufeats(tags, lemma, surf)
            dep, deptarget = get_dep(tags, lemma, surf)
            cohorts.append({"surf": surf, "lemma": lemma, "tags": tags,
                            "suggested": True, "upos": upos, "xpos": xpos,
                            "feats": feats, "dep": dep,
                            "depto": deptarget})
        elif line.startswith(";\t") and line.count("\"") == 2:
            if "¶" in line:
                continue
            lemstart = line.find("\"")
            lemend = line.find("\"", lemstart+1)
            lemma = line[lemstart+1:lemend]
            tags = line.rstrip()[lemend+1:].split()
            upos = get_upos(tags, lemma, surf)
            xpos = get_xpos(tags, lemma, surf)
            feats = get_ufeats(tags, lemma, surf)
            dep, deptarget = get_dep(tags, lemma, surf)
            cohorts.append({"surf": surf, "lemma": lemma, "tags": tags,
                            "suggested": False, "upos": upos, "xpos": xpos,
                            "feats": feats, "dep": dep,
                            "depto": deptarget})
        elif line.startswith("\t\"\"\""):
            if "¶" in line:
                continue
            lemma = "\""
            tags = line.rstrip()[5:].split()
            upos = get_upos(tags, lemma, surf)
            xpos = get_xpos(tags, lemma, surf)
            feats = get_ufeats(tags, lemma, surf)
            dep, deptarget = get_dep(tags, lemma, surf)
            cohorts.append({"surf": surf, "lemma": lemma, "tags": tags,
                            "suggested": False, "upos": upos, "xpos": xpos,
                            "feats": feats, "dep": dep,
                            "depto": deptarget})
        elif line.startswith(":\\n"):
            if cohorts:
                sent.append(cohorts)
                cohorts = []
            print_sent(sent, opts.infile.name + "." + str(sentnum), orig,
                       opts.outfile)
            sentnum = sentnum + 1
            sent = []
            orig = ""
        elif line.startswith(";\t") and line.count("\"") == 4:
            # FIXME: tokeniser split
            continue
        elif line.startswith(":"):
            orig = orig + line[1:-1]  # or rstrip(\n) like
        elif line.strip() == "":
            continue
        else:
            print(f"some garbage data here: {line}")
    if cohorts:
        sent.append(cohorts)
    print_sent(sent, opts.infile.name + "." + str(sentnum), orig, opts.outfile)


if __name__ == "__main__":
    main()
