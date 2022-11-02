#!/bin/bash

# `gut set info` script to set a description for multiple repos

# Input arguments:
reponame=$1
orgname=$2

# Other variables:
selfdir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

langcode=$(echo $reponame | cut -d'-' -f2)
langname=$( $selfdir/../../scripts/iso639-to-name.sh $langcode )

printf "Finite state and Constraint Grammar based analysers and proofing tools, and language resources for the $langname language"
