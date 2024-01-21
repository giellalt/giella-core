#!/bin/bash
# updates to infra 2024
# this is a one off script but perhaps good for future reference
# how to work around some git isseus with big directory moves...

# cannot use $TMPDIR if it's /tmp on tmpfs  (RAM) because these stuff are huge
BIGTEMP="$HOME/tmp/"
if test $# -ne 1 ; then
    echo "Usage: $0 lang-XXX"
    exit 1
fi

function potentialmergefailyo() {
    if ! diff -u "$1" "$2" ; then
        echo maybe copy that diff to Makefile.modifications-local.am afterwards?
        select a in yes no ; do
            if test x$a = xno ; then
                echo lol
            fi
            break
        done
    else
        echo "ok cool $1 == $2 only gits quirky merge fails here..."
    fi
}

if ! test -d "$1" ; then
    echo "$1 must be a lang-XXX dir"
    exit 1
fi
# start with a clean clone anyways and a backup...
if ! test -d "$BIGTEMP/$1" ; then
    mv -v "$1" "$BIGTEMP" || return 1
else
    rm -rfv "$1"  # dangerous lol
fi
git clone git@github.com:giellalt/"$1"


gut template apply -o giellalt -r "^$1" -t template-lang-und
pushd "$1" || return 1
pushd src/fst || return 1
# mkdir morphology
git mv -v root.lexc morphology/
if test -f compounding.lexc ; then
    git mv -v compounding.lexc morphology/
fi
if test -f clitics.lexc ; then
    git mv -v clitics.lexc morphology/
fi
if ! git mv -v Makefile.am morphology/ ; then
    potentialmergefailyo Makefile.am morphology/Makefile.am
fi
if ! git mv -v Makefile.modifications-phon.am morphology/ ; then
    potentialmergefailyo Makefile.modifications-phon.am\
        morphology/Makefile.modifications-phon.am
fi
if test -f phonology.twolc ; then
    git mv -v phonology.twolc morphology/
fi
if test -f phonology.xfscript ; then
    git mv -v phonology.xfscript morphology/
fi
git mv -v affixes/ morphology/
git mv -v stems/ morphology/
git mv -v generated_files morphology/
git mv -v incoming/ morphology/
popd || return 1
pushd src || return 1
for f in filters/* filters/.gitignore orthography/* phonetics/* tagsets/* \
         transcriptions/*; do
    git mv -v "$f" "fst/$f" || git rm "$f" || rm -v "$f"
    git add "fst/$f"
done
# git autoremoves empty dirs sometimes so these may fail:
rmdir -v filters
rmdir -v orthography
rmdir -v tagsets
rmdir -v transcriptions
git mv hyphenation fst/syllabification
popd || return 1
popd || return 1
# move and change is too tricky for template merge
cp -v template-lang-und/src/fst/Makefile.am "$1/src/fst/Makefile.am"
cp -v template-lang-und/src/fst/morphology/Makefile.am "$1/src/fst/morphology/Makefile.am"
cp -v template-lang-und/src/fst/morphology/Makefile.modifications-local.am "$1/src/fst/morphology/Makefile.modifications-local.am"
pushd "$1" || return 1
git add src/fst/morphology/Makefile{,.modifications-local,.modifications-phon}.am
popd || return 1
if test -n "$(find "$1" -name '*.rej' -o -name '*.orig')" ; then
    echo fix thesE:
    find "$1" -name '*.rej' -o -name '*.orig'
    echo "say ’find . -name '*.rej' -delete , -name '*.orig' -delete’ at the end"
fi
echo now open another terminal and fix all that before we commit and push
select a in yes no ; do
    if test x$a = xno ; then
        echo lol
    fi
    break
done
gut commit -o giellalt -r "^$1$" -m "[Template merge] src/fst reorg"
gut template apply --continue -o giellalt -r "^$1$" -t template-lang-und
gut pull -o giellalt -r "^$1$"
echo "don't forget that you have a backup in $BIGTEMP/$1..."
pushd "$1" || return 1
if grep -F 'rev_id = 159' .gut/delta.toml ; then
    sed -i -e 's/rev_id = 159/rev_id = 160/' .gut/delta.toml
    sed -i -e 's/template_sha = .*/template_sha = "fc6d977744e106bcf7fd29789ca6a657ef70dd39"/' \
        .gut/delta.toml
    git commit .gut/delta.toml -m "Apply changes 160 manually"
fi
