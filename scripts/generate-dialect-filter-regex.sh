#!/bin/bash

# Create a filter regex to remove all strings not belonging to the requested
# dialect, either because they are positively marked for other dialects, or
# because they are negatively marked for the dialect.

if ! test $# -eq 3 ; then
    echo
    echo "Usage: $0 OUTFILE DIALECTTAG ALLDIALECTTAGS"
    echo
    echo "OUTFILE        = regex file to be created"
    echo "DIALECTTAG     = the tag for the target dialect"
    echo "ALLDIALECTTAGS = a list of tags for all dialeccts"
    echo
    exit 1
fi

REGEXFILE=$1
TARGETDIAL=$2
ALLDIALECTS=$3
SED=sed

NONTARGETDIALECTS=$(echo "$ALLDIALECTS" | tr ' ' '\n' | grep -v $TARGETDIAL )

# echo "Nontargets: $NONTARGETDIALECTS"

# Print header text:
echo "# This is a generated file - do not edit!"        > $REGEXFILE
echo "# It removes dialect-marked strings belonging"   >> $REGEXFILE
echo "# to all dialects but $TARGETDIAL, so that the"  >> $REGEXFILE
echo "# filtered fst will generate wordforms suitable" >> $REGEXFILE
echo "# for the target dialect only."                  >> $REGEXFILE
echo ""                                                >> $REGEXFILE

# Print the actual regular expression:
echo "~\$[ %+Dial%/%-$TARGETDIAL |" >> $REGEXFILE # Exclude from target

echo "$NONTARGETDIALECTS"  \
| $SED 's/^/	\+Dial\//' \
| $SED 's/\([+/_-]\)/%\1/g' \
| $SED 's/$/  |/'          \
| $SED '$ s/|/ ] ;/' >> $REGEXFILE
