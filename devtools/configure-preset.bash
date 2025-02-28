#!/bin/bash
# some aliases for configuratios that I got bored hunting and copypasting

if test $# != 1 ; then
    echo "Usage: $0 PRESET-NAME"
    echo
    echo "PRESET-NAME is a name of configuration option set, one of:"
    echo "  - docsygen, docs, ...: configure used by github action docsygen"
    echo "  - analysers,      ...: configure used in analysers build action"
    echo "  - grammar, gramch,...: configure used in gramchk build action"
    echo "  - speller, spell, ...: configure used in speller build action"
    echo "  - tino, apertium, ...: configure used in apertium.projectjj logs"
    echo "  - anything else will be used as a configure arguments"
    exit 1
fi

case $1 in
    tino|apertium) ./configure --enable-tokenisers --enable-fst-hyphenator\
        --without-xfst --enable-spellers --enable-hfst-mobile-speller\
        --enable-alignment --disable-minimised-spellers --enable-syntax\
        --enable-analysers --enable-generators --enable-apertium\
        --enable-grammarchecker --enable-dicts --enable-oahpa\
        --enable-morpher --disable-hfst-desktop-spellers;;
    docs*) ./configure --without-forrest --disable-silent-rules\
        --without-xfst --disable-analysers --disable-generators\
        --disable-transcriptors --enable-reversed-intersect ;;
    analyse*) ./configure --without-forrest --disable-silent-rules\
        --without-xfst --enable-reversed-intersect;;
    spell*) ./configure --without-forrest --disable-silent-rules\
        --without-xfst --disable-analysers --disable-generators\
        --disable-transcriptors --enable-spellers\
        --disable-hfst-desktop-spellers --enable-hfst-mobile-speller\
        --enable-reversed-intersect;;
    grammar*|gramchk) ./configure --without-forrest --disable-silent-rules\
        --without-xfst --disable-analysers --disable-generators\
        --disable-transcriptors --enable-spellers\
        --disable-hfst-desktop-spellers --enable-hfst-mobile-speller\
        --enable-grammarchecker --enable-reversed-intersect;;
    *) ./configure "$@";;
esac
