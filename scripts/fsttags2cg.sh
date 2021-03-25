#!/bin/bash

### Generated tags for cg3 file ###

echo ""
echo "Picking tags from root.lexc"
echo "processing..."

i="LIST-TAGS += "

cat src/fst/root.lexc |\
cut -d '!' -f1 |\
cut -d ':' -f1 |\
sed 's/+/¢+/g' |\
sed 's/@/¢@/g' |\
tr '¢' '\n'    |\
egrep '(\+|@)' |\
tr -d ' '  |\
tr -d '\t' |\
sort -u |\
grep -v "@" |\
cut -c2- |\
tr '\n' ' ' > xxrest

j=`cat xxrest`
k=" ;"

echo "$i$j$k" > src/cg3/fsttags.cg3

rm -f xxrest

echo "All tags put in src/cg3/fsttags.cg3, to be read by INCLUDE command in the cg3 files"
echo ""
