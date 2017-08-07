#!/bin/bash

# Take a list of GT/Divvun semantic tags of the form +Abc/XYZ, and turn it into
# a regex to reorder those tags wrt a short list of POS tags.

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
TMPFILE=$1.tmp
TAGFILE=$2

SED=sed

# The list of POS's to move semantic tags for (use underscore for
# multitag POS's, use =XX= for tag-internal slashes as in +Use/NG):

POSes="%+N %+A %+N_%+Prop \
%+v1_%+A %+v2_%+A %+v3_%+A %+v4_%+A \
%+v1_%+N %+v2_%+N %+v3_%+N %+v4_%+N \
%+v5_%+N %+v6_%+N %+v7_%+N %+v8_%+N \
%+v1_%+Use=XX=NG_%+N %+v2_%+Use=XX=NG_%+N %+v3_%+Use=XX=NG_%+N \
%+v4_%+Use=XX=NG_%+N %+v5_%+Use=XX=NG_%+N %+v6_%+Use=XX=NG_%+N \
%+v7_%+Use=XX=NG_%+N %+v8_%+Use=XX=NG_%+N"

# Print header text:
echo "# This is a generated file - do not edit!"    > $TMPFILE
echo "# The script file that generates it is " >> $TMPFILE
echo "# $GTHOME/giella-core/scripts/taglist2reorder_semantic_tags_regex.sh" >> $TMPFILE
echo "# The generated regex reorders all semantic" >> $TMPFILE
echo "# tags with respect to some POS tags."       >> $TMPFILE

# Loop over the list of POS's requiring semantic tag reordering:
for POS in $POSes; do
    # replace _ with space in POS
    REALPOS=$(echo $POS | tr '_' ' ')
    echo "" >> $TMPFILE
    echo "# $REALPOS" >> $TMPFILE

    # escape characters special to Xerox regex, then create the regex:
    $SED   's/\([+/_-]\)/%\1/g' $TAGFILE \
    | $SED "s/^\(.*\)/$REALPOS \1 <- \1 $REALPOS ,/" \
    >> $TMPFILE
done

    # finally replace =XX= with %/, and replace the last comma with a semicolon
    # to end the regex:
cat $TMPFILE \
    | $SED 's/=XX=/%\//g' \
    | $SED '$ s/,/;/' \
    > $REGEXFILE

rm -f $TMPFILE
