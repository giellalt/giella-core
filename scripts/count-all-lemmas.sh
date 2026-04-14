#!/bin/bash

# For debugging, uncomment this command:
# set -x

function print_usage() {
    echo "Usage: $0 [OPTIONS...] INPUTDIR"
    echo "Cound lemmas for INPUTDIR (language root dir)"
    echo
    echo "  -h, --help              Print this usage info"
    echo "  -m, --merge-homonyms    Count homonyms as one entry, default=count each homonym"
    echo "  -c, --giella-core PATH  Path to giella-core, if not given will try to find from \$0"
    echo "  -s, --custom-script SCRIPT  Use custom script to count lemmas instead of default"
    echo "                          The script will be called with INPUTDIR as argument and"
    echo "                          should output the lemma count to stdout"
    echo
    echo "Note: If INPUTDIR/src/fst/morphology/lemma-count.sh exists and is executable,"
    echo "      it will be used automatically (unless --custom-script overrides it)."
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
    elif test x$1 = x--merge-homonyms -o x$1 = x-m ; then
        merge_homonyms="true"
    elif test x$1 = x--giella-core -o x$1 = x-c ; then
        giella_core=$2
        shift
    elif test x$1 = x--custom-script -o x$1 = x-s ; then
        custom_script=$2
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

if test "x${giella_core}" = "x" ; then
    # Find giella-core from self:
    SCRIPT=$(realpath "$0")
    GIELLA_CORE=$(dirname "$(dirname "$SCRIPT")")
else
    GIELLA_CORE=${giella_core}
fi

# When calling extract-lemmas.sh, the default is to NOT keep homonyms, specifying -H will keep them
if test "$merge_homonyms" = "true" ; then
    homonyms=""
else
    homonyms="-H"
fi

# Initialise:
lemmacount=0

# Check for custom counting script
# Priority: 1) --custom-script option, 2) language repo's lemma-count.sh, 3) default logic
if test -n "$custom_script" ; then
    # Use manually specified custom script
    if test ! -x "$custom_script" ; then
        echo "$0: Error: Custom script not found or not executable: $custom_script" >&2
        exit 1
    fi
    lemmacount=$("$custom_script" "$inputdir")
elif test -x "$inputdir/src/fst/morphology/lemma-count.sh" ; then
    # Use language repo's lemma-count.sh if it exists
    lemmacount=$("$inputdir/src/fst/morphology/lemma-count.sh" "$inputdir")
fi

# Default logic for standard repository structures
if compgen -G "$inputdir/src/fst/morphology/stems/*.lexc" > /dev/null; then
    lemmacounts=$(for f in "$inputdir"/src/fst/morphology/stems/*.lexc ; do
        "$GIELLA_CORE"/scripts/extract-lemmas.sh $homonyms "$f" | # extract all lemmas for each stem file
    wc -l; done) # ... and count them
    lemmacount=$(echo $lemmacounts | tr ' ' '+' | bc)
elif compgen -G "$inputdir/src/fst/morphology/stems/*.lexd" > /dev/null; then
    # approximate
    lemmacount=$(grep -h -F -v LEXICON "$inputdir"/src/fst/morphology/stems/*.lexd |\
        grep -E -v "^[[:space:]]*\$" |
        wc -l)
fi
echo "$lemmacount"
