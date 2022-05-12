#!/bin/bash
GITURL="git@github.com:giellalt"
if test $# != 1 ; then
    echo "Usage: $0 GIELLALT-REPO"
    exit 1
fi

if test -d "$1" ; then
    echo "$1 exists already"
    exit 1
fi
echo "fetching giella-core that is required for all builds"
if ! test -d giella-core ; then
    if ! git clone $GITURL/giella-core ; then
        echo "git clone giella-core failed"
        exit 1
    fi
fi
# TODO: remove
echo "fetching giella-shared that is required for all builds"
if ! test -d giella-shared ; then
    if ! git clone $GITURL/giella-shared ; then
        echo "git clone giella-shared failed"
        exit 1
    fi
fi
echo "fetching $1"
if ! git clone "$GITURL/$1" ; then
    echo "git clone $1 failed"
    exit 1
fi
echo "fetching optional dependencies"
if grep -F -q 'gt_USE_SHARED' "$1/configure.ac" ; then
    for r in $(grep gt_USE_SHARED "$1/configure.ac" |\
               sed -e 's/^.*gt_USE_SHARED([^,]*, *//' | tr -d '[)]') ; do
        echo "fetching $r"
        if test -d "$r" ; then
            echo "$r exists already, skipping"
        elif ! git clone "$GITURL/$r" ; then
            echo "git clone $r failed"
            exit 1
        fi
    done
fi
echo "succesfully cloned $1 and its optional dependencies into $(pwd)"
echo "configuring giella-core"
pushd giella-core || exit 1
autoreconf -i
./configure
popd || exit 1
# TODO: remove
echo "configuring giella-shared"
pushd giella-core || exit 1
autoreconf -i
./configure
popd || exit 1
echo "building $1..."
pushd "$1" || exit 1
autoreconf -i
./configure
make
popd || exit 1
echo "built $1"

