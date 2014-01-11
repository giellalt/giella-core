#!/bin/bash

if test -z "${GTCORE}" ; then
    echo "Unable to determine GTCORE, re-run gtsetup.sh and re-try"
    exit 1
fi

# Wrong usage - short instruction:
if ! test $# -eq 3 ; then
    echo
    echo "Usage: $0 LANGUAGE_CODE ROOT_LANG_DIR VERSION_FILE"
    echo
    echo "where:"
    echo "   LANGUAGE_CODE=iso639 code of the wanted language"
    echo "   ROOT_LANG_DIR=\$top_srcdir (the dir with the configure.ac file)"
    echo "   VERSION_FILE=file containing the speller version info"
    echo
    exit 1
fi

Language=$(${GTCORE}/scripts/iso639-to-name.sh $1)

Date=$(date +%Y.%m.%d)
Version=$(cat $3)
Revision=$(svn info $2 | grep Revision | grep -Eo '[0-9]+')
HfstVersion=$(hfst-info | grep 'HFST version' | grep -Eo '[0-9.]+')
HfstRevision=$(hfst-info | grep 'revision' | grep -Eo '[0-9.]+')

echo "Divvun for $Language"
echo "$1 version $Version, $Date, rev$Revision"
echo "Built using HFST $HfstVersion, rev$HfstRevision"
