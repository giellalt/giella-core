#!/bin/sh

echo "Initial automake setup of $(basename "$(pwd)")"


# autoreconf should work for most platforms
autoreconf -i -v

if ! type pre-commit > /dev/null 2>&1 ; then
    echo "we recommend use of pre-commit for automatic checks and fixes:"
    echo "  on mac: brew install pre-commit"
    echo "  on others: pipx install pre-commit"
fi
