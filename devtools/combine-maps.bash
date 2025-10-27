#!/bin/bash
if test $# -lt 2 ; then
    echo "Usage: $0 LANGS..."
    exit 1
fi
echo '# Map genereated from $@"'
echo
echo '```geojson
{
  "type": "FeatureCollection",
  "features": ['
for d in $@ ; do
    # Check if coordinates are [0, 0] - if so, skip this repo
    if grep -q '"coordinates": \[0, 0\]' "$d/docs/language-map.md" 2>/dev/null; then
        echo "Skipping $d - coordinates are [0, 0]" >&2
        continue
    fi
    cat $d/docs/language-map.md |\
        grep -F -v '```' |\
        sed -e 's/^}/},/' |\
        sed -e 's/^/    /'
done
echo '  ]
}
```'
