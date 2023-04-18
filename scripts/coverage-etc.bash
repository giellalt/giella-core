#!/bin/bash

if test $# -lt 1 ; then
    echo "Usage: $0 LANGUAGECODEs..."
    echo
    exit 1
fi

for ll in "$@" ; do
    echo -n "words in $ll: "
    cat "$GTLANGS/lang-$ll"/src/fst/stems/*.lexc |\
        sed -e 's/!.*//' |\
        grep -F -v LEXICON |\
        grep -E -v '^[[:space:]]*$' |\
        wc -l
    echo -n "covarega for $ll: "
    ccat "$GTFREE/converted/$ll" |\
        sed -e 's/¶//g' -e 's:[]^/{}\\@$[]:\\&:g' -e 's/[<>]//g' |\
        hfst-proc "$GTLANGS/lang-$ll"/src/analyser-gt-desc.hfstol > "$ll.apes"
    tr '^' '\n' < "$ll.apes" > "$ll.tokens"
    echo -n "tokens: "
    wc -l < "$ll.tokens"
    echo -n "OOVs: "
    fgrep -F -c "/*" < "$ll.tokens"
done
