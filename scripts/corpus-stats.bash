#!/bin/bash

if test $# -lt 1 ; then
    echo "Usage: $0 LANGUAGECODEs..."
    echo
    exit 1
fi


for ll in "$@" ; do
    CORPUS="$GTLANGS/corpus-$ll/converted/"
    TOKENISER="$GTLANGS/lang-$ll/tools/tokenisers/tokeniser-disamb-gt-desc.pmhfst"
    ANALYSER="$GTLANGS/lang-$ll/src/analyser-gt-desc.hfstol"
    echo "$ll"
    if ! test -f "$ll.tokens" ; then
        ccat -l "$ll" "$CORPUS" | hfst-tokenise "$TOKENISER" > "$ll.tokens"
    fi
    if ! test -f "$ll.freqs" ; then
        sort < "$ll.tokens" | uniq -c | sort -nr > "$ll.freqs"
    fi
    python "$GTHOME/scripts/freq-evals.py" -a "$ANALYSER" -i "$ll.freqs" \
        -m "$ll.missinglist"
done
