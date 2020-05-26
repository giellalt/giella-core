#!/bin/bash

# Wrong usage - short instruction:
if ! test $# -eq 4 -o $# -eq 5 ; then
    echo
    echo "Usage: $0 LANGUAGE_CODE TOPSRCDIR VERSION PLATFORM [VARIANT]"
    echo
    echo "where:"
    echo "   LANGUAGE_CODE=iso639 code of the wanted language"
    echo "   TOPSRCDIR=Obsolete"
    echo "   VERSION=speller version info"
    echo "   PLATFORM=target platform, one of 'mobile' or 'desktop'"
    echo "   VARIANT=variant tag (script code, country code, alt. spelling)"
    echo
    exit 1
fi

# Find path to self, to reliably call other scripts in the same dir:
SELFDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"

Language=$($SELFDIR/iso639-to-name.sh $1)
RevisionPath=$2
Version=$3
Platform=$4
Variant=$5

Date=$(date +%d.%m.%Y-%H%M)
HfstVersion=$(hfst-info | grep 'HFST version' | grep -Eo '[0-9.]+')

if test $Variant == 'default' -o "x$Variant" == 'x'; then
    VariantText=""
    Variant=""
else
    VariantText=" using $Variant"
    Variant="-$Variant"
fi

echo "Divvun speller for $Language$VariantText"
echo "$1$Variant, $Platform, version $Version, ${Date}"
echo "Built using HFST $HfstVersion"
