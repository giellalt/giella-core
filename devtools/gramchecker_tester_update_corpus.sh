#!/bin/bash
# usage: gramchecker_tester_update_corpus.sh thomas

cd $GTFREE
echo "Updating $GTFREE"
rm -rf correct-no-gs
rm -rf goldstandard
svn -q up
svn log -v -r7534:HEAD | awk -v username="$1" '{print username} /^r[0-9]+ / {user=$3} /./ {if (user==username) {print}}'| grep -E "^   M|^   G|^   A|^   D|^   C|^   U" | awk '{print $2}'|sort|uniq|fgrep /orig/sme | sed 's_/orig/_orig/_' | xargs convert2xml --goldstandard

cd $GTBOUND
echo "Updating $GTBOUND"
rm -rf correct-no-gs
rm -rf goldstandard
svn -q up
svn log -v -r5037:HEAD | awk -v username="$1" '{print username} /^r[0-9]+ / {user=$3} /./ {if (user==username) {print}}'| grep -E "^   M|^   G|^   A|^   D|^   C|^   U" | awk '{print $2}'|sort|uniq|fgrep /orig/sme | sed 's_/orig/_orig/_' | xargs convert2xml --goldstandard

echo "Finished with conversion"
