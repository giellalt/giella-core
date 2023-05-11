#!/bin/bash

if test $# -lt 1 ; then
    echo "Usage: $0 GENERATOR"
    echo
    echo GENERATOR should be generator-gt-desc.hfst of target language
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
echo "$cyclicRE +UglyHack | [? - [ $cyclicRE ] ]* ;" |
    sed -e 's/+/%+/g' -e 's:/:%/:g' -e 's/#/%#/g' -e 's/\^/%^/g' > generative.regex
hfst-regexp2fst -i generative.regex -o generative.hfst -f foma
hfst-compose -F -1 generative.hfst -2 "$generator" |\
    hfst-fst2fst -f olw -o generator.hfst
hfst-fst2strings -c 0 generator.hfst > generated.all
uniq < generated.all | "$(dirname "$0")"/convert.py

