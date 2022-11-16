#!/bin/bash

# Script for gut apply --script that converts keyboard layouts from kbdgen2 to
# kbdgen3 format.

# Variables:
convertordir=../../divvun/kbdgen/resources/scripts

for layout in *.kbdgen/layouts/*.yaml; do
    echo $layout
    deno run --allow-read $convertordir/kbdgen2to3.js $layout > $layout.tmp
    mv -f $layout.tmp $layout
done
