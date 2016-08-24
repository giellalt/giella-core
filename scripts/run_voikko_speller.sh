#!/bin/bash

# Take a list of GT/Divvun semantic tags of the form +Abc/XYZ, and turn it into
# a regex to reorder those tags wrt a short list of POS tags.

if ! test $# -eq 4 -o $# -eq 5 ; then
    echo
    echo "Runs the command line speller 'voikkospell' with input from INFILE,"
    echo "writing the result to OUTFILE for the language given by LANGCODE,"
    echo "optionally using the zhfst file found in DICTDIR."
    echo
    echo "Usage: $0 INFILE OUTFILE TIMEUSE LANGCODE [DICTDIR]"
    echo
    echo "INFILE   = list of potential misspellings, one word pr line"
    echo "OUTFILE  = output from speller"
    echo "TIMEUSE  = filename for storing the elapsed time for the speller run"
    echo "LANGCODE = ISO 639-1, -2 or -3 language code for the language to test"
    echo "           Please use the 639-1 code if there is one."
    echo "DICTDIR  = directory containing a subdir 3/ containin a zhfst file."
    echo "           Optional. If not specified, speller files from the default"
    echo "           directories will be used."
    echo
    exit 1
fi

INFILE=$1
OUTFILE=$2
TIMEUSE=$3
LANGCODE=$4
DICTDIR=$5

VOIKKOSPELL=voikkospell

{ time $VOIKKOSPELL -s -d $LANGCODE-x-standard -p $DICTDIR/ ignore_dot=1 \
        < $INFILE > $OUTFILE 2>/dev/null ; } 2> $TIMEUSE
