#!/bin/bash

# This is a maintenance script to ease propagating changes in the core template
# to all languages. It loops over all language dirs as defined in the *.am file
# and runs the merge script in each of them.

# The whole GT infra requires GTCORE to be accessible at setup time
if test -z $GTCORE ; then
    echo variable GTCORE not set, run gtsetup.sh and retry
    exit 1
fi

# This script requires GTHOME to be accessible at setup time
if test -z $GTHOME ; then
    echo variable GTHOME not set, run gtsetup.sh and retry
    exit 1
fi

# Extract the list of all languages from the $GTHOME/langs/*.am file:
ALL_LANGS=$(egrep '^ALL_LANGS=' < $GTHOME/langs/Makefile.am \
			| sed -e 's/ALL_LANGS=//')

for ll in $ALL_LANGS ; do
    if test -d $ll ; then
    	Language=$(${GTCORE}/scripts/iso639-to-name.sh $ll)
        echo
        echo "*** Setting svn:ignore's for language $ll - $Language ***"
        echo
        cd $ll && ${GTCORE}/scripts/set-svn-ignores.sh $(pwd) && cd ..
    fi
done

echo
echo "*** Done: svn:ignore's for all languages updated. ***"
echo
