#!/bin/bash
# cheap tokeniser if we can't run full tokeniser on every CI commit
# or all the other cases when you need all the tokens in a minute instead of an
# hour.
cat $@ |\
    sed -e 's/[.,:!?;)"*]\+ / &/g'\
        -e 's/[.,:!?:)"*]\+$/ &/' \
        -e 's/ [(*"[]/& /g' \
        -e 's/^[(*"[]/& /' |\
    tr -s ' ' '\n' |\
    sed -e 's/^\([[:punct:]]\)\([[:punct:]]\)$/\1\n\2/'
