#!/bin/bash

# Run this to test building a language in a reasonably clean environment. Set the
# variable `testlang` on line 24 to the language you want to test.
#
# This is a slightly modified version of the following gist by Tino Didriksen:
#
# https://gist.github.com/TinoDidriksen/bc44df6cddf551454d58adc14b416192

P=$PATH

# Unset all envvars
for e in $(env | awk -F"=" '{print $1}') ; do
unset $e ; done

export PATH=$P
export TMPDIR=/tmp
export LC_ALL=en_US.UTF-8

echo "Only these envvars are set:"
env
echo ""

testlang=sma

rm -rf /tmp/test-$testlang
mkdir -v /tmp/test-$testlang
pushd /tmp/test-$testlang
svn co https://github.com/giellalt/giella-core.git/trunk giella-core
svn co https://github.com/giellalt/lang-${testlang}.git/trunk "lang-$testlang"

pushd giella-core
autoreconf -fvi
./configure
make
popd

export GIELLA_CORE=/tmp/test-$testlang/giella-core

pushd lang-$testlang
./autogen.sh
autoreconf -fvi
./configure --enable-analysers --enable-generators --enable-tokenisers --enable-reversed-intersect --enable-spellers --enable-hfst-mobile-speller --enable-alignment --disable-minimised-spellers --enable-apertium --enable-grammarchecker --with-backend-format=foma --enable-dicts --enable-oahpa
make -j4 V=1 VERBOSE=1 2>&1 | tee build.log
popd
