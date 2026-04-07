#!/bin/bash

# For debugging, uncomment this command:
# set -x

function print_usage() {
    echo "Usage: $0 REPORTFILE"
    echo "Build typossize.json for REPORTFILE (typosreport/report.json)"
    echo
    echo "  -h, --help              Print this usage info"
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
    elif test -f "$1"; then
        reportfile="$1"
    else
        echo "$0: unknown option $1"
        print_usage
        exit 1
    fi
    shift
done

# Check if report file exists
if test ! -f "$reportfile" ; then
    echo "$0: Error: Report file not found: $reportfile" >&2
    colour=grey
    message="N/A"
    label="Typos test set"
else
    # Extract true_positive from JSON using jq
    true_positive=$(jq -r '.summary.true_positive // 0' "$reportfile")
    
    # Default values
    label="Typos test set"
    colour=grey
    message="N/A"
    
    # Check if we got a valid value
    if test -z "$true_positive" ; then
        colour=grey
        message="N/A"
    elif test "$true_positive" -eq 0 ; then
        colour=grey
        message="N/A"
    elif test "$true_positive" -lt 100 ; then
        # Experiment
        colour=black
        message="$true_positive"
    elif test "$true_positive" -lt 500 ; then
        # Poor
        colour=red
        message="$true_positive"
    elif test "$true_positive" -lt 1000 ; then
        # Medium
        colour=yellow
        message="$true_positive"
    else
        # Good
        colour=green
        message="$true_positive"
    fi
fi

echo "{ \"schemaVersion\": 1, \"label\": \"$label\", \"message\": \"$message\", \"color\": \"$colour\" }"
