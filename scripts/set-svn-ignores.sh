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

mkfiles="Makefile
Makefile.in"

autofiles="autom4te.cache
build-aux
config.log
config.status
configure
aclocal.m4"

fstfiles="*fst
*.hfstol
*.foma
*.bin
*.bcg3"

# Set svn:ignore props on all dirs:
for f in $(find $1/ \
			-not -iwholename '*.svn*' \
			-type d) ; do
	svn propset svn:ignore "$mkfiles
$fstfiles" $f
done

# Set the svn:ignore prop on the top level lang dir:
svn propset svn:ignore "$autofiles
$mkfiles
build" $1

# Set the svn:ignore prop on the doc dir:
svn propset svn:ignore "$mkfiles
build" $1/doc

# Set the svn:ignore prop on the misc dir:
svn propset svn:ignore "*" $1/misc

# Set the svn:ignore prop on the source dir:
svn propset svn:ignore "$mkfiles
$fstfiles
*.tmp" $1/src

# Ignore all temporary and generated files in the morph dir:
svn propset svn:ignore "$mkfiles
$fstfiles
*.foma
*.script
*.tmp.*" $1/src/morphology

# Ignore all temporary and generated files in the tagsets dir:
svn propset svn:ignore "$mkfiles
$fstfiles
*.relabel
*.txt" $1/src/tagsets

# Only ignore generated propernoun files in stems dir:
svn propset svn:ignore "*-*-propernouns.lexc" $1/src/morphology/stems

# Set the svn:ignore prop on the test/src/morphology/ dir:
svn propset svn:ignore "$mkfiles
*-affixes_*.yaml
*-stems_*.yaml
*-morphology_*.yaml
*.log
*.trs
*.txt
*.sh" $1/test/src/morphology

# Set the svn:ignore prop on the hfst speller dir:
svn propset svn:ignore "$mkfiles
$fstfiles
*.zhfst
3" $1/tools/spellcheckers/fstbased/hfst

# Remove the svn:ignore prop on some subdirs:
svn propdel svn:ignore $1/src/morphology/affixes
svn propdel svn:ignore $1/am-shared
svn propdel svn:ignore $1/m4
svn propdel svn:ignore $1/doc/resources
svn propdel svn:ignore $1/doc/resources/images
