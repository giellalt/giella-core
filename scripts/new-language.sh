#!/bin/bash

# Debug:
#set -x

if test -z "${GTCORE}" ; then
    echo "Unable to determine GTCORE, re-run gtsetup.sh and re-try"
    exit 1
fi

# Wrong usage - short instruction:
if ! test $# -eq 1 -o $# -eq 2 ; then
    echo "Usage: $0 NEW_LANGUAGE_ISOCODE [TEMPLATECOLLECTION]"
    echo
    echo "e.g.:"
    echo "$0 sme"
    echo "$0 kal langs"
    echo
    exit 1
fi

curDir=$(pwd)
if test "x$2" == "x"; then
    # Where are we? Must be inside 'langs' or 'prooftesting' if not specified:
    # Extract template collection name from current dir:
    TEMPLATECOLL=$(basename $curDir | cut -d'-' -f2)
else
    TEMPLATECOLL=$2
fi

# Get the list of available template collections:
availableTemplateColls=$(for t in $GTCORE/*-templates; do n=$(basename $t); \
                        n2=${n%-templates}; echo "$n2"; done)

# Check if the current directory name matches one of the template collection
# names by counting the matches (it should be 1 if it matches, 0 if not);
# if the test fails (i.e. we are in the wrong directory), write a message and
# exit:
if test $(echo "$availableTemplateColls" \
          | grep -c "^$TEMPLATECOLL\$" ) -eq 0 ; then
    echo "You are not in a directory holding template-based language dirs,"
    echo "or the specified collection name is invalid."
    echo "The given or identified collection name is '$TEMPLATECOLL', but"
    echo "should be one of:"
    echo
    echo "$availableTemplateColls"
    echo
    echo "Move to a suitable directory, or specify the template collection"
    echo "name as the second option, and try again."
    exit 1
fi

if ! [ -f Makefile.am ]
then
    echo "No Makefile.am file in this directory. It seems this is not a proper"
    echo "Giellatekno/Divvun infrastructure directory holding template-based"
    echo "language directories."
    exit 1
fi

if ! [ -f configure.ac ]
then
    echo "No configure.ac file in this directory. It seems this is not a proper"
    echo "Giellatekno/Divvun infrastructure directory holding template-based"
    echo "language directories."
    exit 1
fi

if test $(grep -c "^ALL_LANGS=" Makefile.am ) -eq 0 ; then
    echo "Something is wrong with your infrstructure setup:"
    echo "Your Makefile.am file does not set the variable ALL_LANGS."
    exit 1
fi

echo "*** updating $$GTCORE before populating the new directory.***"
svn up $GTCORE

TEMPLATEDIR=$TEMPLATECOLL-templates

# Copy template files to new language dir:
rsync -avzC ${GTCORE}/${TEMPLATEDIR}/und/ $1/

# Replace placeholder language code with real language code:
${GTCORE}/scripts/replace-dummy-langcode.sh "$curDir/$1" $1

# Rename files with placeholder language code:
for f in $(find ./$1 -name "*__UND__*") ; do
    newf=$( echo $f | sed -e "s/__UND__/$1/g"  )
    mv -f $f $newf
done

# Update Makefile.am with the new language:
cp Makefile.am Makefile.am~
old_langs=$(grep "ALL_LANGS=" < Makefile.am | cut -d'=' -f2)
new_langs=$(echo "$old_langs $1" | tr ' ' '\n' | sort -u | tr '\n' ' ' )
sed -e "s/NEW_LANGS=\(.*\)$1\(.*\)/NEW_LANGS=\1\2/" \
    -e "s/ALL_LANGS=.*/ALL_LANGS=$new_langs/" \
    < Makefile.am~ > Makefile.am

# Update configure.ac with the new language:
cp configure.ac configure.ac~
sed -e "s/AC_CONFIG_SUBDIRS(\\[.*/AC_CONFIG_SUBDIRS([$new_langs])/" \
	< configure.ac~ > configure.ac

# Stamp new language dir with latest template merging time
touch $1/und.timestamp

# Add the new language to svn:
svn add --force $1

# Revert the addition of the source files to make the transition from old to
# new easier - we want to svn move the old files, so no new source files in
# svn (remove these commands when all languages have been moved from the old to
# the new infra - the svn revert commands do not make sense outside the langs
# template collection):
if [[ x$TEMPLATECOLL = "xlangs" ]]; then
    svn revert $1/src/morphology/affixes/*
    svn revert $1/src/morphology/stems/*
    svn revert $1/src/morphology/root.lexc
    svn revert $1/src/phonology/*phon.*
fi

# Now that the files are known to svn, add svn:ignore properties:
${GTCORE}/scripts/set-svn-ignores-$TEMPLATECOLL.sh $1

cat<<EOF
    The new language $1 has been added to the top-level Makefile.
    The old Makefile has been backed up as Makefile.am~
    All dirs and files in $1 have been added to svn. Either "svn ci $1" if
    all is ok, or "svn revert $1" if not.
    If all is ok, remember to also commit the changes to ./Makefile.am and
    ./configure.ac, to ensure that automatic processes are aware
    of the new language.
    To start working on the new language, fill in license and copyright
    info in the $1/LICENCE file, and then start filling the files in
    $1/src/ with linguistic content.
EOF
