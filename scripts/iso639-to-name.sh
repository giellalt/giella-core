#!/bin/bash
#
# A simple shell script to return the two-letter ISO 639 code for a three letter
# code. If no two-letter code is available, it returns the three-letter code
# given in the input. The code data is taken from a table of ISO 639-3 codes.
# Code source: http://www.sil.org/iso639-3/iso-639-3_20110525.tab
# Code homepage: http://www.sil.org/iso639-3/download.asp
#
# Calling convention:
#
# iso639-to-name.sh $1
#
# $1 - the ISO 639 code we want the natural language name for

# Wrong usage - short instruction:
if ! test $# -eq 1 ; then
    echo "Usage: $0 ISO-639_LANGUAGE_CODE"
    echo "       Both 2 and 3 letter codes are ok."
    exit 1
fi

# The location of the script dir:
scriptdir="$( cd -P "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# The name of the file with ISO codes
codefilename="iso-639-3.txt"

# The ISO code file is located in the same dir as the script,
# and does not change - no need for the filename as a parameter:
codefile=$scriptdir/$codefilename

# Check whether the file exists:
if [[ ! -e "$codefile" ]]
then
	echo "ISO 639-3 code file not found! $codefile" 1>&2
	exit 2
fi

# Check that we get clean input - it must be two or three characters long:
len=${#1}
if [[ "$len" -eq 2 ]]
then
	# Get the line containing the codes we are after.
	# We tail and cut before we grep, to ensure we don't get spurious matches
	# on column headers and language names:
	iso1codes=`tail -n +2 "$codefile" | cut -f4,7 | grep "^$1" `
elif  [[ "$len" -eq 3 ]]
then
	iso2codes=`tail -n +2 "$codefile" | cut -f2,7 | grep "^$1" `
	iso3codes=`tail -n +2 "$codefile" | cut -f1,7 | grep "^$1" `
else
	echo "Bad input! ISO 639 language codes must be two or three chars: $1" 1>&2
	exit 3
fi

len3=${#iso3codes}
len2=${#iso2codes}
len1=${#iso1codes}

if [[ "$len3" -ne 0 ]]
then
	# Get the name:
	isoname=`echo "$iso3codes" | cut -f2`
elif [[ "$len2" -ne 0 ]]
then
	# Get the name:
	isoname=`echo "$iso2codes" | cut -f2`
elif [[ "$len1" -ne 0 ]]
then
	# Get the name:
	isoname=`echo "$iso1codes" | cut -f2`
else
	echo "No such language code found! $1" 1>&2
	exit 4
fi

if [ "$isoname" == "" ]
then
	echo "No name for the language code: $1" 1>&2
	exit 5
else
	echo "$isoname"
fi
exit 0
