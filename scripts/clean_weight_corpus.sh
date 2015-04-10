#!/bin/bash

# A simple shell script to clean raw text to something processable by the
# weighting processsing.

cat $1 \
| sed -e 's/\( [].:;,(){}!?[]\)\([[:alpha:]]\)/\1 \2/g'            \
      -e 's/\([[:alpha:]]\)\([],:;(){}[] \)/\1 \2/g'               \
      -e 's/\([[:alpha:]]\)\([.!?]\ \+\)\([[:upper:]]\)/\1 \2\3/g' \
      -e  's/[]\.:;,(){}!?[]$$/ \0/g' \
      -e 's/^[]\.:;,(){}!?[]/\0 /g'   \
| tr -s ' ' '\n' \
| sed -e 's/:/\\:/g' \
| egrep -v '^[[:punct:][:digit:]]*$$' \
> $2
