#!/bin/bash

# From a list of GT/Divvun tags of the form +Abc/XYZ, extract all semantic tags
# of the form +Sem/abc; if no such tags are found, print a dummy tag instead, to
# make the generated regex valid.
#
# Usage:
# $0 input-tag-file output-semtag-file

if ! grep -F '+Sem/' $1; then
    echo "+Sem/DummySemTag" > $2
else
    grep -F '+Sem/' $1 > $2
fi
