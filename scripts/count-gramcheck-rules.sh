#!/bin/bash

# For debugging, uncomment this command:
# set -x

function print_usage() {
    echo "Usage: $0 [OPTIONS...] INPUTDIR"
    echo "Count error-detection rules for INPUTDIR (language root dir)"
    echo
    echo "  -h, --help              Print this usage info"
    echo "  -f, --file FILE         Use FILE instead of the default"
    echo "                          INPUTDIR/tools/grammarcheckers/grammarchecker.cg3"
    echo
}

# Wrong usage - short instruction:
if (( $# < 1 )) ; then
    print_usage
    exit 1
fi

# manual getopt loop... Mac OS X does not have good getopt
while test $# -ge 1 ; do
    if test x$1 = x--help -o x$1 = x-h ; then
        print_usage
        exit 0
    elif test x$1 = x--file -o x$1 = x-f ; then
        cg3file=$2
        shift
    elif test -d "$1"; then
        inputdir="$1"
    else
        echo "$0: unknown option $1"
        print_usage
        exit 1
    fi
    shift
done

if test "x${cg3file}" = "x" ; then
    cg3file="$inputdir/tools/grammarcheckers/grammarchecker.cg3"
fi

if test ! -f "$cg3file" ; then
    echo 0
    exit 0
fi

# Error-detection rules add an error tag (an ampersand-prefixed set, e.g.
# "&msyn-compound") to a reading, following the "RULETYPE:rule-name
# (&errortag) ..." convention used throughout giellalt grammarcheckers.
# Comment lines (starting with #) are ignored. Only the rule name part
# is kept, uniqued and counted, and experimental rules are excluded:
grep -Ev '^[[:space:]]*#' "$cg3file" \
    | grep -E '^[A-Za-z]+:[A-Za-z0-9_.-]+[[:space:]]*\(&' \
    | cut -d' ' -f1 | grep -v 'ADD:x' \
    | uniq | wc -l | tr -d ' '
