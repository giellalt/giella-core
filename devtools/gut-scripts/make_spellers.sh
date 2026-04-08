#!/bin/bash

# gut apply script to run make & make checks. Assumes that the build
# dir is bygg/rett/ and that autogen.sh and configure has been run,
# which can be done using the build_spellers.sh skript.
# Ie this is a shorthand script for fast rerunning just make and
# make check again

# command:
cd bygg/rett/ && make -j && make check -j
