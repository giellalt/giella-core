#!/bin/bash

# For debugging, uncomment this command:
# set -x

function print_usage() {
    echo "Usage: $0 [OPTIONS...] INPUTFILE [INPUTFILE ...]" >&2
    echo "Extract lemmas from INPUTFILE(S) (lexc). Avoid affix files in the input." >&2
    echo >&2
    echo "  -h, --help             Print this usage info" >&2
    echo "  --exclude '(pattern)'  Exclude (egrep) patterns from the lemma list" >&2
    echo "  --include '(pattern)'  Include (egrep) patterns from the lemma list" >&2
    echo "  -k --keep-contlex      Keep the continuation lexicon in the output" >&2
    echo "  -H --keep-homonyms     Keep homonymy tags to separate such lemmas" >&2
    echo >&2
}

# Wrong usage - short instruction:
if ! test $# -ge 1 ; then
    print_usage
    exit 1
fi

# manual getopt loop... Mac OS X does not have good getopt
while test $# -ge 1 ; do
    if test "x$1" = x--help -o "x$1" = x-h ; then
        print_usage
        exit 0
    elif test "x$1" = x--keep-contlex -o "x$1" = x-k ; then
        keep_contlex=true
    elif test "x$1" = x--keep-homonyms -o "x$1" = x-H ; then
        keep_homonyms=true
    elif test "x$1" = x--exclude ; then
        excludepattern="$2"
        shift
    elif test "x$1" = x--include ; then
        includepattern="$2"
        shift
    elif test -f "$1"; then
        inputfiles="$inputfiles $1"
    elif test -z "$1" ; then
        # apparently this is possible
        shift
    else
        echo "$0: unknown option $1" >&2
        print_usage
        exit 1
    fi
    shift
done

# Only grep if there is a pattern to grep on, or everything will vanish:
exclgrep () {
    # Check that the grep pattern isn't empty:
    if test "x$*" != "x"; then
        grep -E -v "$@"
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
        perl -pe 's/(\w)\+(Hom[0-9])/\1__\2__/' ;
        perl -pe 's/(\w)\+(G[37])/\1__\2__/'
    else
        cat
    fi
}

# The main lemma extraction thing:
cat $inputfiles | grep ";"                              | # grep only lines containing ;
    grep -E -v "^[[:space:]]*(!|@|<|\+)"                | # do NOT grep lines beginning with (space +) !, @ or <
    keep_hom_tags                                       | # treat homonyms special
    grep -E -v "^[[:space:]]*[[:alnum:]_-]+[[:space:]]*;" | # do NOT grep lines containing ONLY a continuation lexicon ref
    grep -E -v "(LEXICON| K |ENDLEX|\+Err/|DerSub)"      | # do NOT grep lines containing a number of generally known wrong stuff
    exclgrep "$excludepattern"                          | # do NOT grep things specified in each test script
    grep -E  "$includepattern"                          | # DO grep things specified in each test script if specified
    sed 's/^[ 	]*//'                             | # Remove initial whitespace
    sed 's/% /€/g'                                 | # escape lexc escapes
    sed 's/%:/¢/g'                                 | # escape lexc escapes
    sed 's/%#/¥/g'                                 | # escape lexc escapes
    sed 's/%@/£/g'                                 | # escape lexc escapes
    perl -pe 's/\+(?![A-Z])(?!v[0-9])/xxplussxx/g' | # escape + when not being the first letter in a tag
    sed 's/%\(.\)/\1/g'                | # simplify lexc escapes
    tr '\t' ' '                        | # replate tabs with spaces
    tr -s ' '                          | # squash spaces to one
    sed 's/:/XXXXX/'                   | # escape upper-lower mark before next step
    cut_fields                         | # extract lemma, possibly contlex if specified
    sed 's/@.* / /'                    | # remove lemma final flag diacritics
    sed 's/XXXXX.* / /'                | # remove lower part
    sed 's/XXXXX.*//'                  | # remove lower part
    tr -d "#"                          | # remove word boundaries in lemmas (should not exist, but just to be safe)
    tr " " "\t"                        | # change space to tabs - why??
    sed 's/€/ /g'                      | # restore lexc escapes to their lexical form
    sed 's/¢/:/g'                      | # restore lexc escapes to their lexical form
    sed 's/£/@/g'                      | # restore lexc escapes to their lexical form
    sed 's/¥/#/g'                      | # restore lexc escapes to their lexical form
    grep -E -v "(^$|^;|^[0-9]$|^!)"     | # remove useless lines
    perl -pe 's/__(Hom[0-9]+)__/\+\1/' | # restore homonym tags if kept
    perl -pe 's/__(G[37]+)__/\+\1/'    | # restore homonym tags if kept
    sed 's/xxplussxx/\+/g'             | # restore literal, escaped + sign
    sort -u
