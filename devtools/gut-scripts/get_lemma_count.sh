#!/bin/bash

# `gut apply script` to extract lemma statistics for matching repos
#
# Usage:
#
# gut apply -s giella-core/devtools/gut-scripts/get_lemma_count.sh \
# -r '^lang-(mhr|myv|fao|fin|kal|izh|sjd|kpv|fkv|olo|mdf|sje|sm.|udm|vro|mrj)$'

dir=$(pwd)

# Use common lemma extraction script for most robust and reliable count:
lemmacount=$(../giella-core/scripts/count-all-lemmas.sh $dir )

echo $lemmacount
