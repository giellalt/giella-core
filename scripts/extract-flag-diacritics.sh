#!/bin/bash

# From a list of GT/Divvun tags of the form +Abc/XYZ, extract all semantic tags
# of the form +Sem/abc; if no such tags are found, print a dummy tag instead, to
# make the generated regex valid.

REGEX="^@.+@$"

if ! test $# -eq 2 ; then
    echo
    echo "Usage: $0 INPUTFILE OUTPUTFILE"
    echo
    echo "INPUTFILE  = file with list of all tags in a lexical transducer"
    echo "OUTPUTFILE = the subset of tags matching the regex ${REGEX}"
    echo
    exit 1
fi

if ! grep -E "${REGEX}" $1; then
    echo "${REGEX}N.DummyFlag${REGEX}" > $2
else
    grep -E "${REGEX}" $1 > $2
fi
