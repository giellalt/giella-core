#!/bin/bash

function print_usage() {
    echo "Usage: $0 [OPTIONS...]"
    echo "Prepare Autotools build infrastructure"
    echo
    echo "  -h, --help          print this usage info"
    echo
}

# manual getopt loop... Mac OS X does not have good getopt
while test $# -ge 1 ; do
    if test x$1 = x--help -o x$1 = x-h ; then
        print_usage
        exit 0
    else
        echo
        echo "ERROR: $0: unknown option $1"
        print_usage
        exit 1
    fi
    shift
done

echo
echo "Initial automake setup of $(basename $(pwd))"
echo

# autoreconf should work for most platforms
autoreconf -i
