#!/bin/bash

if test $# -lt 2 ; then
    echo "Usage: $0 WORD GENERATOR"
    echo
    echo WORD should be a lemma form in generator
    echo GENERATOR should be generator-gt-desc.hfst of target language
    exit 1
fi

cyclictags=$(dirname "$0")/excluded.tags
if test ! -f "$cyclictags" ; then
    echo "missing $cyclictags please get them from giella-core"
    exit 2
fi
cyclicRE=$(tr '\n' '|' < "$cyclictags" | sed -e 's/|*$//')
lemma=$1
lemmaRE=$(echo $1 | sed -e 's/./& /g')
shift
generator=$1
shift

if test ! -f "$generator" ; then
    echo "Could not find generator automaton $generator"
    exit 1
fi
echo "$cyclicRE +UglyHack | $lemmaRE [? - [ $cyclicRE ] ]* ;" |
        sed -e 's/+/%+/g' -e 's:/:%/:g' -e 's/#/%#/g' -e 's/\^/%^/g' > generative.$lemma.regex
    hfst-regexp2fst -i generative.$lemma.regex -o generative.$lemma.hfst -f foma
    hfst-compose -F -1 generative.$lemma.hfst -2 "$generator" |\
        hfst-fst2fst -f olw -o generator.$lemma.hfst
        hfst-fst2strings -c 0 generator.$lemma.hfst > generated.$lemma
echo $lemma
uniq < generated.$lemma | "$(dirname "$0")"/convert.py
