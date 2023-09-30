#!/bin/bash

# For debugging, uncomment this command:
# set -x

function print_usage() {
    echo "Usage: $0 REPONAME"
    echo "Build maturity.json for REPONAME."
    echo
    echo "  -h, --help              Print this usage info"
    echo
}

# Wrong usage - short instruction:
if (( $# < 1 || $# > 1)) ; then
    print_usage
    exit 1
fi

# manual getopt loop... Mac OS X does not have good getopt
while test $# -ge 1 ; do
    if test x$1 = x--help -o x$1 = x-h ; then
        print_usage
        exit 0
    elif test -d "$1"; then
        reponame="$1"
    else
        echo "$0: unknown option $1"
        print_usage
        exit 1
    fi
    shift
done

# Default values
label="Maturity"
colour=grey
message="Undefined"

maturity=$(curl -H "Accept: application/vnd.github.mercy-preview+json" https://api.github.com/repos/giellalt/${reponame}/topics | grep maturity | cut -d'-' -f2 | cut -d'"' -f1)

if test "$maturity" = "" ; then
    # Invalid = N/A
    colour=grey
    message="Undefined"
elif test "$maturity" = "exper" ; then
    # Experiment
    colour=black
    message="Experiment"
elif test "$maturity" = "alpha" ; then
    # Alpha
    colour=red
    message="Alpha"
elif test "$maturity" = "beta" ; then
    # Beta
    colour=yellow
    message="Beta"
elif test "$maturity" = "prod" ; then
    # Production
    colour=green
    message="Production"
else
    # Invalid = N/A
    colour=grey
    message="Undefined"
fi

echo "{ \"schemaVersion\": 1, \"label\": \"$label\", \"message\": \"$message\", \"color\": \"$colour\" }"
