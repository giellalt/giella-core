#!/bin/bash

# Take a list of GT/Divvun tags of the form "+Abc/XYZ", and turn it into a regex
# to make those tags into CG format, where each + is replaced with a space:
# " Abc/XYZ". When applied to an fst, the result is that the fst will output
# CG compatible cohorts (in tersm of 

SED=sed
AWK=awk

# SED/AWK script explanation:
# 1. the first line converts tags with plusses in both ends
# 1. the second line converts suffix tags
# 2. the third line converts prefix tags
# 3. the fourth line replaces the last comma with a semicolon, to end the regex
# 4. finally, a warning comment is printed at the top of the file

$SED -e 's/^/| \"/' -e 's/$/\"/' $1 \
| $SED '1s/^|/[/' \
| $SED '$ s/$/ ];/' \
| $AWK 'NR==1{$0="### This is a file  generated with flaglist2make_flag_regex.sh - do not edit!!!\n\n"$0}1' ;
