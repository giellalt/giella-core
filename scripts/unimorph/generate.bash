#!/bin/bash

if test $# -lt 1 ; then
    echo "Usage: $0 GENERATOR [INPUT]"
    echo
    echo GENERATOR should be generator-gt-desc.hfst of target language
    echo INPUTs are unimorph style TSV files or stdin if missing
    exit 1
fi

cyclictags=$(dirname "$0")/excluded.tags
if test ! -f "$cyclictags" ; then
    echo "missing $cyclictags please get them from giella-core"
    exit 2
fi
cyclicRE=$(tr '\n' '|' < "$cyclictags" | sed -e 's/|*$//')
generator=$1
shift

if test ! -f "$generator" ; then
    echo "Could not find generator automaton $generator"
    exit 1
fi
analyser=${generator/generator/analyser}ol
if test ! -f "$analyser" ; then
    echo "Could not find analyser automaton $analyser"
    exit 1
fi
prevlemmapos="NA"
cat "$@" | while read -r l ; do
    lemma=$(echo "$l" | cut -f 1)
    pos=$(echo "$l" | cut -f 3 | cut -f 1 -d ';')
    gtpos="+?"
    if test x"$lemma" == x ; then
        continue
    elif test "$prevlemmapos" == "$lemma${pos%.*}" ; then
        continue
    else
        prevlemmapos=$lemma$pos
    fi
    case $pos in
        ADJ) gtpos="+A";;
        ADV) gtpos="+Adv";;
        NUM) gtpos="+Num";;
        ADP) gtpos="+Po";;
        INTJ) gtpos="+Interj";;
        CONJ) gtpos="+CS";;
        PRO) gtpos="+Pron";;
        V) gtpos="+V";;
        V.PTCP) gtpos="+V";;
        V.MSD) gtpos="+V";;
        V.CVB) gtpos="+V";;
        N) gtpos="+N";;
        *) gtpos="+$pos?";;
    esac
    echo
    echo "$lemma$gtpos"
    echo "$lemma" | sed -e 's/./ & /g' | sed -e "s/\$/ $gtpos /" |\
        sed -e "s:\$: [? - [ $cyclicRE  ] ]*:" |\
        sed -e "s:^:$cyclicRE +UglyHack | :" |\
        sed -e 's/+/%+/g' -e 's:/:%/:g' -e 's/#/%#/g' > generative.regex
    hfst-regexp2fst -i generative.regex -o generative.hfst -f foma
    hfst-compose -F -1 generative.hfst -2 "$generator" |\
        hfst-fst2fst -f olw -o generator.hfst
    timeout 10s hfst-fst2strings generator.hfst > generated.strings
    if test -s generated.strings ; then
        uniq < generated.strings | "$(dirname "$0")"/convert.py
    else
        echo "FAILED TO GENERATE $lemma $gtpos"
        echo "$lemma" | hfst-lookup -q "$analyser"
    fi
done

