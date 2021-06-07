#!/bin/bash

# test script for gut apply script

# Variables:
LANGDIR=$(pwd)

reponame=$(basename $LANGDIR)

echo "__REPO__ = \"$reponame\""

echo "__REPO__ = \"$reponame\"" >> $LANGDIR/.gut/delta.toml
