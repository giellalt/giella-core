#!/bin/sh

echo "Initial automake setup of $(basename $(pwd))"

echo 'subdir_files = \' > subfiles.mk
find giella-shared -type f -print |\
    LC_ALL=C sort |\
    sed 's/^/   /;$q;s/$/ \\/' >> subfiles.mk

# autoreconf should work for most platforms
autoreconf -i -v
