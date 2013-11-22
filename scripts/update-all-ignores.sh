#!/bin/bash

# This is a maintenance script to ease updating the svn:ignore property
# for all languages. It loops over all language dirs as defined in the *.am file
# and runs the set-svn-ignores-X.sh script in each of them.

# Wrong usage - short instruction:
if ! test $# -eq 0 ; then
    echo "Usage: $0"
    exit 1
fi

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

DIR=$(pwd)
TEMPLATENAME=$(basename $DIR)

# This script requires GTBIG to be accessible at setup time
# if the prooftesting files should be updated:
if ! test -e $DIR/Makefile.am ; then
    echo "Makefile.am not found - please call from within the directory above"
    echo "all language dirs, typically $GTHOME/langs/"
    echo "or $GTBIG/prooftesting/"
    exit 1
fi

# Extract the list of all languages from the $GTHOME/langs/Makefile.am file
# or from the $GTBIG/prooftesting/Makefile.am file:
ALL_LANGS=$(egrep '^ALL_LANGS=' < $DIR/Makefile.am \
			| sed -e 's/ALL_LANGS=//')

if test "x$ALL_LANGS" == "x" ; then
	echo "Script was called from the wrong directory. It must be called from"
	echo "the directory enclosing all language directories."
	exit 1
fi

for ll in $ALL_LANGS ; do
    if test -d $ll ; then
    	Language=$(${GTCORE}/scripts/iso639-to-name.sh $ll)
        echo "*** Setting svn:ignore's for $ll - $Language ***"
        cd $ll && ${GTCORE}/scripts/set-svn-ignores-$TEMPLATENAME.sh \
        	$(pwd) && cd ..
    fi
done

echo "*** Done: svn:ignore's for all languages updated. ***"
echo
