#!/bin/bash

# gut apply script to run autogen.sh and configure with defaults, to update
# generated and committed files like manifest.toml:

# command:
./autogen.sh && mkdir -p bygg/rett/ && cd bygg/rett/ && ../../configure --enable-spellers && make -j && make check -j
