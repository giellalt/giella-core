#!/bin/bash

# Take a list of flag diacritics, and wrap them in parentheses to make them
# optional

SED=sed
AWK=awk

# Script explanation:
# 1. the first line contains tag symbols that need to be escaped - add as needed
# 2. the second line adds the xfst operation at the beginning of each line
# 3. the third line adds a comma at the end of each line
# 4. the fourth line replaces the last comma with a semicolon, to end the regex

$SED   's/\([+/-@.]\)/%\1/g' $1 \
| $SED 's/^/| /' \
| $SED '1 s/^|/(/' \
| $SED '$ s/$/ ) ;/' \
| $AWK 'NR==1{$0="### This is a generated file - do not edit!!!\n"$0}1'
