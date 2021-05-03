#!/bin/bash

# gut apply script to revert last commit:

# git command:
# git fetch --all && git checkout main && git branch -D develop && git push origin --delete develop
git push origin --delete develop
