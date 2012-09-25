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
# iso3-to-2.sh $1
#
# $1 - the three-letter code we want the two-letter variant for

# Wrong usage - short instruction:
if ! test $# -eq 1 ; then
    echo "Usage: $0 ISO-639-3_LANGUAGE_CODE"
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

# Check that we get clean input - it must be three characters long:
len=${#1}
if [[ "$len" -ne 3 ]]
then
	echo "Bad input! ISO 639-2 and -3 codes must be three chars: $1" 1>&2
	exit 3
fi

# Get the line containing the codes we are after.
# We tail and cut before we grep, to ensure we don't get spurious matches
# on column headers and language names:
isocodes=`tail -n +2 "$codefile" | cut -f1,4 | grep "$1" `

len=${#isocodes}
if [[ "$len" -eq 0 ]]
then
	echo "No such language code found! $1" 1>&2
	exit 4
fi

# Get each individual code:
threecode=`echo "$isocodes" | cut -f1`
twocode=`echo "$isocodes" | cut -f2`

if [ "$twocode" != "" ]
then
	echo "$twocode"
else
	echo "$threecode"
fi
