#!/bin/bash

# `gut apply script` to extract lemma statistics for matching repos
#
# Usage:
#
# gut apply -s giella-core/devtools/gut-scripts/get_lemma_count.sh \
# -r '^lang-(mhr|myv|fao |fin|kal|izh|sjd|kpv|fkv|olo|mdf|sje|sm.|udm|vro|mrj)$'

lemmacount=$(grep ';' src/fst/stems/*.lexc | # get all entries in the stems dir
             cut -d':' -f2-            | # get rid of the filename part of the grep matches
             egrep -v '^\s*(:|\+|!|@)' | # remove lines starting :+!@
             egrep -v '^\s*[^:]+\s+;'  | # remove lines with only contlex
             cut -d':' -f1             | # remove surface side
             cut -d'+' -f1             | # remove tags
             sort -u                   | # sort and unique - we only count unique lemmas 
             wc -l)

echo $lemmacount
