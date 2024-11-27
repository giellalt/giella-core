#!/bin/bash
if test $# -lt 2; then
    echo "Usage: $0 LANGCODE CORPUSDIR"
    exit 1
fi
LANG=$1
CORPUS=$2
if ! test -e "$CORPUS" ; then
    echo "$0: could not find $1, try:"
    ls -R "$GTLANGS/corpus-$1/converted/"
    exit 1
fi
ANALYSER="$GTLANGS/lang-$1/tools/analysers/modes/trace-$1-analyser.mode"
if ! test -f "$ANALYSER" ; then
    echo "$0: missing analyser mode, configure $1 with --enable-analyser-tool"
    echo "and make and make dev and try again"
    exit 1
fi
ANALYSED=$(basename "$CORPUS" .xml).cg3text
ccat "$CORPUS" | "$ANALYSER" > "$ANALYSED"
python vislcg2ud.py -i "$ANALYSED" \
    -o "$(basename "$ANALYSED" .cg3text).conllu"
