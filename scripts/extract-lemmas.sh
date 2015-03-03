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

inputfile=$1
shift

# Specify a never-matching dummy string if no second argument is given:
if test "x$@" != "x"; then
    EXTRAREMOVALS=$@
else
    EXTRAREMOVALS="(THISISADUMMYSTRING)"
fi

# Debug:
# printf "$0 $inputfile $@\n" 1>&2
# printf "Extra removals: $EXTRAREMOVALS\n" 1>&2

# The first lines do:
# 1. grep only lines containing ;
# 2. do NOT grep lines beginning with (space +) !, @ or <
# 3. do NOT grep lines containing ONLY a continuation lexicon ref
# 4. do NOT grep lines containing a number of generally known wrong stuff
# 5. do NOT grep things specified in each test script
# The rest is general mangling
grep ";" $inputfile \
   | egrep -v "^[[:space:]]*(\!|\@|<)" \
   | egrep -v "^[[:space:]]*[[:alpha:]]+[[:space:]]*;" \
   | egrep -v '(LEXICON| K | Rreal | R |ShCmp|RCmpnd|CmpN/Only|ENDLEX|\/LexSub)'\
   | egrep -v "$EXTRAREMOVALS" \
   | sed 's/^[ 	]*//' \
   | grep -v "^\-" \
   | sed 's/% /€/g' \
   | sed 's/%:/¢/g' \
   | sed 's/%#/¥/g' \
   | sed 's/%\(.\)/\1/g' \
   | tr ":+\t" " "  \
   | cut -d " " -f1 \
   | tr -d "#"  \
   | tr "€" " " \
   | tr "¢" ":" \
   | tr "¥" "#" \
   | egrep -v "(^$|^;|_|^[0-9]$|^\!)" \
   | sort -u
