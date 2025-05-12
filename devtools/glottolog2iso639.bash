#!/bin/bash
# download glottolog codes and compile a mappings to iso 639-3
#
# also use jq to script further when needed
curl https://glottolog.org/resourcemap.json?rsc=language |\
    jq '[.resources[] | {glottocode: .id, isocode: [.identifiers[]] | map(select(.type == "iso639-3"))[0].identifier}] | map(select(.isocode!=null))'

