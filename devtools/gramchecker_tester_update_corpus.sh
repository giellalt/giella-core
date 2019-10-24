#!/bin/bash
# usage: gramchecker_tester_update_corpus.sh <zcheck archive> <freecorpus directory> <boundcorpus directory>

cd $2
echo "Updating $2"
rm -rf correct-no-gs/converted
rm -rf goldstandard/converted
svn up
svn log -v -r7534:HEAD | awk -v username="thomas" '{print username} /^r[0-9]+ / {user=$3} /./ {if (user==username) {print}}'| grep -E "^   M|^   G|^   A|^   D|^   C|^   U" | awk '{print $2}'|sort|uniq|fgrep /orig/sme | sed 's_/orig/_orig/_' | xargs convert2xml --goldstandard

cd $3
echo "Updating $3"
rm -rf correct-no-gs/converted
rm -rf goldstandard/converted
svn up
svn log -v -r5037:HEAD | awk -v username="thomas" '{print username} /^r[0-9]+ / {user=$3} /./ {if (user==username) {print}}'| grep -E "^   M|^   G|^   A|^   D|^   C|^   U" | awk '{print $2}'|sort|uniq|fgrep /orig/sme | sed 's_/orig/_orig/_' | xargs convert2xml --goldstandard

echo "Finished with conversion"

cd $GTHOME/langs/sme/devtools/
for j in goldstandard correct-no-gs
do
    for i in $2 $3
    do
        echo "Gramchecking in $i/$j/converted/sme"
        time $GTHOME/giella-core/devtools/gramcheck_tester2.py $1 $i/$j/converted/sme
    done
    echo "Report on $j"
    time $GTHOME/giella-core/devtools/gramcheck_comparator.py $1 $j --filtererror errorlex errormorphsyn errorortreal
done
