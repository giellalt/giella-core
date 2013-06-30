#!/bin/bash
if test -z "${GTCORE}" ; then
    echo "Unable to determine GTCORE, re-run gtsetup.sh and re-try"
    exit 1
fi

# Wrong usage - short instruction:
if ! test $# -eq 2 ; then
    echo "Usage: $0 NEW_LANGUAGE_ISOCODE TEMPLATE_COLLECTION"
    echo
    echo "e.g. $0 sme langs"
    echo
    exit 1
fi

TEMPLATEDIR=$2-templates

# Copy template files to new language dir:
rsync -avzC ${GTCORE}/${TEMPLATEDIR}/und/ $1/

# Replace placeholder language code with real language code:
curDir=`pwd`
${GTCORE}/scripts/replace-dummy-langcode.sh "$curDir/$1" $1

# Update Makefile.am with the new language:
cp Makefile.am Makefile.am~
sed -e "s/NEW_LANGS=\(.*\)$1/NEW_LANGS=\1/" \
    -e "s/ALL_LANGS=/ALL_LANGS=$1 /" \
    < Makefile.am~ > Makefile.am

# Update configure.ac with the new language:
cp configure.ac configure.ac~
sed -e "s/AC_CONFIG_SUBDIRS(\\[/AC_CONFIG_SUBDIRS([$1 /" \
	< configure.ac~ > configure.ac

# Stamp new language dir with latest template merging time
touch $1/und.timestamp

# Add the new language to svn:
svn add --force $1
# Revert the addition of the source files to make the transition from old to
# new easier - we want to svn move the old files, so no new source files in
# svn:
svn revert $1/src/morphology/*/*
svn revert $1/src/morphology/root.lexc
svn revert $1/src/syntax/disambiguation.cg3
svn revert $1/src/phonology/*phon.*
svn revert $1/src/transcriptions/*.lexc

# Now that the files are knwon to svn, add svn:ignore properties:
${GTCORE}/scripts/set-svn-ignores-$2.sh $1

cat<<EOF
    The new language $1 has been added to the top-level Makefile.
    The old Makefile has been backed up as Makefile.am~
    All dirs and files in $1 have been added to svn. Either \"svn ci $1\" if
    all is ok, or \"svn revert $1\" if not.
    If all is ok, remember to also commit the changes to ./Makefile.am and
    ./configure.ac, to ensure that automatic processes are aware
    of the new language.
    To start working on the new language, fill in license and copyright
    info in the $1/LICENCE file, and then start filling the files in
    $1/src/ with linguistic content.
EOF
