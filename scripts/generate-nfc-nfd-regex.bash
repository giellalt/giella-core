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
echo "# This is a generated file - do not edit!"          > "$REGEXFILE"
echo "# It recodes NFC coded symbols to NFD optionally"   >> "$REGEXFILE"
echo "# (for NFD support for tools that don't handle it)" >> "$REGEXFILE"
echo >> "$REGEXFILE"

hfst-summarize "$FSAFILE" -v |\
    grep -F -A 1 "sigma set:" |\
    tail -n 1 |\
    tr , '\n' |\
    sed -e 's/^ //' |\
    grep -E -v '^[+{@}^]' > "$REGEXFILE".sigma.nfc
uconv -x any-nfd "$REGEXFILE".sigma.nfc > "$REGEXFILE".sigma.nfd
paste "$REGEXFILE".sigma.nfc "$REGEXFILE".sigma.nfd |\
    gawk '$1 != $2 {printf("%s (->) %s,\n", $1, $2);
    printf("%s (->) ", $1);
    for (i = 1; i <= length($2); i++) {
        printf("%s ", substr($2, i, 1));
    }
    printf(",\n");
 }' >> "$REGEXFILE"
echo "X (->) X ;" >> "$REGEXFILE"
