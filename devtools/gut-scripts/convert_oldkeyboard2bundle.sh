#!/bin/bash

# test script for dadmin apply script

# Variables:
convertordir=/Users/smo036/gitlangtech/kbdgen/support/convertor
sti=$(pwd)
language=$( basename $sti | cut -d'-' -f2 )

if ! ( ls $sti | grep kbdgen ) ; then
#    echo STIG: $sti
#    echo MÅL:  $language
    cd $convertordir
    node index.js $sti/project.yaml $sti/$language.kbdgen
else
    echo "Already converted!"
fi

# $ node index.js /Users/smo036/dadmin/giellalt/keyboard-yrk/project.yaml /Users/smo036/dadmin/giellalt/keyboard-yrk/yrk.kbdgen 
