#!/bin/bash
#
# extract-lemmas.sh FILE ["(string1|string2|stringN)"]
#
# Extracts all real lemmas from lexc file FILE, optionally excluding lines
# containing the strings in the second argument (as pased to egrep -v). The
# lemmas are printed to STDOUT.

if test -z "${GTCORE}" ; then
    echo "Unable to determine GTCORE, re-run gtsetup.sh and re-try"
    exit 1
fi

# Wrong usage - short instruction:
if ! test $# -ge 1 ; then
    echo "Usage: $0 INPUT_FILE [\"(EXCLUDE|MATCHING|LINES)\"]"
    exit 1
fi

# Specify a never-matching dummy string if no second argument is given:
if test $2 ; then
    EXTRAREMOVALS=$2
else
    EXTRAREMOVALS="(THISISADUMMYSTRING)"
fi

grep ";" $1 | grep -v "^\!" | \
             egrep -v '(LEXICON| K | Rreal | R |ShCmp|RCmpnd|CmpN/Only|ENDLEX)' | \
             egrep -v "$EXTRAREMOVALS" | \
              sed 's/^[ 	]*//' | \
              grep -v "^\-" | \
              sed 's/% /€/g' | \
              sed 's/%:/¢/g' | \
              sed 's/%#/¥/g' | \
              sed 's/%\(.\)/\1/g' | \
              tr ":+\t" " "  | \
              cut -d " " -f1 | \
              tr -d "#"  | \
              tr "€" " " | \
              tr "¢" ":" | \
              tr "¥" "#" | \
             egrep -v "(^$|^;|_|^[0-9]$|^\!)" | \
              sort -u
