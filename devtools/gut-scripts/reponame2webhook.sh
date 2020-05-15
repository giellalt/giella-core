#!/bin/bash

# test script for dadmin apply script

# Variables:
reponame=$1
orgname=$2
langcode=$(echo $reponame | cut -d'-' -f2)
url=https://giella.zulipchat.com/api/v1/external/github
api_key="api_key=NEbDQEHRPlGcOe3Mg2YDk7m9xf6cLVqG"
stream="stream=$langcode"

printf "${url}?${api_key}&${stream}"
