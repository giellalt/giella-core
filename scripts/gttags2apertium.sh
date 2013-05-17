#!/bin/bash

hfst-project -p upper $1 | hfst-minimise | hfst-summarise -v | grep -A1 'arc symbols actually seen' | grep -F '+' | tr ' ' '\n' | grep '\+[^,]' | tr -d ',' > $1.gttags

tr -d '+' < $1.gttags | tr '[:upper:]' '[:lower:]' | awk '{print "<"$0">"}' > $1.apertiumtags

paste $1.gttags $1.apertiumtags | awk '{print $0","}' | sed 's/	/ -> /g' | sed '$ s/,/;/' > gt2apertium.regex
