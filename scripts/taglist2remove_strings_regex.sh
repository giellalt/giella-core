#!/bin/bash

# Create a filter regex to remove all strings not belonging to the requested
# category, as extracted from the list of multichar symbols in the lexical fst.

if ! test $# -eq 3 -o $# -eq 4 ; then
    echo
    echo "Usage: $0 OUTFILE CATEGORY TAGFILE [ADAPTIONREGEXFILE]"
    echo
    echo "OUTFILE           = regex file to be created"
    echo "CATEGORY          = a string that describes what is being removed"
    echo "TAGFILE           = a file with the list of tags for CATEGORY"
    echo "ADAPTIONREGEXFILE = a regex fragment used to modify the final regex"
    echo "                    - strings with tags listed in this file within []"
    echo "                      will NOT be removed. Example:"
    echo "                      [ +Sem/Hum | +Sem/Plc ]"
    echo "                      Strings with these tags would not be removed"
    echo "                      from the fst if specified in ADAPTIONREGEXFILE."
    echo
    exit 1
fi

REGEXFILE=$1
CATEGORY=$2
TAGFILE=$3
ADAPTIONREGEXFILE=$4
SED=sed

ADAPTIONREGEX=""

if test "x$ADAPTIONREGEXFILE" != "x" ; then
    ADAPTIONREGEX=" - @re\"$ADAPTIONREGEXFILE\" "
fi

# Print header text:
echo "# This is a generated file - do not edit!"             > $REGEXFILE
echo "# The generated regex removes all $CATEGORY strings"  >> $REGEXFILE
echo "# except whatever is specified in the file given as"  >> $REGEXFILE
echo "# the last argument (optional). It will remove"       >> $REGEXFILE
echo "# all derivation strings with no third argument."     >> $REGEXFILE
echo ""                                                     >> $REGEXFILE

# Print the actual regular expression:
printf "~[ \$[ " >> $REGEXFILE # Exclude from target

$SED 's/$/"  |/' $TAGFILE \
| $SED 's/^/"/' \
| $SED "$ s/|/ ] /" >> $REGEXFILE

echo "$ADAPTIONREGEX ] ;" >> $REGEXFILE
