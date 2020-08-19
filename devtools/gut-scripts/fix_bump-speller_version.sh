#!/bin/bash

# test script for gut apply script

# Variables:
LANGDIR=$(pwd)

if test ! -f $LANGDIR/configure.ac ; then
    echo no such file
    exit
fi

init_string=$(grep 'SPELLERVERSION' $LANGDIR/configure.ac )
pre_version=$( echo $init_string | cut -d'[' -f-2)
present_version=$( echo $init_string | cut -d'[' -f3 | cut -d']' -f1)
post_version=$( echo $init_string | cut -d']' -f3-)

#echo "orig: $init_string"

#echo $present_version

maj_version=$(echo $present_version | cut -d'.' -f1 )
min_version=$(echo $present_version | cut -d'.' -f2 )
patch_version=$(echo $present_version | cut -d'.' -f3 )

#echo "orig maj_version: $maj_version"
#echo "orig min_version: $min_version"
#echo "orig patch_version: $patch_version"

let patch_version++

#echo "new maj_version: $maj_version"
#echo "new min_version: $min_version"
#echo "new patch_version: $patch_version"

new_init_string=${pre_version}[${maj_version}.$min_version.$patch_version]$post_version

#echo "new_init_string: $new_init_string"

awk '/^SPELLERVERSION/ {exit} {print}' $LANGDIR/configure.ac > $LANGDIR/configure.ac.tmp
echo $new_init_string                                       >> $LANGDIR/configure.ac.tmp
sed -e "1,/^SPELLERVERSION/d" $LANGDIR/configure.ac         >> $LANGDIR/configure.ac.tmp

mv -f $LANGDIR/configure.ac.tmp $LANGDIR/configure.ac
