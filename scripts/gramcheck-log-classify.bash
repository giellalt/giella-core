#!/bin/bash
if test $# != 1 ; then
    echo "Usage $0 REPORTFILE"
    exit 1
fi
for t in tp fn1 fn2 fp1 fp2 tn errorsyn errorort typo errorformat ; do
    echo -n $t:$'\t'
    grep -F -c "$t" "$1"
done
for t in tp fn1 fn2 fp1 fp2 tn ; do
    for e in errorsyn errorort errorformat typo ; do
        echo -n $t...$e$'\t'
        grep -E -c "$t.*$e" "$1"
    done
done
