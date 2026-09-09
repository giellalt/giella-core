#!/bin/bash

# For debugging, uncomment this command:
# set -x

function print_usage() {
    echo "Usage: $0 [OPTIONS...] INPUTDIR"
    echo "Build gramcheck-rules.json for INPUTDIR (language root dir)"
    echo
    echo "  -h, --help              Print this usage info"
    echo "  -c, --giella-core PATH  Path to giella-core, if not given will try to find from \$0"
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

# Default values
label="GramCheck rules"
colour=grey
message="N/A"

rulecount=0
rulecount=$($GIELLA_CORE/scripts/count-gramcheck-rules.sh $inputdir)

if test "$rulecount" -eq 0 ; then
    # Invalid = N/A
    colour=grey
    message="N/A"
elif test "$rulecount" -gt 0 && test "$rulecount" -lt 50 ; then
    # Experiment
    colour=black
    message=$rulecount
elif test "$rulecount" -ge 50 && test "$rulecount" -lt 200 ; then
    # Alpha
    colour=red
    message=$rulecount
elif test "$rulecount" -ge 200 && test "$rulecount" -lt 500 ; then
    # Beta
    colour=yellow
    message=$rulecount
else
    # Production
    colour=green
    message=$rulecount
fi

echo "{ \"schemaVersion\": 1, \"label\": \"$label\", \"message\": \"$message\", \"color\": \"$colour\" }"
