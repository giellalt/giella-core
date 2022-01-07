#!/bin/bash

# test script for gut apply script

# Variables:
LANGDIR=$(pwd)
reponame=$(echo $LANGDIR | rev | cut -d'/' -f1 | rev)

# Replace __UNDEFINED__ with the placeholder string you want to act upon:
placeholder=__UNDEFINED__
replacement=$(grep $placeholder $LANGDIR/.gut/delta.toml | cut -d'=' -f2 | cut -d'"' -f2)

echo ${reponame}: $placeholder ⇒ $replacement

for f in $(grep -rl "$placeholder" ./*); do
    sed -e "s|$placeholder|$replacement|g" $f > $f.tmp
    mv -f $f.tmp $f
    echo $f
done
