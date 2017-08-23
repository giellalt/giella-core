#!/bin/bash

# Take a list of GT/Divvun tags of the form "+Abc/XYZ", and turn it into a regex
# to make those tags into CG format, where each + is replaced with a space:
# " Abc/XYZ". When applied to an fst, the result is that the fst will output
# CG compatible cohorts (in tersm of 

SED=sed
AWK=awk

# Script explanation:
# 1. the first line converts suffix tags
# 2. the second line converts prefix tags
# 3. the third line replaces the last comma with a semicolon, to end the regex
# 4. finally, a warning comment is printed at the top of the file

$SED   's/^\+\(.*\)$/" \1" <- "+\1",/' $1 \
| $SED 's/^\(.*\)\+$/"\1 " <- "\1+",/' \
| $SED '$ s/,/;/' \
| $AWK 'NR==1{$0="### This is a file  generated with taglist2make_CG_tags_regex.sh - do not edit!!!\n\n"$0}1'
