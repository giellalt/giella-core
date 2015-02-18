#!/bin/bash

set -e -u

dir=$1

dir=${dir%%/}
src_lang=${dir%???}
trg_lang=${dir#???}

cd "$(dirname "$0")/.."

src_ex () {
    xmlstarlet sel -t -m '//x/text()' -c . -n "${dir}/src"/*.xml | grep '[^[:space:][:punct:]]'
}
trg_ex () {
    xmlstarlet sel -t -m '//xt/text()' -c . -n "${dir}/src"/*.xml | grep '[^[:space:][:punct:]]'
}

cat<<EOF
Running language identification on examples in ${dir}/src/*.xml. We
expect at least a couple false hits :-)

Source examples (<x>) recognised as ${trg_lang}:
EOF
paste <(src_ex | pytextcat proc -s --langs "${src_lang},${trg_lang}" ) <(src_ex) | grep "^${trg_lang}" || true
cat <<EOF

Target examples (<xt>) recognised as ${src_lang}:
EOF
paste <(trg_ex | pytextcat proc -s --langs "${src_lang},${trg_lang}" ) <(trg_ex) | grep "^${src_lang}" || true
