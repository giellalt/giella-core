#!/bin/bash

# `gut set info` script to specify website for repositories

# Input arguments:
reponame=$1
orgname=$2

printf "https://${orgname}.github.io/${reponame}"
