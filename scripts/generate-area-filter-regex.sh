#!/bin/bash

# Create a filter regex to remove all strings not belonging to the requested
# area, either because they are positively marked for other areas, or
# because they are negatively marked for the specified area.

if ! test $# -eq 3 ; then
    echo
    echo "Usage: $0 OUTFILE AREA_TAG ALL_AREA_TAGS"
    echo
    echo "OUTFILE       = regex file to be created"
    echo "AREA_TAG      = the tag for the target area"
    echo "ALL_AREA_TAGS = a list of tags for all areas"
    echo
    exit 1
fi

REGEXFILE=$1
TARGETAREA=$2
ALLAREAS=$3
SED=sed

NON_TARGET_AREAS=$(echo "$ALLAREAS" | tr ' ' '\n' | grep -v $TARGETAREA )

# echo "Nontargets: $NON_TARGET_AREAS"

# Print header text:
echo "# This is a generated file - do not edit!"        > $REGEXFILE
echo "# It removes area-marked strings belonging"      >> $REGEXFILE
echo "# to all areas but $TARGETAREA, so that the"     >> $REGEXFILE
echo "# filtered fst will generate wordforms suitable" >> $REGEXFILE
echo "# for the target area only."                     >> $REGEXFILE
echo ""                                                >> $REGEXFILE

# Print the actual regular expression:
echo "~\$[ %+Area%/%-$TARGETAREA |" >> $REGEXFILE # Exclude from target

echo "$NON_TARGET_AREAS"  \
| $SED 's/^/	\+Area\//' \
| $SED 's/\([+/_-]\)/%\1/g' \
| $SED 's/$/  |/'          \
| $SED '$ s/|/ ] ;/' >> $REGEXFILE
