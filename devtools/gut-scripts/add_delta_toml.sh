#!/bin/bash

repodir=$(pwd)
iso3code=$(fgrep '[GLANG]' $repodir/configure.ac | cut -d'[' -f3 | cut -d']' -f1)
iso2code=$(fgrep '[GLANG2]' $repodir/configure.ac | cut -d'[' -f3 | cut -d']' -f1)
langname=$(fgrep '[GLANGUAGE]' $repodir/configure.ac | cut -d'[' -f3 | cut -d']' -f1 | tr -d '"')
deltatemplate=/Users/smo036/langtech/gut/giellalt/giella-core/devtools/delta.toml

echo $iso3code and $iso2code and $langname

mkdir -p $repodir/.gut
sed -e "/__UND__/s/\$/\"$iso3code\"/" \
    -e "/__UND2C__/s/\$/\"$iso2code\"/" \
    -e "/__UNDEFINED__/s/\$/\"$langname\"/" $deltatemplate \
    > $repodir/.gut/delta.toml
