#!/bin/bash

if test $# -lt 2 ; then
    echo "Usage: $0 LANGDIR LEXCFILE [GTPOS [NOPOSLEX]]"
    echo
    echo LANGDIR should be clone of giellalt/lang-XXX
    echo "LEXCFILE is name of (stems) .lexc file"
    echo GTPOS is tag after lemma if nonstandard filename or tag
    echo NOPOSLEX is continuation lexicon if no tags in stem lexicon
    exit 1
fi

cyclictags=$(dirname "$0")/excluded.tags
if test ! -f "$cyclictags" ; then
    echo "missing $cyclictags please get them from giella-core"
    exit 2
fi
cyclicRE=$(tr '\n' '|' < "$cyclictags" | sed -e 's/|*$//')
generator=$1/src/generator-gt-desc.hfst
if test ! -f "$generator" ; then
    echo "Could not find generator automaton $generator"
    exit 1
fi
analyser=${generator/generator/analyser}ol
if test ! -f "$analyser" ; then
    echo "Could not find analyser automaton $analyser"
    exit 1
fi
stems=$2
if test $# -ge 3 ; then
    gtpos=$3
else
    case $stems in
        *abbreviations.lexc) gtpos="+N";;
        *acronyms.lexc) gtpos="+N";;
        *adjectives.lexc) gtpos="+A";;
        *adpositions.lexc) gtpos="+Pr"; noposlex="Postp";;
        *adverbs.lexc) gtpos="+Adv";;
        *conjunctions.lexc) gtpos="+CC";;
        *subjunctions.lexc) gtpos="+CS";;
        *interjections.lexc) gtpos="+Interj";;
        *numerals.lexc) gtpos="+Num";;
        *particles.lexc) gtpos="+Pcle";;
        *pronouns.lexc) gtpos="+Pron";;
        *propernouns.lexc) gtpos="+N";;
        *punctuation.lexc) gtpos="+Punct";;
        *nouns.lexc) gtpos="+N";;
        *verbs.lexc) gtpos="+V";;
        *) gtpos="+X";;
    esac
fi
if test $# -ge 4 ; then
    noposlex=$4
else
    noposlex="#"
fi
if test "$noposlex" != "#" ; then
    grep -E "^[^ ]* *$noposlex" "$stems" | while read -r ll ; do
        lemma=${ll%% *}
        lemma=${lemma%%:*}
        lemma=${lemma%%+*}
        if test -z "$lemma"; then
            continue
        fi
        echo "$lemma" | sed -e 's/./ & /g' | sed -e "s/\$/ $gtpos /" |\
            sed -e "s:\$: [? @MINUS@ [ $cyclicRE  ] ]*:" |\
            sed -e "s:^:$cyclicRE +UglyHack | :" |\
            sed -e 's/+/%+/g' -e 's:/:%/:g' -e 's/-/%-/g' \
                -e 's/#/%#/g' -e 's/_/%_/g' -e 's/\^/%^/g' \
                -e 's/@MINUS@/-/g'  > generative.regex
        hfst-regexp2fst -i generative.regex -o generative.hfst -f foma
        hfst-compose -F -1 generative.hfst -2 "$generator" |\
            hfst-fst2fst -f olw -o generator.hfst
        hfst-fst2strings generator.hfst > generated.strings
        if test -s generated.strings ; then
            uniq < generated.strings | "$(dirname "$0")"/convert.py
        else
            echo "FAILED TO GENERATE $lemma $gtpos"
            echo "$lemma" | hfst-lookup -q "$analyser"
        fi
    done
else
    grep -E -o "^[^ :!]+\\$gtpos" "$stems" | while read -r lg ; do
        lemma=${lg%%+*}
        if test -z "$lemma"; then
            continue
        fi
        echo "$lemma" | sed -e 's/./ & /g' | sed -e "s/\$/ $gtpos /" |\
            sed -e "s:\$: [? @MINUS@ [ $cyclicRE  ] ]*:" |\
            sed -e "s:^:$cyclicRE +UglyHack | :" |\
            sed -e 's/+/%+/g' -e 's:/:%/:g' -e 's/-/%-/g' \
                -e 's/#/%#/g' -e 's/_/%_/g' -e 's/\^/%^/g' \
                -e 's/@MINUS@/-/g' > generative.regex
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
fi

