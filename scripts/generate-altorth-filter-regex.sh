#!/bin/bash

# Create a filter regex to remove all strings not belonging to the requested
# orthography, either because they are positively marked for other orthographies,
# or because they are negatively marked for the specified orthography.

if ! test $# -eq 3 ; then
    echo
    echo "Usage: $0 OUTFILE ORTH_TAG ALL_ORTH_TAGS"
    echo
    echo "OUTFILE       = regex file to be created"
    echo "ORTH_TAG      = the tag for the target orthography"
    echo "ALL_ORTH_TAGS = a list of tags for all orthographies"
    echo
    exit 1
fi

REGEXFILE=$1
TARGETORTH=$2
ALLORTHS=$3
SED=sed

NON_TARGET_ORTHS=$(echo "$ALLORTHS" | tr ' ' '\n' | grep -v $TARGETORTH )

# echo "Nontargets: $NON_TARGET_ORTHS"

# Print header text:
echo "# This is a generated file - do not edit!"        > $REGEXFILE
echo "# It removes altorth-marked strings belonging"   >> $REGEXFILE
echo "# to all orths but $TARGETORTH, so that the"     >> $REGEXFILE
echo "# filtered fst will generate wordforms suitable" >> $REGEXFILE
echo "# for the target orthography only."              >> $REGEXFILE
echo ""                                                >> $REGEXFILE

# Print the actual regular expression:
echo "~\$[ %+AltOrth%/%-$TARGETORTH |" >> $REGEXFILE # Exclude from target

echo "$NON_TARGET_ORTHS"  \
| $SED 's/^/	\+AltOrth\//' \
| $SED 's/\([+/_-]\)/%\1/g' \
| $SED 's/$/  |/'          \
| $SED '$ s/|/ ] ;/' >> $REGEXFILE
