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

function diffoldmove() {
    if ! diff -u "$1" "$2" ; then
        echo "use old script?"
        select a in yes no ; do
            if test x$a = xyes ; then
                cp -v "$1" "$2"
            elif test x$a = xno ; then
                echo "assuming you fixed it then"
            fi
            git add -v "$2"
            break
        done
    else
        echo "new version same as old ok adding $1 == $2"
        git add -v "$2"
    fi
}

# try move things with git mv failed so we try to clean it up somehow
function difformove() {
    if ! diff -u "$1" "$2" ; then
        echo "this modified script needs to be adapted by hand :-("
        select a in yes no ; do
            if test x$a = xno ; then
                echo "we just use the $2 as is then"
            elif test x$a = xyes; then
                echo "I assume you finished editing now adding"
            fi
            git add -v "$2"
            git rm "$1"
            break
        done
    else
        echo "ok cool $1 == $2 only gits quirky merge fails here..."
        git rm "$1"
        git add -v "$2"
    fi
}

function trymoveandold() {
    if diff -u "$1" "$2" ; then
        echo "this is just a git fail, fixing"
        git rm "$1"
        git add -v "$2"
    elif diff -u "$3" "$2" ; then
        echo "this another kind of git fail, fixing"
        git rm "$1"
        git add -v "$2"
    else
        echo "use old script?"
        select a in yes no ; do
            if test x$a = xyes ; then
                cp -v "$1" "$2"
            elif test x$a = xno ; then
                echo "assuming you fixed it then"
            fi
            git add -v "$2"
            break
        done
    fi
}

function justmoveit() {
    mv -v "$1" "$2"
    git add -v "$2"
    git rm "$1"
}

if ! test -d "$1" ; then
    echo "$1 must be a lang-XXX dir"
    exit 1
fi
if ! test -d template-lang-und-move ; then
    echo you need to have the move only template at template-lang-und-move
    exit 1
fi
# start with a clean clone anyways and a backup...
if ! test -d "$BIGTEMP/$1" ; then
    mv -v "$1" "$BIGTEMP" || return 1
else
    rm -rfv "$1"  # dangerous lol
fi
git clone git@github.com:giellalt/"$1"


# obs! apply template for move only stuff
gut template apply -o giellalt -r "^$1" -t template-lang-und-move
pushd "$1" || exit 1
# build dirs
mkdir -v src/fst/test
mkdir -v src/fst/orthography/test
mkdir -v src/fst/morphology/test
mkdir -v src/fst/morphology/test/phonology/
mkdir -v src/cg3/test
mkdir -v tools/hyphenators/test
mkdir -v tools/mt/apertium/test
mkdir -v tools/spellcheckers/test/
# move existing potentially modified tests
git mv -v test/src/dict-gt-yamls src/fst/test/
# move makefiles and scripts with modifications intact
for f in test/src/run-gt*.sh test/src/run-dict*.sh test/src/run-lexc*.sh; do
    if ! git mv -v "$f" src/fst/test/ ; then
        difformove "$f" src/fst/test/"$(basename "$f")"
    fi
done
# move untemplated test runners
if compgen -G "test/src/run-*.sh" ; then
    for f in test/src/run-*.sh ; do
        if ! git mv -v "$f" src/fst/test/ ; then
            justmoveit "$f" src/fst/test/
        fi
    done
fi
if ! git mv -v test/src/Makefile.am src/fst/test/ ; then
    trymoveandold test/src/Makefile.am src/fst/test/Makefile.am \
        "$BIGTEMP/$1/test/src/Makefile.am"
fi
if ! git mv -v test/src/orthography/Makefile.am src/fst/orthography/test/ ; then
    trymoveandold test/src/orthography/Makefile.am \
        src/fst/orthography/test/Makefile.am \
        "$BIGTEMP/$1/test/src/orthography/Makefile.am"
fi
if ! git mv -v test/src/orthography/run-initcaps-genyaml-testcases.sh \
        src/fst/orthography/test/ ; then
    trymoveandold test/src/orthography/run-initcaps-genyaml-testcases.sh \
        src/fst/orthography/test/run-initcaps-genyaml-testcases.sh \
        "$BIGTEMP/$1/test/src/orthography/run-initcaps-genyaml-testcases.sh"
