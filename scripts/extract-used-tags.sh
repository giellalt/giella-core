#!/bin/bash

# Extract all tags found in the lexc code.
#
# This script is included by scripts found in each language repo.
# It is not intended to be used on its own.

cut -d'!' -f1                     | # get rid of comments
grep ';'                          | # Get only lines with
grep -v -E '^[0-9A-Za-z_-]+\s+;'  | # get rid of entries with only contlex
sed 's/"[^"]*"//g'                | # get rid of quoted info strings
tr '\t' ' '                       | # translate all tabs to spaces
tr -s ' '                         | # squeeze all spaces
sed 's/ [0-9A-Za-z/#_-]* ;//'     | # get rid of all contlexes
cut -d':' -f1                     | # get rid of the surface side
sed -e 's/ /_/g'                  | # we don't care about mwe with spaces here
grep -E '[@+][0-9A-Za-z][0-9A-Za-z@+]' |  # Only keep interesting strings
sed 's/@@/@€@/g'                  | # insert newline placeholder between flag diacritics
sed 's/@+/@€+/g'                  | # insert newline placeholder between flag and tag
tr '€#"' '\n'                     | # insert newlines now, for cleaner data for the next steps
sed '/^[^@+]/ s/^[^@+]*//'        | # remove non-tag text at beginning of line
sed 's/^\(@[^@]*@\)/\1€/'         | # insert newline placeholer after initial flag diacritic
tr '€' '\n'                       | # insert newline for cleaner data for next step
grep -E '[@+].'                   | # Only keep intersting stuff
sed '/^\+/ s/\+/€+/g'             | # if begins with +, insert newlines before + (suffix tags)
sed '/\+$/ s/\+/\+€/g'            | # if ends with +, insert newlines after + (prefix tags)
tr '€' '\n'                       | # insert newlines
grep '[\+@].'                     | # keep only interesting stuff
grep -E -o '@[^@]*@|\+[^+@]*'       | # output only taggy flaggy parts
sed -e 's/[-%]*$//' -e 's/^[-%]*//' | # Get rid of final stuff that is odd
sed -e 's/%\([_/]\)/\1/g'  # some de-escaping
