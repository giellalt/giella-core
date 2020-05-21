#!/bin/bash

# test script for dadmin apply script

# Variables:
reponame=$1
orgname=$2
langcode=$(echo $reponame | cut -d'-' -f2)
url=https://giella.zulipchat.com/api/v1/external/github
api_key="REPLACE_WITH_REAL_API_KEY_WHEN_USED"
stream="$langcode"

printf "${url}?api_key=${api_key}&stream=${stream}"
