#!/bin/bash

# Debug:
#set -x

if test -z "${GTCORE}" ; then
    echo "Unable to determine GTCORE, re-run gtsetup.sh and re-try"
    exit 1
fi

if test -z "${GTHOME}" ; then
    echo "Unable to determine GTHOME, re-run gtsetup.sh and re-try"
    exit 1
fi

# Wrong usage - short instruction:
if ! test $# -eq 1 -o $# -eq 2 ; then
    echo "Usage: $0 NEW_LANGUAGE_ISOCODE [TEMPLATECOLLECTION]"
    echo
    echo "Examples:"
    echo "$0 sme # Implicit template collection, derived from the name"
    echo "         of the current working dir"
    echo "$0 kal langs"
    echo "$0 hdn keyboards"
    echo "$0 fao prooftesting"
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
availableTemplateColls=$(for t in $GTHOME/giella-templates/*-templates; \
                        do n=$(basename $t); \
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
    echo "Giella infrastructure directory holding template-based"
    echo "language directories."
    exit 1
fi

if ! [ -f configure.ac ]
then
    echo "No configure.ac file in this directory. It seems this is not a proper"
    echo "Giella infrastructure directory holding template-based"
    echo "language directories."
    exit 1
fi

if test $(grep -c "^ALL_LANGS=" Makefile.am ) -eq 0 ; then
    echo "Something is wrong with your infrstructure setup:"
    echo "Your Makefile.am file does not set the variable ALL_LANGS."
    exit 1
fi

echo "*** updating $$GTHOME/giella-templates before populating the new directory.***"
svn up $GTHOME/giella-templates

TEMPLATEDIR=$TEMPLATECOLL-templates

# Copy template files to new language dir:
rsync -avzC $GTHOME/giella-templates/${TEMPLATEDIR}/und/ $1/

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
    info in the $1/LICENCE file, and start the real work. See
    https://giellalt.uit.no/GettingStarted.html for details.
EOF
