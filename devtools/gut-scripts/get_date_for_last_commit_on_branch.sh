#!/bin/bash

# gut apply script to revert last commit:

reponame=$(basename $(pwd))

curl -s -H "Accept: application/vnd.github.v3+json" https://api.github.com/repos/giellalt/$reponame/commits/master | grep "date" | head -n +1 | cut -d':' -f2 | cut -d'"' -f2 | cut -d'T' -f1