fi
# move yamls including untemplated ones
if compgen -G "test/src/orthography/*.yaml" ; then
    for f in test/src/orthography/* ; do
        if ! git mv -v "$f" src/fst/orthography/test/ ; then
            justmoveit "$f" src/fst/orthography/test/
        fi
    done
fi
for f in test/src/phonology/Makefile.am \
        test/src/phonology/pair-test-*.sh.in ; do\
    if ! git mv -v "$f" src/fst/morphology/test/phonology/ ; then
        trymoveandold "$f" src/fst/morphology/test/phonology/"$(basename "$f")"\
            "$BIGTEMP/$1/$f"
    fi
done
for f in test/src/morphology/generate*.sh.in test/src/morphology/Makefile.am \
        test/src/morphology/tag_test.sh ; do
    if ! git mv -v "$f" src/fst/morphology/test/ ; then
        trymoveandold "$f" src/fst/morphology/test/"$(basename "$f")" \
            "$BIGTEMP/$1/$f"
    fi
done
if compgen -G "test/src/morphology/*" ; then
    for f in test/src/morphology/* ; do
        if ! git mv -v "$f" test/src/morphology/ ; then
            justmoveit "$f" src/fst/morphology/test/
        fi
    done
fi
if ! git mv -v test/src/syntax/Makefile.am src/cg3/test/ ; then
    difformove test/src/syntax/Makefile.am src/cg3/test/Makefile.am
fi
if ! git mv -v test/tools/hyphenators/Makefile.am tools/hyphenators/test/ ; then
    difformove test/tools/hyphenators/Makefile.am tools/hyphenators/test/Makefile.am
fi
if ! git mv -v test/tools/hyphenators/* tools/hyphenators/test/ ; then
    for f in test/tools/hyphenators/* ; do
        difformove "$f" tools/hyphenators/test/"$(basename "$f")"
    done
fi
for f in test/tools/mt/apertium/Makefile.am \
        tools/mt/apertium/test/run-mt-gt-desc-anayaml-testcases.sh ; do
    if ! git mv -v "$f" tools/mt/apertium/test/ ; then
                trymoveandold "$f" tools/mt/apertium/test/"$(basename "$f")" \
                    "$BIGTEMP/$1/$f"
    fi
done
for f in test/tools/mt/apertium/*.yaml ; do
    if ! git mv -v "$f" tools/mt/apertium/test/ ; then
        justmoveit "$f" tools/mt/apertium/test/
    fi
done
if compgen -G "test/tools/mt/apertium/run-*" ; then
    for f in test/tools/mt/apertium/run-* ; do
        if ! git mv -v "$f" tools/mt/apertium/test/ ; then
            justmoveit "$f" tools/mt/apertium/test/"$(basename "$f")"
        fi
    done
fi

for f in test/tools/spellcheckers/Makefile.am \
        test/tools/spellcheckers/run-spellers-gt-norm-yaml-testcases.sh \
        test/tools/spellcheckers/test-zhfst-file.sh.in ; do
    if ! git mv -v "$f" tools/spellcheckers/test/ ; then
        trymoveandold "$f" tools/spellcheckers/test/"$(basename "$f")" \
            "$BIGTEMP/$1/$f"
    fi
done
if ! git mv -v test/tools/spellcheckers/fstbased/mobile/Makefile.am \
        tools/spellcheckers/test/fstbased/mobile/ ; then
    difformove test/tools/spellcheckers/fstbased/mobile/Makefile.am \
        tools/spellcheckers/test/fstbased/mobile/Makefile.am
fi
if ! git mv -v test/tools/spellcheckers/fstbased/desktop/Makefile.am \
        tools/spellcheckers/test/fstbased/desktop/ ; then
    difformove test/tools/spellcheckers/fstbased/desktop/Makefile.am \
        tools/spellcheckers/test/fstbased/desktop/Makefile.am
fi
if ! git mv -v test/tools/spellcheckers/fstbased/desktop/hfst/Makefile.am \
        tools/spellcheckers/test/fstbased/desktop/hfst/ ; then
    difformove test/tools/spellcheckers/fstbased/desktop/hfst/Makefile.am \
        tools/spellcheckers/test/fstbased/desktop/hfst/Makefile.am
fi
for f in test/tools/spellcheckers/fstbased/desktop/hfst/accept-all-lemmas.sh.in \
        test/tools/spellcheckers/fstbased/desktop/hfst/run-acceptor-yaml-testcases.sh \
        test/tools/spellcheckers/fstbased/desktop/hfst/test-zhfst-basic-sugg-speed.sh.in \
        ; do
    if ! git mv -v "$f" tools/spellcheckers/test/fstbased/desktop/hfst/ ; then
        trymoveandold "$f" tools/spellcheckers/test/fstbased/desktop/hfst/"$(basename "$f")" \
            "$BIGTEMP/$1/$f"
    fi
done
for d in test/tools/spellcheckers/fstbased/desktop/hfst/*yamls ; do
    if ! git mv -v "$d" tools/spellcheckers/test/fstbased/desktop/hfst/ ; then
        justmoveit "$d" tools/spellcheckers/test/fstbased/desktop/hfst/
    fi
done
for f in test/tools/spellcheckers/fstbased/Makefile.am \
        test/tools/spellcheckers/fstbased/run-fstspeller-gt-norm-yaml-testcases.sh \
        ; do
    if ! git mv -v "$f" tools/spellcheckers/test/fstbased/ ; then
        difformove "$f" tools/spellcheckers/test/fstbased/"$(basename "$f")"
    fi
done
for d in test/tools/spellcheckers/fstbased/*yamls ; do
    if ! git mv -v "$d" tools/spellcheckers/test/fstbased/ ; then
        justmoveit "$d" tools/spellcheckers/test/fstbased/
    fi
done
for d in test/tools/spellcheckers/*yamls ; do
    if ! git mv -v "$d" tools/spellcheckers/test/ ; then
        justmoveit "$d" tools/spellcheckers/test/
    fi
done
if compgen -G "test/tools/spellcheckers/run-*" ; then
    for f in test/tools/spellcheckers/run-* ; do
        if ! git mv -v "$f" tools/spellcheckers/test/ ; then
            justmoveit "$f" tools/spellcheckers/test/"$(basename "$f")"
        fi
    done
fi
if compgen -G "test/*-yamls" ; then
    for f in test/*-yamls ; do
        if ! git mv -v "$f" src/fst/orthography/test/ ; then
            justmoveit "$f" src/fst/orthography/test/
        fi
    done
fi
# remove orphaned makefiles already
git rm test/tools/mt/Makefile.am
git rm test/tools/Makefile.am
# try to apply changes now
popd || exit 1
gut commit -o giellalt -r "^$1$" -m "[Template merge] test/ reorg moves"
gut template apply --continue -o giellalt -r "^$1$" -t template-lang-und-move
gut pull -o giellalt -r "^$1$"
if grep -F 'rev_id = 177' "$1/.gut/delta.toml"; then
    pushd "$1" || exit 1
    sed -i -e 's/rev_id = 177/rev_id = 178/' .gut/delta.toml
    sed -i -e 's/8f801491bbbdb21a1f61364166c77fb33bd4a1f0/0e977ab51a115099656def83b47120d28edcd023/' .gut/delta.toml
    git commit .gut/delta.toml -m "Apply changes 178 manually"
    popd || exit 1
fi
#
# onto actual changes
gut template apply -o giellalt -r "^$1$" -t template-lang-und
pushd "$1" || exit 1
if test -n "$(find . -name '*.rej' -o -name '*.orig')" ; then
    echo fix these
    find . -name '*.rej' -o -name '*.orig'
    echo "then say 'find . -name '*.rej' -delete , -name '*.orig' -delete'"
    echo "now open another terminal to fix all that mess -_-"
fi
popd || exit 1
echo last chance to fix everything before last template finish
select a in yes no ; do
    if test x$a = xno ; then
        echo lol
    fi
    break
done
gut commit -o giellalt -r "^$1$" -m "[Template merge] test/ reorg scripts"
gut template apply --continue -o giellalt -r "^$1$" -t template-lang-und
gut pull -o giellalt -r "^$1$"
if grep -F 'rev_id = 178' "$1/.gut/delta.toml" ; then
    pushd "$1" || exit 1
    sed -i -e 's/rev_id = 178/rev_id = 179/' .gut/delta.toml
    sed -i -e 's/template_sha = .*/template_sha = "d9ea42c496cabf88545adf0ae1d6997de4f841a6"/' .gut/delta.toml
    git commit .gut/delta.toml -m "Apply changes 179 manually"
    popd || exit 1
fi
echo "don't forget you have a  backup in $BIGTEMP/$1...!"
