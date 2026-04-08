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

# Function to format number as k with 1 decimal (e.g. 1000 -> 1.0k, 1234 -> 1.2k)
format_count() {
    local count=$1
    if test "$count" -ge 1000 ; then
        awk "BEGIN {printf \"%.1fk\", $count / 1000}"
    else
        echo "$count"
    fi
}

# Extract values from JSON using jq
true_positive=$(jq -r '.summary.true_positive // 0' "$reportfile")
first_position=$(jq -r '.summary.first_position // 0' "$reportfile")
top_five=$(jq -r '.summary.top_five // 0' "$reportfile")

# Default values
colour=grey
message="N/A"
label="Speller sugg."

# Check if we got valid values
if test -z "$true_positive" -o -z "$first_position" -o -z "$top_five" ; then
    colour=grey
    message="N/A"
elif test "$true_positive" -eq 0 ; then
    colour=grey
    message="N/A"
else
    # Calculate percentage with proper rounding to 1 decimal: (first_position / true_positive) * 100
    firstpercentage=$(awk "BEGIN {printf \"%.1f\", ($first_position * 100) / $true_positive}")
    # Calculate percentage with proper rounding to 1 decimal: (top_five / true_positive) * 100
    top5percentage=$(awk "BEGIN {printf \"%.1f\", ($top_five * 100) / $true_positive}")
    
    # Format true_positive count
    formatted_count=$(format_count "$true_positive")
    
    message="${firstpercentage}%/${top5percentage}%/${formatted_count}"
    
    # Convert to integer for comparison
    firstpercentage_int=$(awk "BEGIN {printf \"%.0f\", $firstpercentage}")
    top5percentage_int=$(awk "BEGIN {printf \"%.0f\", $top5percentage}")
    
    # Set color based on percentage thresholds (test both percentages)
    if test "$firstpercentage_int" -lt 40 -o "$top5percentage_int" -lt 50 -o "$true_positive" -lt 100 ; then
        # Very poor
        colour=black
    elif test "$firstpercentage_int" -lt 60 -o "$top5percentage_int" -lt 70 -o "$true_positive" -lt 500 ; then
        # Poor
        colour=red
    elif test "$firstpercentage_int" -lt 80 -o "$top5percentage_int" -lt 90 -o "$true_positive" -lt 1000 ; then
        # Medium
        colour=yellow
    else
        # Good
        colour=green
    fi
fi

echo "{ \"schemaVersion\": 1, \"label\": \"$label\", \"message\": \"$message\", \"color\": \"$colour\" }"
