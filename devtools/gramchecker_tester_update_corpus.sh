#!/bin/bash
# usage: gramchecker_tester_update_corpus.sh <zcheck archive> <freecorpus directory> <boundcorpus directory>

cd $2
echo "Updating $2"
rm -rf correct-no-gs
rm -rf goldstandard
svn -q up
svn log -v -r7534:HEAD | awk -v username="thomas" '{print username} /^r[0-9]+ / {user=$3} /./ {if (user==username) {print}}'| grep -E "^   M|^   G|^   A|^   D|^   C|^   U" | awk '{print $2}'|sort|uniq|fgrep /orig/sme | sed 's_/orig/_orig/_' | xargs convert2xml --goldstandard

cd $3
echo "Updating $3"
rm -rf correct-no-gs
rm -rf goldstandard
svn -q up
svn log -v -r5037:HEAD | awk -v username="thomas" '{print username} /^r[0-9]+ / {user=$3} /./ {if (user==username) {print}}'| grep -E "^   M|^   G|^   A|^   D|^   C|^   U" | awk '{print $2}'|sort|uniq|fgrep /orig/sme | sed 's_/orig/_orig/_' | xargs convert2xml --goldstandard

echo "Finished with conversion"

cd $GTHOME/giella-core/devtools/
for i in $2 $3
do
    for j in correct-no-gs goldstandard
    do
        echo "Gramchecking in $i/$j/converted/sme"
        time $GTHOME/giella-core/devtools/gramcheck_tester2.py $1 $i/$j/converted/sme
        time $GTHOME/giella-core/devtools/gramcheck_comparator.py --filtererror=errorlang,errorlex,errormorphsyn,errorortreal $1 $i/$j/converted/sme
    done
done
