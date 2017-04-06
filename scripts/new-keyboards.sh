#!/bin/bash
if test -z "${GTCORE}" ; then
    echo "Unable to determine GTCORE, re-run gtsetup.sh and re-try"
    exit 1
fi

# Wrong usage - short instruction:
if ! test $# -eq 1; then
    echo "Usage: $0 LANG"
    echo
    echo "e.g.:"
    echo "$0 sma"
    echo
    exit 1
fi

COLLECTION_NAME=$1
shift
first_lang=$1
shift
other_langs=$@

# Extract template collection name from current dir:
curDir=$(pwd)
TEMPLATECOLL=$(basename $curDir | cut -d'-' -f2)

# Test whether the current directory name matches 'keyboards'
# If the test fails, write a message and exit:
if test "x$TEMPLATECOLL" != "xkeyboards" ; then
    echo "You are not in a keyboards directory."
    echo "The given or identified collection name is '$TEMPLATECOLL', but"
    echo "should be:"
    echo
    echo "keyboards"
    echo
    echo "Move to a suitable directory, or rename your keyboards directory."
    exit 1
fi

if ! [ -f Makefile.am ]
then
    echo "No Makefile.am file in this directory. It seems this is not a proper"
    echo "Divvun/Giellatekno infrastructure directory holding template-based"
    echo "keyboards directories."
    exit 1
fi

if ! [ -f configure.ac ]
then
    echo "No configure.ac file in this directory. It seems this is not a proper"
    echo "Divvun/Giellatekno infrastructure directory holding template-based"
    echo "keyboards directories."
    exit 1
fi

if test $(grep -c "^ALL_KEYBOARDS=" Makefile.am ) -eq 0 ; then
    echo "Something is wrong with your infrstructure setup:"
    echo "Your Makefile.am file does not set the variable ALL_KEYBOARDS."
    exit 1
fi

TEMPLATEDIR=$TEMPLATECOLL-templates

# Copy template files to new language dir:
rsync -avzC ${GTCORE}/${TEMPLATEDIR}/und/ $COLLECTION_NAME/

# Replace placeholder language code with real language code:
${GTCORE}/scripts/replace-dummy-langcode.sh \
                  "$curDir/$COLLECTION_NAME" $first_lang

# Rename files with placeholder language code:
for f in $(find ./$COLLECTION_NAME -name "*__UND__*") ; do
    newf=$( echo $f | sed -e "s/__UND__/$first_lang/g"  )
    mv -f $f $newf
done

# Loop over the list of other languages, adding a keyboard template file
# for each, and add the language code to the project file:
if test "x$other_langs" != "x"; then
    for lang in $other_langs; do
        rsync -avzC ${GTCORE}/${TEMPLATEDIR}/und/mobile/__UND__.yaml \
                    $COLLECTION_NAME/mobile/
        ${GTCORE}/scripts/replace-dummy-langcode.sh \
                  "$curDir/$COLLECTION_NAME" $lang
        for f in $(find . -name "*__UND__*") ; do
            newf=$( echo $f | sed -e "s/__UND__/$lang/g"  )
            mv -f $f $newf
        done
        cp $COLLECTION_NAME/mobile/project.yaml \
           $COLLECTION_NAME/mobile/project.yaml~
        sed -e "s/^\(layouts: \\[.*\)\\]/\1 $lang]/" \
            < $COLLECTION_NAME/mobile/project.yaml~ \
            > $COLLECTION_NAME/mobile/project.yaml
        rm -f $COLLECTION_NAME/mobile/project.yaml~
    done
fi

# Update Makefile.am with the new keyboard collection:
cp Makefile.am Makefile.am~
sed -e "s/NEW_KEYBOARDS=\(.*\)$COLLECTION_NAME/NEW_LANGS=\1/" \
    -e "s/ALL_KEYBOARDS=/ALL_KEYBOARDS=$COLLECTION_NAME /" \
    < Makefile.am~ > Makefile.am

# Update configure.ac with the new language:
cp configure.ac configure.ac~
sed -e "s/AC_CONFIG_SUBDIRS(\\[/AC_CONFIG_SUBDIRS([$COLLECTION_NAME /" \
	< configure.ac~ > configure.ac

# Stamp new language dir with latest template merging time
touch $COLLECTION_NAME/und.timestamp

# Add the new language to svn:
svn add --force $COLLECTION_NAME

# Now that the files are known to svn, add svn:ignore properties:
${GTCORE}/scripts/set-svn-ignores-$TEMPLATECOLL.sh $COLLECTION_NAME

cat<<EOF
    The new keyboard collection $COLLECTION_NAME has been added to the
    top-level Makefile. The old Makefile has been backed up as Makefile.am~
    All dirs and files in $COLLECTION_NAME have been added to svn.
    Either \"svn ci $COLLECTION_NAME\" if
    all is ok, or \"svn revert $COLLECTION_NAME\" if not.
    If all is ok, remember to also commit the changes to ./Makefile.am and
    ./configure.ac, to ensure that automatic processes are aware
    of the new keyboard collection.
    To start working on the new keyboard collection, fill in license
    and copyright info in the $COLLECTION_NAME/LICENCE file, and
    then start filling the files in
    $COLLECTION_NAME/mobile/ with keyboard content.
EOF
