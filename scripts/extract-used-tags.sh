#!/bin/bash

# Extract all tags found in the lexc code.
#
# This script is included by scripts found in each language repo.
# It is not intended to be used on its own.

cut -d'!' -f1                     | # get rid of comments
grep ';'                          | # Get only lines with 
cut -d';' -f1                     | # get everything in front of ;
tr ' \t' '\n'                     | # turn all spaces and tabs into newlines
grep -E '[\+|@]'                  | # grep relevant stuff only
cut -d':' -f1                     | # get rid of surface side
sed 's/+/¢+/g'                    | # prepare for tag isolation
sed 's/@@/@¢@/g'                  | # prepare for flag diacritic splitting
tr '¢"#' '\n'                     | # replace some symbols with newlines = split tags
grep -E '^(\+|@)[A-Za-z]'         | # grep only relevant lines / symbols
perl -pe "s#^(\+[^@]+)@#\1\n@#g"  | # do a final split of +Tag@C.FLAG@
perl -pe "s#^(@[^@]+@)#\1\n#g"    | # do a final cleanup of @C.FLAG@abc
grep -E '^(\+|@)[A-Za-z]'         | # grep only relevant lines / symbols
sed 's/\-$//'
# Get rid of final hyphens, they are bogus
