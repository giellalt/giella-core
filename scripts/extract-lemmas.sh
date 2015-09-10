#!/bin/bash

# For debugging, uncomment this command:
# set -x

function print_usage() {
    echo "Usage: $0 [OPTIONS...] INPUTFILE"
    echo "Extract lemmas from INPUTFILE (lexc)"
    echo
    echo "  -h, --help             Print this usage info"
    echo "  --exclude '(pattern)'  Exclude (egrep) patterns from the lemma list"
    echo "  --include '(pattern)'  Include (egrep) patterns from the lemma list"
    echo "  -k --keep-contlex      Keep the continuation lexicon in the output"
    echo "  -H --keep-homonyms     Keep homonymy tags to separate such lemmas"
    echo
}

# Wrong usage - short instruction:
if ! test $# -ge 1 ; then
    print_usage
    exit 1
fi

# manual getopt loop... Mac OS X does not have good getopt
while test $# -ge 1 ; do
    if test x$1 = x--help -o x$1 = x-h ; then
        print_usage
        exit 0
    elif test x$1 = x--keep-contlex -o x$1 = x-k ; then
        keep_contlex=true
    elif test x$1 = x--keep-homonyms -o x$1 = x-H ; then
        keep_homonyms=true
    elif test x$1 = x--exclude ; then
        if test -z "$2" ; then
            print_usage
            exit 1
        else
            excludepattern="$2"
            shift
        fi
    elif test x$1 = x--include ; then
        if test -z "$2" ; then
            print_usage
            exit 1
        else
            includepattern="$2"
            shift
        fi
    elif test -f "$1"; then
        inputfile="$1"
        shift
    else
        echo "$0: unknown option $1"
        print_usage
        exit 1
    fi
    shift
done

# Only grep if there is a pattern to grep on, or everything will vanish:
exclgrep () {
    # Check that the grep pattern isn't empty:
    if test "x$@" != "x"; then
        egrep -v "$@"
    # If it is, just let everything pass through using cat:
    else
        cat
    fi
}

# Cut the requested fields, the default is only the lemma (f1):
# Also do some additional mangling, since we need to remove tags while keeping
# the continuation lexicon, if asked to.
cut_fields () {
    if test "$keep_contlex" = "true" ; then
        tr ":\t"  " " | cut -d " " -f1,2 | perl -pe "s/\+[^\t ]+//"
    else
        tr ":+\t" " " | cut -d " " -f1
    fi
}

# Use this function to keep homonymy tags depending on the option given:
keep_hom_tags () {
    if test "$keep_homonyms" = "true" ; then
        perl -pe 's/(\w)\+(Hom[0-9])/\1__\2__/'
    else
        cat
    fi
}

# The first lines do:
# 1. grep only lines containing ;
# 2. do NOT grep lines beginning with (space +) !, @ or <
# 3. do NOT grep lines containing ONLY a continuation lexicon ref
# 4. do NOT grep lines containing a number of generally known wrong stuff
# 5. do NOT grep things specified in each test script
# The rest is general mangling, the XXXXX part is needed to take care of
# "lemma:stem CONTLEX" vs "word CONTLEX" when retaining the CONTLEX.
# The penultimate perl s/__Hom..// thing is to restore the homonymy tags if kept
grep ";" $inputfile \
   | egrep -v "^[[:space:]]*(\!|\@|<|\+)" \
   | keep_hom_tags \
   | egrep -v "^[[:space:]]*[[:alpha:]_-]+[[:space:]]*;" \
   | egrep -v "(LEXICON| K |ENDLEX|\+Err\/Lex)" \
   | exclgrep "$excludepattern" \
   | egrep    "$includepattern" \
   | sed 's/^[ 	]*//' \
   | sed 's/% /€/g' \
   | sed 's/%:/¢/g' \
   | sed 's/%#/¥/g' \
   | sed 's/%@/£/g' \
   | sed 's/%\(.\)/\1/g' \
   | tr -s ' ' \
   | sed 's/:/XXXXX/' \
   | cut_fields \
   | sed 's/@.* / /' \
   | sed 's/XXXXX.* / /' \
   | sed 's/XXXXX.*//' \
   | tr -d "#"  \
   | tr " " "\t" \
   | sed 's/€/ /g' \
   | sed 's/¢/:/g' \
   | sed 's/£/@/g' \
   | sed 's/¥/#/g' \
   | egrep -v "(^$|^;|^[0-9]$|^\!)" \
   | perl -pe 's/__(Hom[0-9]+)__/\+\1/' \
   | sort -u
