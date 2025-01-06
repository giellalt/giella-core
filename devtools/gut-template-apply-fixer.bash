#!/bin/bash
# when you do gut template apply and it just fails and you manually merge and
# have to update the template.toml afterwards anyways...

revision=$(fgrep 'rev_id =' "$GTLANGS"/template-lang-und/.gut/template.toml |\
    sed -e 's/.*rev_id = //')
prev=$((revision - 1))
pushd template-lang-und || return 1
newhash=$(git rev-parse HEAD)
popd || return 1

for d in lang-* ; do
    pushd "$d" || return 1
    if grep -F "rev_id = $prev" .gut/delta.toml ; then
        sed -i -e "s/rev_id = $prev/rev_id = $revision/" .gut/delta.toml
        sed -i -e "s/template_sha = .*/template_sha = \"$newhash\"/" \
            .gut/delta.toml
        git commit .gut/delta.toml -m "Applied changes $revision manually"
        rm -rf .git/gut/template_apply
    fi
    popd || return 1
done
