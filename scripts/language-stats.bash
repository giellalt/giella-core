#!/bin/bash

if test $# -lt 1 ; then
    echo "Usage: $0 LANGUAGECODEs..."
    echo
    exit 1
fi

for ll in "$@" ; do
    echo "$ll"
    cat "$GTLANGS/lang-$ll"/src/fst/stems/*.lexc |\
        sed -e 's/!.*//' |\
        grep -F -v LEXICON |\
        grep -E -v -c '^[[:space:]]*$' |\
        sed -e 's/$/ root morphs or similar/'
    cat "$GTLANGS/lang-$ll"/src/fst/generated_files/*.lexc |\
        sed -e 's/!.*//' |\
        grep -F -v LEXICON |\
        grep -E -v -c '^[[:space:]]*$' |\
        sed -e 's/$/ shared root morphs (proper nouns, symbols, etc.)/'
done
