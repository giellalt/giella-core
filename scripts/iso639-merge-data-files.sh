#!/bin/bash

# For debugging, uncomment this command:
# set -x

function print_usage() {
    echo "Usage: $0 ISO639-3.tab ISO639-5.ttl ISO639-3.txt"
    echo "Merge downloaded ISO 639 3 & 5 files to one file used internally"
    echo
    echo "  -h, --help              Print this usage info"
    echo
}

# Wrong usage - short instruction:
if (( $# < 3 || $# > 3)) ; then
    print_usage
    exit 1
fi

# manual getopt loop... Mac OS X does not have good getopt
while test $# -ge 1 ; do
    if test x$1 = x--help -o x$1 = x-h ; then
        print_usage
        exit 0
    elif test -f "$1"; then
        iso639_3="$1"
        iso639_5="$2"
        iso639_out="$3"
        shift
        shift
    else
        echo "$0: unknown option $1"
        print_usage
        exit 1
    fi
    shift
done

# Strip returns from source file when copying to our data file:
tr -d '\r' < "$iso639_3" > "$iso639_out"

echo "# Beginning of ISO 639-5 data:" >> $iso639_out

grep -v 'BEGIN /vocabulary/iso639-5/iso639-5_Language' "$iso639_5" | # Start by grepping away noise
    egrep '(^# BEGIN|^madsrdf:authoritativeLabel)' | # Then grep out the interesting lines
    grep -A 1 '# BEGIN' | # We only need the first language family name
    grep -v '^-' | # Remove record separator made by previous grep
    cut -d'/' -f4 | # Clean data, first step
    cut -d'"' -f2- | # Clean data, second step
    tr '\n' '\t' | # More cleaning - getting all on one line
    sed -e 's/"@en,/\n/g' | # Replace the end of data sequence with a newline
    sed -e 's/^\t//' | # Remove inital tabs, an artifact of previous steps, and then format the data
    sed -e 's/\t/\t\t\t\tM\tS\t/' \
    >> "$iso639_out"
