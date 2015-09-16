#!/bin/sh

echo "Initial automake setup of $(basename $(pwd))"

echo 'subdir_files = \' > subfiles.mk
find gtdshared scripts -type f -print | \
    grep -vE '/(Makefile|.*\.(am|in|ac)$|configure|config\.|autogen\.sh|build-aux|autom4te.cache|aclocal\.m4)' |\
    sed 's/^/   /;$q;s/$/ \\/' >> subfiles.mk

# autoreconf should work for most platforms
autoreconf -i -v
