#!/bin/bash

# For debugging, uncomment this command:
# set -x

function print_usage() {
    echo "Usage: $0 INPUTDIR"
    echo "Build lemmacount.json for INPUTDIR (language root dir)"
    echo
    echo "  -h, --help              Print this usage info"
    echo "  -c, --giella-core PATH  Path to giella-core, if not given will try to find from $0"
    echo
}

# Wrong usage - short instruction:
if (( $# < 1 || $# > 2)) ; then
    print_usage
    exit 1
fi

# manual getopt loop... Mac OS X does not have good getopt
while test $# -ge 1 ; do
    if test x$1 = x--help -o x$1 = x-h ; then
        print_usage
        exit 0
    elif test x$1 = x--giella-core -o x$1 = x-c ; then
        giella_core=$2
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
    GIELLA_CORE=$(dirname $(dirname "$SCRIPT"))
else
    GIELLA_CORE=${giella_core}
fi

# For lemma counts > 1000, round to nearest 100 and strip final zeros:
round100 () {
    rounded=$( echo "(${1%??}*100)+100" | bc )
    shortened=$(echo "scale=1; ${rounded%??} / 10" | bc)
    echo $shortened
}

# For lemma counts > 10000, round to nearest 1000 and strip final zeros:
round1000 () {
    rounded=$( echo "(${1%???}*1000)+1000" | bc )
    shortened=$(echo ${rounded%???})
    echo $shortened
}

# Default values
label=Lemmas
colour=grey
message="N/A"

lemmacount=$($GIELLA_CORE/scripts/count-all-lemmas.sh $inputdir)

if test "$lemmacount" -eq 0 ; then
    # Invalid = N/A
    colour=grey
    message="N/A"
elif test "$lemmacount" -gt 0 && test "$lemmacount" -lt 1000 ; then
    # Experiment
    colour=black
    message=$lemmacount
elif test "$lemmacount" -ge 1000 && test "$lemmacount" -lt 10000 ; then
    # Alpha
    colour=red
    newlemmacount=$(round100 $lemmacount)
    message="$newlemmacount K"
elif test "$lemmacount" -ge 10000 && test "$lemmacount" -lt 30000 ; then
    # Beta
    colour=yellow
    newlemmacount=$(round100 $lemmacount)
    message="$newlemmacount K"
elif test "$lemmacount" -ge 30000 ; then
    # Production
    colour=green
    newlemmacount=$(round1000 $lemmacount)
    message="$newlemmacount K"
else
    # Invalid = N/A
    colour=grey
    message="N/A"
fi

echo "{ \"schemaVersion\": 1, \"label\": \"$label\", \"message\": \"$message\", \"color\": \"$colour\" }"
