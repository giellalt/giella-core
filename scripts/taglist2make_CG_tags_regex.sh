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

# But first, check that all tags conform, and if not print an error message and
# the list of non-conformant tags:
if $( egrep -v -q '(^\+[^\+]+$|^[^\+]+\+$|^\+[^\+]+\+$)' $1 ) ; then
  echo "ERROR:" 1>&2 ;
  echo "The following tags do not follow the Giella tag conventions" 1>&2 ;
  echo '(either +TAG, TAG+ or +TAG+) and can not be converted to the CG' 1>&2 ;
  echo "format required for proper tokeniser functionality within the" 1>&2 ;
  echo "Giella infrastructure:" 1>&2 ;
  echo  1>&2 ;
  egrep -v '(^\+[^\+]+$|^[^\+]+\+$|^\+[^\+]+\+$)' $1 1>&2 ;
  exit 1;
else
  $SED '/^[+][^+]*[+]$/s/^[+]\([^+]*\)[+]$/\" \1\ " <- \"+\1\+",/' $1 \
  | $SED '/^[+][^+]*$/s/^[+]\([^+]*\)$/\" \1\" <- \"+\1\",/' \
  | $SED '/^[^+]*[+]$/s/^\([^+]*\)[+]$/\"\1 \" <- \"\1+\",/' \
  | $SED '$ s/,/;/' \
  | $AWK 'NR==1{$0="### This is a file  generated with taglist2make_CG_tags_regex.sh - do not edit!!!\n\n"$0}1' ;
fi
