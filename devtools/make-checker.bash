#!/bin/bash

if ! test -d lang-zxx ; then
    echo "run this script in giellalt gut root that has lang-* subdirs!"
    exit 2
fi
for f in lang-* ; do
    echo "skip $f?"
    select answer in yes no ; do
        if test $answer == yes ; then
            continue 2
        else
            break
        fi
    done
    pushd "$f" || exit 1
    ./autogen.sh || exit 1
    ./configure "$@" || exit 1
    if ! make ; then
        echo this needs to be fixed later...
        echo "$f" >> ../broken-makes
        popd || exit 1
        continue
    fi
    make check
    echo repeat?
    select answer in yes no ; do
        if test $answer == yes ; then
            make check
        else
            break
        fi
    done
    popd || exit 1
done
if test -s broken-makes ; then
    echo these need to be fixed:
    cat broken-makes
fi
