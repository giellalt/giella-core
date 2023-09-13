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

POS='[ "+N" | "+A" | "+V" | "+Adv" | "+Pron" | "+CS" | "+CC" | "+Adp" | "+Po" | "+Pr" | "+Interj" | "+Pcle" | "+Num" ]'

AREATAGRGX=$( $SED -e 's/^/\"/'  -e 's/$/\"/' < $TAGFILE | tr '\n' '|' | \
              $SED -e 's/^/\[ /' -e 's/|$/ \]/' -e 's/|/ | /g')

# Print header text:
echo "# This is a generated file - do not edit!"      > $REGEXFILE
echo "# The script file used to generate it is:"     >> $REGEXFILE
echo "# $0"                                          >> $REGEXFILE
echo "# The generated regex inserts area tags"       >> $REGEXFILE
echo "# before all POS tags unless there is already" >> $REGEXFILE
echo "# an area tag there. It should be used in"     >> $REGEXFILE
echo "# tandem with another script that will make"   >> $REGEXFILE
echo "# all area tags optional for generation. This" >> $REGEXFILE
echo "# way one can always generate a word form,"    >> $REGEXFILE
echo "# even in cases where the area tag makes no"   >> $REGEXFILE
echo "# sense, but the area tag is inherited."       >> $REGEXFILE
echo >> $REGEXFILE
echo "# This filter inserts all Area tags in front of the POS tags, if NO area tags already exist in that position" >> $REGEXFILE
echo >> $REGEXFILE

echo "[" >> $REGEXFILE

echo " $AREATAGRGX <- [..] ||" >> $REGEXFILE;

echo "[ \"-\" | .#. | \"#\" ]" >> $REGEXFILE

echo "\\${AREATAGRGX}* _ $POS"    >> $REGEXFILE

echo "] ;" >> $REGEXFILE
