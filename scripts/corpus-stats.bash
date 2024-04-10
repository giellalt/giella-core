#!/bin/bash

if test $# -lt 1 ; then
    echo "Usage: $0 LANGUAGECODEs..."
    echo
    exit 1
fi


for ll in "$@" ; do
    for copyright in "" -x-closed ; do
        CORPUS="$GTLANGS/corpus-$ll$copyright/converted/"
        TOKENISER="$GTLANGS/lang-$ll/tools/tokenisers/tokeniser-disamb-gt-desc.pmhfst"
        ANALYSER="$GTLANGS/lang-$ll/src/fst/analyser-gt-desc.hfstol"
        echo "$ll$copyright"
        if ! test -f "$ll$copyright.text" ; then
            ccat -l "$ll" "$CORPUS" > "$ll$copyright.text"
        fi
        if ! test -f "$ll$copyright.tokens" ; then
            cat "$ll$copyright.text" | hfst-tokenise "$TOKENISER" > "$ll$copyright.tokens"
        fi
        if ! test -f "$ll$copyright.freqs" ; then
            sort < "$ll$copyright.tokens" | uniq -c | sort -nr > "$ll$copyright.freqs"
        fi
        printf "paragraphs tokens characters\n"
        wc "$ll$copyright.text"
        python "$GTHOME/scripts/freq-evals.py" -a "$ANALYSER" -i "$ll$copyright.freqs" \
            -m "$ll$copyright.missinglist" -n "$ll$copyright.prodlist"
    done
    for gecs in goldstandard correct-no-gs ; do
        CORPUS="$GTLANGS/corpus-$ll/$gecs/converted/"
        TOKENISER="$GTLANGS/lang-$ll/tools/tokenisers/tokeniser-disamb-gt-desc.pmhfst"
        ANALYSER="$GTLANGS/lang-$ll/src/fst/analyser-gt-desc.hfstol"
        echo "$ll$gecs"
        if ! test -f "$ll$gecs.text" ; then
            ccat -l "$ll" "$CORPUS" > "$ll$gecs.text"
        fi
        if ! test -f "$ll$gecs.tokens" ; then
            cat "$ll$gecs.text" | hfst-tokenise "$TOKENISER" > "$ll$gecs.tokens"
        fi
        if ! test -f "$ll$gecs.freqs" ; then
            sort < "$ll$gecs.tokens" | uniq -c | sort -nr > "$ll$gecs.freqs"
        fi
        printf "paragraphs tokens characters\n"
        wc "$ll$gecs.text"
        python "$GTHOME/scripts/freq-evals.py" -a "$ANALYSER" -i "$ll$gecs.freqs" \
            -m "$ll$copyright.missinglist" -n "$ll$copyright.prodlist"

    done
done
