#!/bin/bash

# Function to clean dirnames from irrelevant ../../ intermediate steps:
function myreadlink() {
  (
  cd $(dirname $1)         # or  cd ${1%/*}
  echo $PWD/$(basename $1) # or  echo $PWD/${1##*/}
  )
}

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

# Get the list of dirs to work on:
dirlist=$(find $1 \
			-not -iwholename '*.cache*' \
			-not -iwholename '*inc/*' \
			-not -iwholename '*/ext-*' \
			-not -iwholename '*incoming*' \
			-not -iwholename '*hfst/3*' \
			-not -iwholename '*hfst/MacVoikko*' \
			-not -iwholename '*grammarcheckers/4*' \
			-not -iwholename '*grammarcheckers/*-x-standard*' \
			-type d)

# Remove intermediate ../../:
shorteneddirlist=$(for d in $dirlist; do
    myreadlink $d;
done)

### Set svn:ignore props on all found dirs, but skip 'bygg' and 'build': ###
for f in $shorteneddirlist ; do
	if echo $f | egrep -v -q "(bygg|build)"; then
		$svnignore "$mkfiles
$fstfiles" $f
    fi
done

### Then reset the default ignore pattern with the following values for ###
### specific directories:                                               ###

# Set the svn:ignore prop on the top level lang dir, ignoring build, bygg,
# *.html and *.pc:
$svnignore "$autofiles
$mkfiles
Desktop.ini
build
bygg
*.html
*.pc" $1

# Set the svn:ignore prop on the devtools dir:
$svnignore "speller*.txt
check_analysis_regressions.sh
*suggestions.sh" $1/devtools

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

# Ignore all temporary and generated files in the src/filters/ dir:
$svnignore "$mkfiles
$fstfiles
*.txt
*.regex" $1/src/filters

# Ignore all temporary and generated files in the src/hyphenation/ dir:
$svnignore "$mkfiles
$fstfiles
hyphenation.xfscript" $1/src/hyphenation

# Ignore all temporary and generated files in the src/morphology/ dir:
$svnignore "$mkfiles
$fstfiles
url.lexc
*.tmp.*
lexicon.*" $1/src/morphology

# Ignore all files in the src/morphology/generated_files dir:
$svnignore "*" $1/src/morphology/generated_files

# Ignore all temporary and generated files in the src/syntax/ dir:
$svnignore "$mkfiles
$fstfiles
*.xeroxscript
*.hfstscript
downcase-derived_proper-strings.xfscript" $1/src/orthography

# Ignore all temporary and generated files in the src/tagsets/ dir:
$svnignore "$mkfiles
$fstfiles
*.relabel
*.txt" $1/src/tagsets

# Ignore all temporary and generated files in the src/syntax/ dir:
$svnignore "$mkfiles
$fstfiles
dependency.cg3
functions.cg3" $1/src/syntax

# Set the svn:ignore prop on the test/tools/grammarcheckers/ dir:
$svnignore "$mkfiles
$fstfiles
*.pmhfst
*.cg3
*.zhfst
*.zcheck
modes
errors.xml
pipespec.xml" $1/tools/grammarcheckers

# Set the svn:ignore prop on the test/tools/grammarcheckers/filters/ dir:
$svnignore "$mkfiles
$fstfiles
*.regex
*.txt" $1/tools/grammarcheckers/filters

# Set the svn:ignore prop on the tools/hyphenators/fstbased/ dir:
$svnignore "$mkfiles
$fstfiles
all_tags.txt" $1/tools/hyphenators/fstbased

# Set the svn:ignore prop on the tools/mt/apertium/ dir:
$svnignore "$mkfiles
$fstfiles
sigma.txt
*.cg3
*.att.gz" $1/tools/mt/apertium

# Set the svn:ignore prop on the tools/mt/apertium/filters/ dir:
$svnignore "$mkfiles
$fstfiles
*txt
*.regex" $1/tools/mt/apertium/filters

# Set the svn:ignore prop on the tools/mt/apertium/tagsets/ dir:
$svnignore "$mkfiles
$fstfiles
apertiumtags.txt
apertium.relabel
gttags.txt" $1/tools/mt/apertium/tagsets

