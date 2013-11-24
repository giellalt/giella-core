#!/bin/bash

# Take a list of GT/Divvun tags of the form +Abc/XYZ, and turn it into a regex
# to remove those tags.

SED=sed

$SED   's/+/%+/g' $1 \
| $SED 's/\//%\//g' \
| $SED 's/^/0 <- /' \
| $SED 's/$/,/' \
| $SED '$ s/,/;/'
