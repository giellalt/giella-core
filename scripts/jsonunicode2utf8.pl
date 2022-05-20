#!/usr/bin/perl -w

# 7bit-utf8.pl
# The input is transformed from internal Latin 1 digraph Sami to utf8.
# It only takes the gang of six.
# $Id: 6x7bit-utf8.pl 25426 2009-04-21 09:48:21Z boerre $


while (<>) 
{


# The Sámi digraphs


s/\\u00c1/Á/g ;
s/\\u00c2/Â/g ;
s/\\u00c4/Ä/g ;
s/\\u00c5/Å/g ;
s/\\u00c6/Æ/g ;
s/\\u00d8/Ø/g ;
s/\\u00e1/á/g ;
s/\\u00e2/â/g ;
s/\\u00e4/ä/g ;
s/\\u00e5/å/g ;
s/\\u00e6/æ/g ;
s/\\u00f8/ø/g ;
s/\\u010c/Č/g ;
s/\\u010c/Č/g ;
s/\\u010d/č/g ;
s/\\u0110/Đ/g ;
s/\\u0111/đ/g ;
s/\\u014a/Ŋ/g ;
s/\\u014b/ŋ/g ;
s/\\u0161/Š/g ;
s/\\u0162/š/g ;
s/\\u0166/Ŧ/g ;
s/\\u0167/ŧ/g ;
s/\\u017d/Ž/g ;
s/\\u017e/ž/g ;

print ;
}
