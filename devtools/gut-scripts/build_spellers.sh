#!/bin/bash

# gut apply script to run autogen.sh and configure with spellers enabled,
# and using out-of-source builds + checks

# command:
./autogen.sh && mkdir -p bygg/rett/ && cd bygg/rett/ && ../../configure --enable-spellers && make -j && make check -j
