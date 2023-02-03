#!/bin/bash

if ! test $# -eq 2 ; then
    echo
    echo "Usage: $0 OUTFILE FSAFILE"
    echo
    echo "OUTFILE is the regex file to be created"
    echo "FSAFILE is the file with alphabet containing NFD coded unicode arcs"
    echo
    exit 1
fi

REGEXFILE="$1"
FSAFILE="$2"

# Print header text:
echo "# This is a generated file - do not edit!"        > "$REGEXFILE"
echo "# It recodes NFD coded symbols to NFC"           >> "$REGEXFILE"
echo ""                                                >> "$REGEXFILE"

hfst-summarize "$FSAFILE" -v |\
    grep -F -A 1 "sigma set:" |\
    tail -n 1 |\
    tr , '\n' |\
    sed -e 's/^ //' > "$REGEXFILE".sigma
 uconv -x any-nfc "$REGEXFILE".sigma > "$REGEXFILE".sigma.nfc
 paste "$REGEXFILE".sigma "$REGEXFILE".sigma.nfc |\
     awk '$1 != $2 {printf("%s (->) %s,\n", $1, $2);}' >> "$REGEXFILE"
echo "X (->) X ;" >> "$REGEXFILE"
