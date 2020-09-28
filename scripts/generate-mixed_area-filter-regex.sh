#!/bin/bash

# Create a filter regex to remove all strings containing two or more different
# area tags.

if ! test $# -eq 2 ; then
    echo
    echo "Usage: $0 OUTFILE ALL_AREA_TAGS"
    echo
    echo "OUTFILE       = regex file to be created"
    echo "ALL_AREA_TAGS = a list of tags for all areas"
    echo
    exit 1
fi

REGEXFILE=$1
ALLAREAS=$2
SED=sed

# Print header text:
echo "# This is a generated file - do not edit!"        > $REGEXFILE
echo "# It removes area-marked strings with multiple"  >> $REGEXFILE
echo "# and mixed area tagging, by way of the U flag"  >> $REGEXFILE
echo "# diacritic. The regex requires that it is"      >> $REGEXFILE
echo "# followed by the fst operation 'twosided "      >> $REGEXFILE
echo "# flag-diacritics'. Thus the filtering does not" >> $REGEXFILE
echo "# work with Xerox' xfst (it crashes due to a"    >> $REGEXFILE
echo "# bug)."                                         >> $REGEXFILE
echo ""                                                >> $REGEXFILE
echo ""                                                >> $REGEXFILE

# Print the actual regular expression:
for AREA in $ALLAREAS; do
	echo "\"+Area/$AREA\" \"@U.Area.$AREA@\" <- \"+Area/$AREA\"," >> $REGEXFILE

	# In case of negative area definitions, we need to loop over the other
	# areas, and make regexes of the type: Area/-NO -> U.Area.SE etc:

	# First, get all the other areas but the one in focus, and make it an array:
	NON_TARGET_AREA_STRING=$(echo "$ALLAREAS" | tr ' ' '\n' | grep -v $AREA | tr '\n' ' ')
	# Cf https://stackoverflow.com/questions/10586153/split-string-into-an-array-in-bash
	IFS=' ' read -r -a NON_TARGET_AREA_ARRAY <<< "$NON_TARGET_AREA_STRING"

	# Print initial '[' for the following list of other areas:
	printf "[ " >> $REGEXFILE
	# Then loop over all but the last one in the array:
	# Cf https://stackoverflow.com/questions/12298261/how-to-know-if-file-in-a-loop-is-the-last-one
	# (the second answer)
	for OTHER_AREA in "${NON_TARGET_AREA_ARRAY[@]::${#NON_TARGET_AREA_ARRAY[@]}-1}"; do
		printf "\"+Area/-$AREA\" \"@U.Area.$OTHER_AREA@\" | " >> $REGEXFILE
	done
	# Finally, print the regex for the last area - must end in ']':
	printf "\"+Area/-$AREA\" \"@U.Area.${NON_TARGET_AREA_ARRAY[@]: -1:1}@\" ] " >> $REGEXFILE
	# ... and then close off with the negated area in focus:
	echo "<- \"+Area/-$AREA\"," >> $REGEXFILE
done

# Replace the last comma with a semicolon, on all platforms (sed -i is not reliable):
# (-0 sets the record separator, anything -0400 will cause the whole file to be slurped
# up, by convention -0777 is used, see
# https://unix.stackexchange.com/questions/192485/how-exactly-does-perls-0-option-work
# for the full story. See
# https://stackoverflow.com/questions/15909031/replace-last-character-in-a-large-file
# for the actual solution, which is pretty simple)
perl -0777 -pi -e 's/,$/;/' $REGEXFILE
