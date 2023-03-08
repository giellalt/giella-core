#!/bin/bash

if test $# != 1 ; then
    echo "Usage: $0 LANGDIR"
    echo
    echo LANGDIR should be clone of giellalt/lang-XXX
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
        *) gtpos="+X";;
    esac
    if test $gtpos = +X ; then
        echo "skipping $stems, do "
        echo "  $(dirname "$0")/generate-from-lexc.bash $1 $stems +X FooBar"
        echo "wiht +X and FooBar set to POS tag or end lexicon used"
        continue
    fi
    "$(dirname "$0")/generate-from-lexc.bash" "$1" "$stems" "$gtpos" "$noposlex"
done
