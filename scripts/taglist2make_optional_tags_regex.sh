#!/bin/bash

# Take a list of GT/Divvun tags of the form +Abc/XYZ, and turn it into a regex
# to make those tags optional.

SED=sed
AWK=awk

# Script explanation:
# 1. the first line adds the xfst operation at the beginning of each line + "
# 2. the second line adds a " & comma at the end of each line
# 3. the third line replaces the last comma with a semicolon, to end the regex
# 4. finally, a warning comment is printed at the top of the file

$SED 's/^/0 (<-) "/' $1 \
| $SED 's/$/",/' \
| $SED '$ s/,/;/' \
| $AWK 'NR==1{$0="### This is a file  generated with taglist2make_optional_tags_regex.sh - do not edit!!!\n\n"$0}1'
