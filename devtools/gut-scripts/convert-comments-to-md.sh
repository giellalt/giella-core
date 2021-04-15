#!/bin/bash

path=$(pwd)

for f in $(find . -name '*.lexc' -o -name '*.twolc' -o -name '*.cg3') ; do
  gawk -f $path/../giella-core/scripts/doccomments-jspwiki2gfm-oneshot.awk \
     < $f > $f.gfm
     mv $f.gfm $f
done