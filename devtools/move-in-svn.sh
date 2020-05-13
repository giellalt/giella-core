#!/bin/bash

# This is a maintenance script to help propagate file moves or renames in the
# core template to all languages. It loops over all language dirs as defined in
# the *.am file and svn mv the files specified.

# Extract the list of all languages from the *.am file:
ALL_LANGS=$(egrep '^ALL_LANGS=' < Makefile.am | sed -e 's/ALL_LANGS=//')

oldfile=$1
newfile=$2

for ll in $ALL_LANGS ; do
    if test -d $ll ; then
        svn mv $ll/$oldfile $ll/$newfile
    fi
done

echo
echo "*** Done: all languages updated. ***"
echo
