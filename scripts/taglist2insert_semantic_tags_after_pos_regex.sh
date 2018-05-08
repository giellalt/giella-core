#!/bin/bash

# Take a list of GT/Divvun semantic tags of the form +Abc/XYZ, and turn it into
# a regex to insert those tags after POS tags. This regex goes together with
# another one that removes semantic tags _before_ pos tags, so that the total
# effect is that the semantic tags are moved from before to after the pos tags.

if ! test $# -eq 2 ; then
    echo
    echo "Usage: $0 OUTFILE TAGFILE"
    echo
    echo "OUTFILE = regex file to be created"
    echo "TAGFILE = a file with the list of semantic tags"
    echo
    exit 1
fi

REGEXFILE=$1
TAGFILE=$2

SED=sed

# Print header text:
echo "# This is a generated file - do not edit!"      > $REGEXFILE
echo "# The script file used to generate it is:"     >> $REGEXFILE
echo "# $0"                                          >> $REGEXFILE
echo "# The generated regex inserts semantic tags"   >> $REGEXFILE
echo "# after some POS tags. It should be used in"   >> $REGEXFILE
echo "# tandem with another script that will remove" >> $REGEXFILE
echo "# the semantic tags before the same POS's, so" >> $REGEXFILE
echo "# that the total effect will be that the tags" >> $REGEXFILE
echo "# are moved."                                  >> $REGEXFILE

$SED 's/^\(.*\)$/[ "\1"     <- [..] || "\1" ( ? ) [ "+N" | "+A" ]    "+Prop" _ ,,\
  "\1"     <- [..] || "\1" ( ? ) [ "+N" | "+A" ] _ \\"+Prop"   ] .o./' $TAGFILE \
    | $SED '$ s/ .o./ ;/' \
    >> $REGEXFILE
