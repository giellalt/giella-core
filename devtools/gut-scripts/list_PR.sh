#!/bin/bash

# gut apply script to revert last commit:

reponame=$(basename $(pwd))

curl -s -H "Accept: application/vnd.github.v3+json" https://api.github.com/repos/giellalt/$reponame/pulls | tail -n +2 | tail -r | tail -n +2 | grep -v '^$' | wc -l
