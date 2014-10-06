#!/bin/bash

# Take a list of GT/Divvun semantic tags of the form +Abc/XYZ, and turn it into
# a regex to reorder those tags wrt a short list of POS tags.

if ! test $# -eq 2 ; then
    echo
    echo "Usage: $0 OUTFILE TAGFILE"
    echo
    echo "OUTFILE = regex file to be created"
    echo "TAGFILE = a file with the list of derivation tags"
    echo
    exit 1
fi

REGEXFILE=$1
TAGFILE=$2

SED=sed

# The list of POS's to move semantic tags for (use underscore for
# multitag POS's):

POSes="%+N %+A %+N_%+Prop"

# Print header text:
echo "# This is a generated file - do not edit!"    > $REGEXFILE
echo "# The generated regex reorders all semantic" >> $REGEXFILE
echo "# tags with respect to some POS tags."       >> $REGEXFILE

# Loop over the list of POS's requiring semantic tag reordering:
for POS in $POSes; do
    # replace _ with space in POS
    REALPOS=$(echo $POS | tr '_' ' ')
    echo "" >> $REGEXFILE
    echo "# $REALPOS" >> $REGEXFILE

    # escape characters special to Xerox regex, then create the regex, and
    # finally replace the last comma with a semicolon to end the regex.
    $SED   's/\([+/_-]\)/%\1/g' $TAGFILE \
    | $SED "s/^\(.*\)/$REALPOS \1 <- \1 $REALPOS ,/" \
    | $SED '$ s/,/;/' \
    >> $REGEXFILE
done
