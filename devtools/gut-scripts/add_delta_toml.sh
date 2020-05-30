#!/bin/bash

repodir=$(pwd)
langcode=$(basename $repodir | cut -d'-' -f2)
giella_core="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )/../.."

iso3code=$langcode
iso2code=$($giella_core/scripts/iso3-to-2.sh $langcode)
langname=$($giella_core/scripts/iso639-to-name.sh $langcode)

deltatemplate=$giella_core/devtools/delta.toml

echo $iso3code and $iso2code and $langname

mkdir -p $repodir/.gut
sed -e "/__UND__/s/\$/\"$iso3code\"/" \
    -e "/__UND2C__/s/\$/\"$iso2code\"/" \
    -e "/__UNDEFINED__/s/\$/\"$langname\"/" $deltatemplate \
    > $repodir/.gut/delta.toml
