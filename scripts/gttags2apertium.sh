#!/bin/bash

# Shell script to extract the GT/Divvun tags, transform them to Apertium-style
# tags, and generate a regex that will replace GT/Divvun tags with Apertium
# tags. This regex can then be used to produce Apertium fst's from standard
# fst's.
#
# Usage: $0 GTLANG.lexc.fst OUTFILE
#
# GTLANG.lexc.fst is the input lexical transducer, which should contain all tags
# used; this guarantees that all tags are transformed to Apertium style.
# OUTFILE is the source file to be generated.

hfst-project -p upper $1 | hfst-minimise | hfst-summarise -v | grep -A1 'arc symbols actually seen' | grep -F '+' | tr ' ' '\n' | grep '\+[^,]' | tr -d ',' > $1.gttags

tr -d '+' < $1.gttags | tr '/[:upper:]' '_[:lower:]' | awk '{print "%<"$0"%>"}' > $1.apertiumtags

# Either this:
paste $1.gttags $1.apertiumtags | awk '{print $0","}' | sed 's/	/ -> /g' | sed '$ s/,/;/' | sed 's/^/%/' > $2

# or this:
paste $1.gttags $1.apertiumtags | tr -d '%' > $2.relabel

rm -r $1.gttags $1.apertiumtags
