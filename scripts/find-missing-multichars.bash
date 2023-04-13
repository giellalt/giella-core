#!/bin/bash
if ! test -e src/fst/root.lexc ; then
    echo cannot read src/fst/root.lexc
    echo
    echo "USAGE: $0"
    echo run this in a lang-XXX directory
    exit 1
fi

grep -Eoh '\+[^+: 	#]*' src/fst/stems/* src/fst/affixes/* | sort | uniq > other-flags
grep -Eo '\+[^+: 	#]*' src/fst/root.lexc | sort | uniq >root-flags
diff -u root-flags other-flags
