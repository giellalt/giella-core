#!/bin/bash

# test script for gut apply script

# Variables:
LANGDIR=$(pwd)

new_sha="5560f05c957441070e4ceec926c92c42fb2fe43d"
new_rev_id=2

sed -e "/rev_id/s/=.*\$/= $new_rev_id/" \
    -e "/template_sha/s/=.*\$/= \"$new_sha\"/" < $LANGDIR/.gut/delta.toml \
    > $LANGDIR/.gut/new_delta.toml
mv -f $LANGDIR/.gut/new_delta.toml $LANGDIR/.gut/delta.toml
