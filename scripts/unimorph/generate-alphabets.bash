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
for c in a b c d e f g h i j k l m n o p q r s t u v x y z å ä ö š ž ; do
    echo "$cyclicRE +UglyHack | $c [? - [ $cyclicRE ] ]* ;" |
        sed -e 's/+/%+/g' -e 's:/:%/:g' -e 's/#/%#/g' -e 's/\^/%^/g' > generative.$c.regex
    hfst-regexp2fst -i generative.$c.regex -o generative.$c.hfst -f foma
    hfst-compose -F -1 generative.$c.hfst -2 "$generator" |\
        hfst-fst2fst -f olw -o generator.$c.hfst
        hfst-fst2strings -c 0 generator.$c.hfst > generated.$c
    echo $c
    uniq < generated.$c | "$(dirname "$0")"/convert.py
done

