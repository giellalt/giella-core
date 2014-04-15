#!/bin/bash

# Create a filter regex to remove all strings not belonging to the requested
# dialect, either because they are positively marked for other dialects, or
# because they are negatively marked for the dialect.

if ! test $# -eq 2 -o $# -eq 3 ; then
    echo
    echo "Usage: $0 OUTFILE TAGFILE [ADAPTIONREGEXFILE]"
    echo
    echo "OUTFILE           = regex file to be created"
    echo "TAGFILE           = a file with the list of derivation tags"
    echo "ADAPTIONREGEXFILE = a regex fragment used to modify the final regex"
    echo
    exit 1
fi

REGEXFILE=$1
TAGFILE=$2
ADAPTIONREGEXFILE=$3
SED=sed

ADAPTIONREGEX=""

if test "x$ADAPTIONREGEXFILE" != "x" ; then
    ADAPTIONREGEX=" - @re\"$ADAPTIONREGEXFILE\" "
fi

# Print header text:
echo "# This is a generated file - do not edit!"             > $REGEXFILE
echo "# The generated regex removes all derivation strings" >> $REGEXFILE
echo "# except whatever is specified in the file given as"  >> $REGEXFILE
echo "# the third argument (optional). It will remove"      >> $REGEXFILE
echo "# all derivation strings with no third argument."     >> $REGEXFILE
echo ""                                                     >> $REGEXFILE

# Print the actual regular expression:
printf "~[ \$[ " >> $REGEXFILE # Exclude from target

$SED   's/\([+/-]\)/%\1/g' $TAGFILE \
| $SED 's/$/  |/'          \
| $SED "$ s/|/ ] /" >> $REGEXFILE

echo "$ADAPTIONREGEX ] ;" >> $REGEXFILE
