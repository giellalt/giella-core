#!/bin/bash
# run make in an updated environment

cd $GTLANGS/giella-core
git pull
./autogen.sh
./configure
cd $GTLANGS/giella-shared
git pull
./autogen.sh
./configure
cd $GTLANGS/lang-$1
git pull
make clean
make
