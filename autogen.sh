#!/bin/sh

echo "Initial automake setup of $(basename "$(pwd)")"


# autoreconf should work for most platforms
autoreconf -i -v

if ! type pre-commit > /dev/null 2>&1 ; then
    echo "we recommend use of pre-commit for automatic checks and fixes:"
    echo "  on mac: sudo brew install pre-commit"
    echo "  on many others: sudo python3 -m pip install pre-commit"
fi
