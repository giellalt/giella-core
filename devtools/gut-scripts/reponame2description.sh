#!/bin/bash

# `gut set info` script to set a description for multiple repos

# Input arguments:
reponame=$1
orgname=$2

# Other variables:
selfdir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

prefix=$(echo $reponame | cut -d'-' -f1)
langcode=$(echo $reponame | cut -d'-' -f2)
langname=$( $selfdir/../../scripts/iso639-to-name.sh $langcode )

case "$prefix" in
    keyboard)
        printf "Keyboard layouts for the $langname language"
        ;;
    dict)
        targetcode=$(echo $reponame | cut -d'-' -f3)
        targetname=$( $selfdir/../../scripts/iso639-to-name.sh $targetcode )
        printf "An electronic dictionary from $langname to $targetname"
        ;;
    shared)
        script=$(echo $reponame | cut -d'-' -f3)
        if [ -n "$script" ]; then
            printf "Shared $langname ($script) linguistic resources"
        else
            printf "Shared $langname linguistic resources"
        fi
        ;;
    lang|*)
        printf "Finite state and Constraint Grammar based analysers and proofing tools, and language resources for the $langname language"
        ;;
esac
