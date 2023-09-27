#!/bin/bash

# `gut apply script` to extract lemma statistics for matching repos
#
# Usage:
#
# gut apply -s giella-core/devtools/gut-scripts/get_lemma_count.sh \
# -r '^lang-(mhr|myv|fao |fin|kal|izh|sjd|kpv|fkv|olo|mdf|sje|sm.|udm|vro|mrj)$'

# Use common lemma extraction script for most robust and reliable count:
lemmacount=$(for f in src/fst/stems/*.lexc ; do 
    echo $(../giella-core/scripts/extract-lemmas.sh -H $f | # extract all lemmas for each stem file, keeping homonyms
    wc -l); done  | # ... and count them
    tr '\n' '+'   | # replace newline with +
    sed 's/\+$//' | # ... remove the final +, and summarise everything in the final command
    bc)

echo $lemmacount
