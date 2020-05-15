#!/bin/bash

# test script for gut apply script

# Variables:
reponame=$1
orgname=$2
langcode=$(echo $reponame | cut -d'-' -f2)
langname=$( $GTHOME/giella-core/scripts/iso639-to-name.sh $langcode )

printf "Finite state and Constraint Grammar based analysers and proofing tools, and language resources for the $langname language"
