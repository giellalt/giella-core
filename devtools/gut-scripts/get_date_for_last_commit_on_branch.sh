#!/bin/bash

# gut apply script to revert last commit:

reponame=$(basename $(pwd))

# Replace OAUTH-TOKEN with your real token.
curl -s -H "Accept: application/vnd.github.v3+json" curl -H "Authorization: token OAUTH-TOKEN" https://api.github.com/repos/giellalt/$reponame/commits/master | grep "date" | head -n +1 | cut -d':' -f2 | cut -d'"' -f2 | cut -d'T' -f1
