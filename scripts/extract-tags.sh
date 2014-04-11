#!/bin/bash

# From a list of GT/Divvun tags of the form +Abc/XYZ, extract all semantic tags
# of the form +Sem/abc; if no such tags are found, print a dummy tag instead, to
# make the generated regex valid.

if ! test $# -eq 3 ; then
    echo
    echo "Usage: $0 INPUTFILE OUTPUTFILE MATCHSTRING"
    echo
    echo "INPUTFILE   = file with list of all tags in a lexical transducer"
    echo "OUTPUTFILE  = the subset of tags matching the regex ${REGEX}"
    echo "MATCHSTRING = the string used to match the tags to be extracted"
    echo
    exit 1
fi

REGEX=$3

if ! grep -F "${REGEX}" $1; then
    echo "${REGEX}DummyTag" > $2
else
    grep -F "${REGEX}" $1 > $2
fi
