#!/bin/bash

# gut apply script to revert last commit:

# git command:
git fetch --all && git checkout main && git branch -D develop
