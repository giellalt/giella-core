#!/bin/bash
if test $# -lt 2 ; then
    echo "Usage: $0 LANGS..."
    exit 1
fi
echo '# genereated map from $@"'
echo
echo '```geojson
{
  "type": "FeatureCollection",
  "features": ['
for d in $@ ; do
    cat $d/docs/language-map.md |\
        grep -F -v '```' |\
        sed -e 's/^}/},/' |\
        sed -e 's/^/    /'
done
echo '  ]
}
```'
