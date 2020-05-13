#!/bin/bash

# Take a list of GT/Divvun tags of the form +Abc/XYZ, and turn it into a regex
# to remove those tags in front of derivations.

SED=sed
AWK=awk

# Script explanation:
# 1. the first line adds the xfst operation at the beginning of each line + "
# 2. the second line adds a " & comma at the end of each line
# 3. the third line replaces the last comma with a context condition + semicolon
# 4. finally, a warning comment is printed at the top of the file

$SED 's/^/0 <- "/' $1 \
| $SED 's/$/",/' \
| $SED '$ s/,/ || _ ( ? ) [ "+Der" | "+Der2" | "+Der3" | "+Der4" | "+Der5" ] ;/' \
| $AWK 'NR==1{$0="### This is a file generated with $GIELLA_CORE/scripts/taglist2remove_semantic_tags_before_derivations_regex.sh - DO NOT EDIT!!!\n\n"$0}1'
