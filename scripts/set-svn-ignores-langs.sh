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
			-not -iwholename '*build*' \
			-not -iwholename '*.cache*' \
			-not -iwholename '*hfst/3*' \
			-not -iwholename '*grammarcheckers/4*' \
			-not -iwholename '*grammarcheckers/*-x-standard*' \
			-type d) ; do
	$svnignore "$mkfiles
$fstfiles" $f
done

# Set the svn:ignore prop on the top level lang dir:
$svnignore "$autofiles
$mkfiles
build" $1

# Set the svn:ignore prop on the doc dir:
$svnignore "$mkfiles
build" $1/doc

# Set the svn:ignore prop on the misc dir:
$svnignore "*" $1/misc

# Set the svn:ignore prop on the source dir:
$svnignore "$mkfiles
$fstfiles
*.att
*.gz
*.tmp" $1/src

# Ignore all temporary and generated files in the morph dir:
$svnignore "$mkfiles
$fstfiles
*.foma
*.script
*-all.lexc
*.tmp.*" $1/src/morphology

# Ignore all temporary and generated files in the tagsets dir:
$svnignore "$mkfiles
$fstfiles
*.relabel
*.txt" $1/src/tagsets

# Only ignore generated propernoun files in stems dir:
$svnignore "*-*-propernouns.lexc" $1/src/morphology/stems

# Set the svn:ignore prop on the test/src/morphology/ dir:
$svnignore "$mkfiles
*-affixes_*.yaml
*-stems_*.yaml
*-morphology_*.yaml
*.log
*.trs
*.txt
*.sh" $1/test/src/morphology

# Set the svn:ignore prop on the hfst speller dir:
$svnignore "$mkfiles
$fstfiles
*.zhfst
3" $1/tools/spellcheckers/fstbased/hfst

# Set the svn:ignore prop on the grammarchecker dir:
$svnignore "$mkfiles
$fstfiles
*-x-standard
4" $1/tools/grammarcheckers

# Set the svn:ignore prop on the shellscripts dir:
$svnignore "$mkfiles
*.sh
*.txt" $1/tools/shellscripts

# Remove the svn:ignore prop on some subdirs:
svn propdel svn:ignore $1/src/morphology/affixes
svn propdel svn:ignore $1/am-shared
svn propdel svn:ignore $1/m4
svn propdel svn:ignore $1/doc/resources
svn propdel svn:ignore $1/doc/resources/images
