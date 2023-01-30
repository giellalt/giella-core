#!/bin/bash

if test $# != 1 ; then
    echo "Usage: $0 LANGDIR"
    echo
    echo LANGDIR should be clone of giellalt/lang-XXX
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

for stems in "$1"/src/fst/stems/*lexc ; do
    gtpos="???"
    noposlex="#"
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
        *) gtpos="+?";;
    esac
    grep -E -o "^[^ :!]+\\$gtpos" "$stems" | while read -r lg ; do
        lemma=${lg%%+*}
        echo "$lemma" | sed -e 's/./ & /g' | sed -e "s/\$/ $gtpos /" |\
            sed -e "s:\$: [? - [ $cyclicRE  ] ]*:" |\
            sed -e "s:^:$cyclicRE +UglyHack | :" |\
            sed -e 's/+/%+/g' -e 's:/:%/:g' > generative.regex
        hfst-regexp2fst -i generative.regex -o generative.hfst -f foma
        hfst-compose -F -1 generative.hfst -2 "$generator" -o generator.hfst
        hfst-fst2strings generator.hfst > generated.strings
        if test -s generated.strings ; then
            uniq < generated.strings | "$(dirname "$0")"/convert.py
        else
            echo "FAILED TO GENERATE $lemma $gtpos"
            echo "$lemma" | hfst-lookup -q "$analyser"
        fi
    done
    if test noposlex != "#" ; then
        grep -E "^[^ ]* *$noposlex" "$stems" | while read -r ll ; do
            lemma=${ll%% *}
            lemma=${lemma%%:*}
            lemma=${lemma%%+*}
            echo "$lemma" | sed -e 's/./ & /g' | sed -e "s/\$/ $gtpos /" |\
                sed -e "s:\$: [? - [ $cyclicRE  ] ]*:" |\
                sed -e "s:^:$cyclicRE +UglyHack | :" |\
                sed -e 's/+/%+/g' -e 's:/:%/:g' > generative.regex
            hfst-regexp2fst -i generative.regex -o generative.hfst -f foma
            hfst-compose -F -1 generative.hfst -2 "$generator" -o generator.hfst
            hfst-fst2strings generator.hfst > generated.strings
            if test -s generated.strings ; then
                uniq < generated.strings | "$(dirname "$0")"/convert.py
            else
                echo "FAILED TO GENERATE $lemma $gtpos"
                echo "$lemma" | hfst-lookup -q "$analyser"
            fi
        done
    fi
done



