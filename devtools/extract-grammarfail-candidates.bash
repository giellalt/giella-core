#!/bin/bash
# script to extract candidates for grammar error corpus based on positive
# matches in current grammar checker:
# https://giellalt.github.io/proof/gramcheck/extracting-precision-sentences.html
#set -x

# todo:
# - remove space at end of sents
# - fix pilcrow sign stuff
# - actually bracketise otputtesd yam,e

function rebrack_errs() {
    #rev | cut -d '"' -f 2 | rev |\
    python "$GTCORE/devtools/testify.py" |\
        sed -e 's/^/ - "/' -e 's/ *$/"/'
}

function plain_yaml() {
    rev | cut -d '"' -f 2 | rev |\
        sed -e 's^/ - "/' -e 's/ *$/"/'
}

function plain_sents() {
    rev | cut -d '"' -f 2 | rev
}

if test $# -lt 1 ; then
    echo "Usage: $0 LANGCODE [CORPUS-DIR [VARIANT]]"
    echo
    echo "LANGCODE should be three-letter name of langs- and corpus- repos."
    echo "if CORPUS is not given, is extracted from corpus-LANGCODE."
    echo "if VARIANT is not given, divvun-checker uses the dafault variant."
    echo
    echo "Environment variable GTLANGS must point to root of giellalt github"
    exit 1
fi
LANGCODE=$1
LANGDIR=$GTLANGS/lang-$LANGCODE/
if ! test -d $LANGDIR ; then
    echo "missing $LANGDIR"
    exit 1
fi
shift
if test $# -ge 1 ; then
    CORPUSDIR=$1
    shift
else
    CORPUSDIR=$GTLANGS/corpus-$LANGCODE/converted/
fi
if ! test -d $CORPUSDIR ; then
    echo "missing $CORPUSDIR"
    exit 1
fi
if test $# -ge 1 ; then
    VARIANT="-n $1"
    shift
else
    VARIANT=
fi
if ! test -f "$LANGDIR/tools/tokenisers/tokeniser-disamb-gt-desc.pmhfst" ; then
    echo "missing $LANGDIR/tools/tokenisers/tokeniser-disamb-gt-desc.pmhfst"
    echo "$LANGDIR must be built with --enable-tokenisers"
    exit 1
fi
if ! test -f "$LANGDIR/tools/grammarcheckers/$LANGCODE.zcheck" ; then
    echo "missing $LANGDIR/tools/grammarcheckers/$LANGCODE.zcheck"
    echo "$LANGDIR must be built with --enable-grammarchecker"
    exit 1
fi
if ! test -f "$GTCORE/devtools/testify.py" ; then
    echo "missing $GTCORE/devtools/testify.py, maybe update giella-core"
    exit 1
fi

if ! test -f candidates-$LANGCODE.json ; then
    ccat -l "$LANGCODE" "$CORPUSDIR" |\
        hfst-tokenise -i "$LANGDIR/tools/tokenisers/tokeniser-disamb-gt-desc.pmhfst" |\
        sed 's/ \([.?!] \)/\1£/g;'|\
        sed 's/£/\n/g' |\
        sed 's/ \([:;,]\)/\1/g;' |\
        divvun-checker -a "$LANGDIR/tools/grammarcheckers/$LANGCODE.zcheck" \
            $VARIANT |\
        grep -F -v '"errs":[]' > "candidates-$LANGCODE.json"
else
    echo "skipped creating candidates-$LANGCODE.json already exists"
fi
echo "intermediate results saved in candidates-$LANGCODE.json"
echo "automatically creating taglist.txt for candidates per type"
jq .errs[][3] "candidates-$LANGCODE.json" |\
    sort | uniq | tr -d '"' |\
    grep -F -v "DELETE" > taglist.txt
for t in $(<taglist.txt) ; do
    printf -- "---\nConfig:\n  Spec: ../pipespec.xml\n" > "candidates-$t.yaml"
    printf "  Variant: %sgram-dev\n\n" "$LANGCODE" >> "candidates-$t.yaml"
    printf "Tests:\n" >> "candidates-$t.yaml"
    grep -F "$t" < "candidates-$LANGCODE.json" |\
        rebrack_errs "$t" | sed -e 's/ *¶ *//g'  >> "candidates-$t.yaml"
    echo "yaml test candidates for $t saved in candidates-$t.yaml"
done
for t in $(<taglist.txt) ; do
    echo > "sents-$t.txt"
    grep -F "$t" < "candidates-$LANGCODE.json" |\
        plain_sents "$t" | sed -e 's/ *¶ *//g' >> "sents-$t.txt"
    echo "plain sentences for $t saved in sents-$t.txt"
done
echo "see files named candidates-[errorcode].yaml and sents-[errorcode].txt"