# Set the svn:ignore prop on the tools/spellcheckers/fstbased/ dir:
$svnignore "$mkfiles
$fstfiles
*.att
*.txt" $1/tools/spellcheckers/fstbased/

# Set the svn:ignore prop on the tools/spellcheckers/fstbased/desktop/ dir:
$svnignore "$mkfiles
$fstfiles
*.txt" $1/tools/spellcheckers/fstbased/desktop/

# Set the svn:ignore prop on the tools/spellcheckers/fstbased/mobile/ dir:
$svnignore "$mkfiles
$fstfiles
*.txt" $1/tools/spellcheckers/fstbased/mobile/

# Set the svn:ignore prop on the hfst speller dir:
$svnignore "$mkfiles
$fstfiles
easteregg.*
*.service
*.zhfst
*.oxt
*.xpi
*.zip
test.*
build
editdist.default.regex
3" $1/tools/spellcheckers/fstbased/desktop/hfst

# Set svn:ignore on the tools/spellcheckers/fstbased/desktop/weighting/ dir:
$svnignore "$mkfiles
$fstfiles
spellercorpus.clean.txt" $1/tools/spellcheckers/fstbased/desktop/weighting

# Set the svn:ignore prop on the mobile hfst speller dir:
$svnignore "$mkfiles
$fstfiles
easteregg.*
*.zhfst
test.*
build
editdist.default.regex
3" $1/tools/spellcheckers/fstbased/mobile/hfst

# Set svn:ignore on the tools/spellcheckers/fstbased/mobile/weighting/ dir:
$svnignore "$mkfiles
$fstfiles
spellercorpus.clean.txt" $1/tools/spellcheckers/fstbased/mobile/weighting

# Set the svn:ignore prop on the shellscripts dir:
$svnignore "$mkfiles
*.sh
*.txt" $1/tools/shellscripts

# Set the svn:ignore prop on the test/tools/tokenisers/ dir:
$svnignore "$mkfiles
*.hfst
*.pmhfst
*.tmp
abbr.txt" $1/tools/tokenisers

# Set the svn:ignore prop on the test/tools/tokenisers/filters/ dir:
$svnignore "$mkfiles
$fstfiles
*.regex
*.txt" $1/tools/tokenisers/filters

# Set the svn:ignore prop on the test/ dir:
$svnignore "$mkfiles
run-yaml-testcases.sh
run-morph-tester.sh" $1/test

# Set the svn:ignore prop on the test/src/ dir:
$svnignore "$mkfiles
*-affixes_*.yaml
*-stems_*.yaml
*-morphology_*.yaml
*.log
*.trs
*.txt
*.sh" $1/test/src

# Set the svn:ignore prop on the test/src/morphology/ dir:
$svnignore "$mkfiles
filtered-*
*.log
*.trs
*.txt
*.sh" $1/test/src/morphology

# Set the svn:ignore prop on the test/tools/spellcheckers/ dir:
$svnignore "$mkfiles
*.log
*.trs
*.txt
*.sh" $1/test/src/phonology

# Set the svn:ignore prop on the test/tools/mt/apertium/ dir:
$svnignore "$mkfiles
*.log
*.trs
*.txt
*.sh" $1/test/tools/mt/apertium

# Set the svn:ignore prop on the test/tools/spellcheckers/ dir:
$svnignore "$mkfiles
*.log
*.trs
*.txt
*.sh" $1/test/tools/spellcheckers

# Set the svn:ignore prop on the test/tools/spellcheckers/fstbased/desktop/hfst dir:
$svnignore "$mkfiles
*.log
*.trs
*.txt
*.sh" $1/test/tools/spellcheckers/fstbased/desktop/hfst

# Remove the svn:ignore prop on some subdirs:
svn -q propdel svn:ignore $1/src/morphology/affixes
svn -q propdel svn:ignore $1/am-shared
svn -q propdel svn:ignore $1/m4
svn -q propdel svn:ignore $1/doc/resources
svn -q propdel svn:ignore $1/doc/resources/images
