#!/bin/bash

MYGTCORE=

if   test   "${GTCORE}";     then
    MYGTCORE=${GTCORE}
elif test   "$(gt-core.sh)"; then
    MYGTCORE=$(gt-core.sh)
else
    echo "Unable to determine GTCORE, either run 'sudo make install' in" >&2
    echo "your gtcore directory, or set GTCORE in .profile or similar."  >&2
    exit 1
fi

# Wrong usage - short instruction:
if ! test $# -eq 3 -o $# -eq 4 ; then
    echo
    echo "Usage: $0 LANGUAGE_CODE ROOT_LANG_DIR VERSION_FILE [VARIANT]"
    echo
    echo "where:"
    echo "   LANGUAGE_CODE=iso639 code of the wanted language"
    echo "   ROOT_LANG_DIR=\$top_srcdir (the dir with the configure.ac file)"
    echo "   VERSION_FILE=file containing the speller version info"
    echo "   VARIANT=variant tag (script code, country code, alt. spelling)"
    echo
    exit 1
fi

Language=$(${MYGTCORE}/scripts/iso639-to-name.sh $1)
Revision=$(svn info --xml $2 | grep -A 4 '<entry' \
		 | grep revision | grep -Eo '[0-9]+')
Version=$(cat $3)
Variant=$4

Date=$(date +%d.%m.%Y)
HfstVersion=$(hfst-info | grep 'HFST version' | grep -Eo '[0-9.]+')
HfstRevision=$(hfst-info | grep 'revision' | grep -Eo '[0-9.]+')

if test $Variant == 'default' -o "x$Variant" == 'x'; then
    VariantText=""
    Variant=""
else
    VariantText=" using $Variant"
    Variant="-$Variant"
fi

echo "Divvun speller for $Language$VariantText"
echo "$1$Variant version $Version, $Date, rev$Revision"
echo "Built using HFST $HfstVersion, rev$HfstRevision"
