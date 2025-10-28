#!/bin/bash

if ! test -f .glottologid.txt ; then
    echo "$0: missing .glottologid.txt"
    echo "need to run this script inside a lang directory"
    exit 1
fi
if ! test -f docs/language-map.md ; then
    echo "$0: missing docs/language-map.md???"
    echo "run git pull or something"
    exit 1
fi
GLOT=$(<.glottologid.txt)
if test -z "${GLOT}" ; then
    echo failed to read glottolog id
    exit 1
fi
echo "using ${GLOT}"
if ! wget https://glottolog.org/resource/languoid/id/${GLOT}.json ; then
    echo "failed to fetch language data from glottolog"
    exit 1
fi
LONG=$(jq '.["longitude"]' "${GLOT}.json")
LAT=$(jq '.["latitude"]' "${GLOT}.json")
echo "update docs/language-map.md coordinates with [$LONG, $LAT]?"
select answer in yes no ; do
    if test $answer == yes ; then
        sed -i -e "s/coordinates\"\?: .*/coordinates\": [$LONG, $LAT]/" \
            docs/language-map.md
    else
        echo I assume no
    fi
    break
done
echo "replace map in README.md with current map:"
cat docs/language-map.md
select answer in yes no ; do
    if test $answer == yes ; then
        sed -e '/^```geojson$/,/^```$/c §§§§' < README.md |\
            sed -e '/§§§§/r docs/language-map.md' -e '/§§§§/d' > README.md.tmp
        mv README.md.tmp README.md
    else
        echo I guess not
    fi
    break
done
rm -v "${GLOT}.json"
git diff README.md docs/language-map.md
echo "send updates to git with standard kind of message"
select answer in yes no ; do
    if test $answer == yes ; then
        git commit README.md docs/language-map.md \
            -m "updated map data from glottolog site coordinates"
    else
        echo nah
    fi
    break
done

