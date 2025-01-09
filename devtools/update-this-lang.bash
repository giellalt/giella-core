#!/bin/bash
# update a language with deps
# bit like update-kal.sh but more basic, for giellalt's all langs like

# for debugging:
# set -x

if ! test -f configure.ac ; then
    echo "cannot find ./configure.ac, this needs to be run from lang-xxx dir"
    exit 1
fi

git pull || exit 1

function clone_or_pull_and_make_local() {
    if test -z "$1" ; then
        echo "$0 called without parameters"
        exit 1
    fi
    echo updating "../$1"
    if test ! -d "../$1" ; then
        git clone -q https://github.com/giellalt/"$1" "../$1"
        pushd "../$1" || return 1
        ./autogen.sh || return 1
        ./configure || return 1
        make -s || return 1
        popd || return 1
    else
        pushd "../$1" || return 1
        git pull -q || return 1
        ./autogen.sh || return 1
        if test -x config.status ; then
            ./config.status || return 1
        else
            ./configure || return 1
        fi
        make -s || return 1
        popd || return 1
    fi
}

function didnt_work() {
    echo "There was an error with $1! See above. Also: "
    exit 1
}

clone_or_pull_and_make_local giella-core || didnt_work giella-core
clone_or_pull_and_make_local shared-mul || didnt_work shared-mul
for ll in $(grep -F gt_USE_SHARED < configure.ac | cut -d , -f 2 | tr -d '[]') ;\
do
    clone_or_pull_and_make_local "$ll" || didnt_work "$ll"
done
for ll in $(grep -F gt_NEED_SHARED < configure.ac | cut -d , -f 2 | tr -d '[]') ;\
do
    clone_or_pull_and_make_local "$ll" || didnt_work "$ll"
done

git pull -q || didnt_work "git pull"
./autogen.sh || didnt_work "autogen.sh"
if test -x config.status ; then
    ./config.status || didnt_work "config.status"
else
    ./configure || didnt_work "configure"
fi
echo "$(basename "$(pwd)") updated, you may run make now"

