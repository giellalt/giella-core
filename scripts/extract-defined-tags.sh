#!/bin/bash

# Extract all tags declared in the root.lex file
#
# This script is included by scripts found in each language repo.
# It is not intended to be used on its own.

cut -d'!' -f1                     | # Remove comments
sed 's/Multichar_Symbols//'       | # Remove the string Multichar_Symbols
tr ' \t' '\n'                     | # Change all spaces and tabs to newlines
grep -E '(^\+|^@|\+$)'
# Extract tags and flag diacritics
