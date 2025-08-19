#!/bin/bash

ask=always
if ! test -d lang-zxx ; then
    echo "run this script in giellalt gut root that has lang-* subdirs!"
    exit 2
fi
for f in lang-* ; do
    if test $ask = always ; then
        echo "skip $f?"
        select answer in yes no never ; do
            if test $answer == yes ; then
                continue 2
            elif test $answer = never ; then
                ask=never
            else
                break
            fi
        done
    fi
    pushd "$f" || exit 1
    ./autogen.sh || exit 1
    ./configure "$@" || exit 1
    if ! make ; then
        echo this needs to be fixed later...
        echo "$f" >> ../broken-makes
        popd || exit 1
        continue
    fi
    if ! make check ; then
        echo repeat?
        select answer in yes no ; do
            if test $answer == yes ; then
                make check
            else
                break
            fi
        done
    fi
    popd || exit 1
done
if test -s broken-makes ; then
    echo these need to be fixed:
    cat broken-makes
fi
