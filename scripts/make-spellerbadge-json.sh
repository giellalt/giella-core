#!/bin/bash

# For debugging, uncomment this command:
# set -x

function print_usage() {
    echo "Usage: $0 REPORTFILE"
    echo "Build spellerbadge.json for REPORTFILE (typosreport/report.json)"
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
fi

# Extract values from JSON using grep and sed
true_positive=$(grep -o '"true_positive": [0-9]*' "$reportfile" | sed 's/.*: //')
first_position=$(grep -o '"first_position": [0-9]*' "$reportfile" | sed 's/.*: //')
top_five=$(grep -o '"top_five": [0-9]*' "$reportfile" | sed 's/.*: //')

# Default values
colour=grey
message="N/A"
label="Typostest"

# Check if we got valid values
if test -z "$true_positive" -o -z "$first_position" -o -z "$top_five" ; then
    colour=grey
    message="N/A"
elif test "$true_positive" -eq 0 ; then
    colour=grey
    message="N/A"
else
    # Calculate percentage: (first_position / true_positive) * 100
    firstpercentage=$(echo "scale=1; ($first_position * 100) / $true_positive" | bc)
    # Calculate percentage: (top_five / true_positive) * 100
    top5percentage=$(echo "scale=1; ($top_five * 100) / $true_positive" | bc)
    
    message="${firstpercentage}% / ${top5percentage}%"
    
    # Convert to integer for comparison (bc can't compare decimals directly in test)
    firstpercentage_int=$(echo "($firstpercentage + 0.5) / 1" | bc)
    top5percentage_int=$(echo "($top5percentage + 0.5) / 1" | bc)
    
    # Set color based on percentage thresholds (test both percentages)
    if test "$firstpercentage_int" -lt 40 -o "$top5percentage_int" -lt 50 ; then
        # Very poor
        colour=black
    elif test "$firstpercentage_int" -lt 60 -o "$top5percentage_int" -lt 70 ; then
        # Poor
        colour=red
    elif test "$firstpercentage_int" -lt 80 -o "$top5percentage_int" -lt 90 ; then
        # Medium
        colour=yellow
    else
        # Good
        colour=green
    fi
fi

echo "{ \"schemaVersion\": 1, \"label\": \"$label\", \"message\": \"$message\", \"color\": \"$colour\" }"
