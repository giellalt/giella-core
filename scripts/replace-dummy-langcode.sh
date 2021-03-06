#!/bin/bash

# Replace placeholder language code with real language code

# Wrong usage - short instruction:
if ! test $# -eq 2 -o $# -eq 3 ; then
    echo
    echo "Usage: $0 DIR ISO3CODE [FILNAME]"
    echo
    echo "Replaces all occurrences of dummy language codes in files and"
    echo "filenames within DIR with real language codes and name."
    echo "Optionally specify a filename to do the replacements in."
    echo
    exit 1
fi

SED=sed

# Prefer gnu sed if found:
GSED=$(which gsed)
if test ! -z $GSED; then
	SED=$GSED
fi

if test x$SED == "x"; then
    echo "Required tools sed or gsed not found, aborting."
    exit 1
fi

langcode=$2
hyphenedcode=$(echo "${langcode}" | grep '[_-]' - )

if test "x${hyphenedcode}" != "x" ; then
    langcode=$( echo "${langcode}" | tr '_' '-' | cut -d'-' -f1 )
fi

# Get the 2-char language code from the 3-char code:
iso2code=$(${GTCORE}/scripts/iso3-to-2.sh $langcode)
if [[ $? -gt 0 ]] ; then
	echo "ISO 639 3-to-2 char conversion had an error!" 1>&2
	exit 2
fi

# Get the language name from the 3-char code:
isoName=$(${GTCORE}/scripts/iso639-to-name.sh $langcode)
if [[ $? -gt 0 ]] ; then
	echo "ISO 639 language name identification had an error!" 1>&2
	exit 3
fi

file=$3

# Replace placeholder language code with real language code
# In either a single file:
if test "x$file" != "x"; then
	if test -e $file -a ! -d $file ; then
	    cp $file $file~
	    $SED -e "s/__UND__/$2/g" \
	    	 -e "s/__UND2C__/$iso2code/g" \
	    	 -e "s/__UNDEFINED__/$isoName/g" \
	    	< $file~ > $file
	    rm -f $file~
	else
		echo "File not found"
		exit 1
	fi
else
# ... or in all files in a given dir
# (but don't touch .svn files and the und.timestamp file):
	for f in $(find $1 \
				-not -wholename '*.svn*' \
				-not -wholename '*.git*' \
				-not -wholename '*autom4te.cache*' \
				-not -wholename '*build*' \
				-not -wholename '*deps*' \
				-not -wholename '*.bundle*' \
				-not -wholename '*.xcodeproj*' \
				-not -wholename '*.xcassets*' \
				-not -wholename '*Generated*' \
				-not -wholename '*HostingApp*' \
				-not -wholename '*Keyboard*' \
				-not -wholename '*hfst-ospell*' \
				-not -wholename '*libarchive*' \
				-not -wholename '*/xz/*' \
				-not -name '.DS_Store' \
				-not -name 'und.timestamp' \
				-not -name 'aclocal.m4' \
				-not -name 'autogen.sh' \
				-not -name 'configure' \
				-not -name 'Makefile.in' \
				-not -name 'Makefile' \
				-not -name '*~' \
				-not -name '*.xfst' \
				-not -name '*.hfst' \
				-not -name '*.hfstol' \
				-not -name '*.png' \
				-not -name '*.pdf' \
				-not -name '*.swift' \
				-not -name '*.h' \
				-not -name '*.xib' \
				-not -name '*.plist' \
				-not -name '*.cpp' \
				-not -name '*.m' \
				-type f) ; do
	    # In file content:
	    cp $f $f~
	    $SED -e "s/__UND__/$2/g" \
	    	 -e "s/__UND2C__/$iso2code/g" \
	    	 -e "s/__UNDEFINED__/$isoName/g" \
	    	< $f~ > $f
	    rm -f $f~
	    # And do the same with filenames:
	    dir=$(dirname $f)
	    undfilename=$(basename $f)
	    newfilename=$(echo $undfilename | $SED -e "s/und/$2/")
	    newfile=$(echo $dir/$newfilename)
	    if test ! $f = $newfile ; then
	        # Only process files starting with 'und' followed by punctuation:
	        if [ $(echo $f | grep -c '^und[.-]') -ne 0 ] ; then
	            # Check whether the file is already known to svn:
	            if [ $(svn st $f | grep -c '^\?') -eq 0 ] ; then
	                svn mv $f $newfile
	            else
	                mv $f $newfile
	            fi
	        fi
	    fi
	done
fi

exit 0
