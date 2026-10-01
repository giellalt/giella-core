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
        map_tmp=docs/language-map.md.tmp.$$
        if awk -v longitude="$LONG" -v latitude="$LAT" '
            /"coordinates":[[:space:]]*\[/ {
                sub(/"coordinates":[[:space:]]*\[[^]]*\]/,
                    "\"coordinates\": [" longitude ", " latitude "]")
                updated = 1
            }
            { print }
            END { if (!updated) exit 1 }
        ' docs/language-map.md > "$map_tmp"; then
            mv "$map_tmp" docs/language-map.md
        else
            rm -f "$map_tmp"
            echo "$0: failed to update coordinates in docs/language-map.md" >&2
            exit 1
        fi
    else
        echo I assume no
    fi
    break
done
echo "replace map in README.md with current map:"
cat docs/language-map.md
select answer in yes no ; do
    if test $answer == yes ; then
        readme_tmp=README.md.tmp.$$
        if awk -v map=docs/language-map.md '
            BEGIN {
                while ((getline line < map) > 0)
                    map_lines[++map_count] = line
                close(map)
            }
            /^```geojson$/ {
                for (i = 1; i <= map_count; i++) print map_lines[i]
                in_map = 1
                found = 1
                next
            }
            in_map && /^```$/ { in_map = 0; closed = 1; next }
            !in_map { print }
            END { if (!found || in_map || !closed) exit 1 }
        ' README.md > "$readme_tmp"; then
            mv "$readme_tmp" README.md
        else
            rm -f "$readme_tmp"
            echo "$0: failed to replace the map block in README.md" >&2
            exit 1
        fi
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

