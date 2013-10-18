#!/bin/bash

# Wrong usage - short instruction:
if ! test $# -eq 1 ; then
    echo "Usage: $0 LANGUAGE_DIR"
    exit 1
fi

if test ! -r $1/und.timestamp ; then
    echo "This script must have a top-level language directory as its only"
    echo "argument, e.g."
    echo
    echo "${GTHOME}/langs/fao/"
    echo
    echo and not:
    echo "$1"
    echo
    exit 1
fi

# The ignore command:
svnignore="svn -q propset svn:ignore"

# Define common ignore patterns:
mkfiles="Makefile
Makefile.in
*.txt
*.xml"

autofiles="autom4te.cache
build-aux
config.log
config.status
configure
aclocal.m4"

# Set svn:ignore props on all dirs:
for f in $(find $1/ \
			-not -iwholename '*.svn*' \
			-type d) ; do
	$svnignore "$mkfiles" $f
done

# Set the svn:ignore prop on the top level lang dir:
$svnignore "$autofiles
$mkfiles
build" $1

# Set the svn:ignore prop on the plx dir - it needs an extra ignore:
$svnignore "$mkfiles
userdict" $1/plx
