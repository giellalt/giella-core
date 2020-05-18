#!/bin/bash

# test script for gut apply script

# Variables:
LANGDIR=$1

present_version=$(grep 'AC_INIT' $LANGDIR/configure.ac | tr '\n' ' ' \
        | cut -d',' -f2 | tr -d ' ' | cut -d'[' -f2 | cut -d']' -f1)

echo $present_version
