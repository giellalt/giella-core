#!/bin/bash
dump=$GTHOME/words/terms/termwiki/dump.xml
line=$(head -n 1 $dump)

# Strip the first empty line in dump.xml
if [ -z "${line}" ]; then
  echo "First line is empty"
  tail -n +2 $dump > dump.tmp && mv dump.tmp $dump
fi

# Run tranformation and commit changes
if [ "$(svn status $dump | awk '{ print $1 }')" == "M" ]; then
  echo "XML dump has updated."
  ant -buildfile $GTHOME/tools/TermWikiExporter/build.xml run xslt
  rm $GTHOME/tools/TermWikiExporter/terms/*
  # /opt/local/bin/gulp --gulpfile ../../words/Gulpfile.js --cwd ../../words store --passwd "$1"
  svn commit -m"Automatic commit of recent changes in the Termwiki." $GTHOME/words/terms/termwiki
fi
