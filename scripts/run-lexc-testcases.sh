#!/bin/bash

# This is a shell script that will call the morph-tester test runner with the
# specified transducer for each lexc file and for each transducer specified in
# the test cases.

if ! test $# = 2 ; then
    echo "Usage: $0 TRANSDUCER SRCDIR FSTLIB"
    echo
    echo "  SRCDIR       root path to lexc files"
    echo "  FSTLIB       hfst, xfst or foma to use"
    exit 2
fi

srcdir=$1
TESTKITS=$2

if test -z "$GIELLA_CORE" ; then
    echo "GIELLA_CORE= must point to giella-core"
    exit 2
fi

###### Variables: #######
Fail=0
Tests_found=no
Skipped=yes
testtype=full
concat_lexc_file="lexicon.lexc"
alt_concat_file="lexicon.tmp.lexc"

relpath=$GIELLA_CORE/scripts/
testrunner=run-morph-tester.sh
. "$relpath/termcolors.bash"

if ! test -x "$relpath/$testrunner" ; then
    printf "%s%s%s: No test runner found in %s/%s!\n" "$red" "$0" "$reset" \
        "$relpath" "$testrunner"
    exit 77
fi

# Get list of source files:
source_files="$(find "${srcdir}"/../ -name '*.lexc' \
                -not -name "$concat_lexc_file" -not -name "$alt_concat_file" )"

# One empty line in the beginning:
echo ""

# Loop over all lexc source files:
for file in ${source_files}; do
    fileshort="$(basename \ "$(dirname "$file")")/$(basename "$file")"

    # For each lexc file, extract all fst's specified in it:
    fsts=$(grep '^!!€[^ :]' "$file" | cut -d':' -f1 \
        | sed 's/\(.*\)€\(.*\)/\2/g' | sort -u)

    # Check whether there are test cases in the file:
    tests=$(grep '^!!€ ' "$file")

    # If no tests or fst's are found, skip the file:
    if test "$fsts" == "" -a "$tests" == ""; then
        if test "$Tests_found" == "no" ; then
          Skipped=yes
        fi
        printf "%sSKIPPED%s: no tests in %s\n" "$light_blue" "$reset" "$fileshort"

    # If there are tests, but no specified fst, skip (future: run default fst)
    elif test "$fsts" == "" -a ! "$tests" == ""; then
#           (( i += 1 ))
#       echo "$file has tests, but no fst specified - defaulting to $transducer"
#       source ./run-yaml-testcases.sh $transducer $file
        printf "* %sWARNING%s: %s has tests, but no fst specified - %sSKIPPED%s\n"\
            "$red" "$reset" "$fileshort" "$light_blue" "$reset"
        Skipped=yes
    # For each specified fst in the lexc file, run those tests:
    else
#       echo "TESTING: found tests in $fileshort" # debug

        Tests_found=yes

        for fst in $fsts; do
            (( i += 1 ))
            echo "Running $fst tests:"
            # Empty line before each new fst:
            echo
            leadtext="LEXC test $i: "

            # Check for possible one-sided tests (default is two-sided/full):
            if [[ "$fst" == *.gen ]]; then
              testtype="gen"
              fst=$(basename "$fst" .gen)
            elif [[ "$fst" == *.ana ]] ; then
              testtype="ana"
              fst=$(basename "$fst" .ana)
            fi

            # Run the actual tests for the given fst:
            for tk in $TESTKITS ; do
                "$relpath"/run-morph-tester.sh \
                    "$fst" "$file" "$relpath" "$testtype" all "$srcdir" "$tk" "$leadtext"
                rv=$?
                if test $rv = 77 ; then
                    printf "%sskipped%s" "$light_blue" "$reset"
                    Skipped=yes
                elif test $rv -ge 1 ; then
                    (( Fail += 1 ))
                    Skipped=no
                else
                    Skipped=no
                fi
            done
#           echo "The $fst testing is done using $testtype testing."    # debug

            # Reset testtype to default:
            testtype=full
        done
    fi
done


if test "$Skipped" == "yes" ; then
    exit 77
fi

# At least one of the Xerox or HFST tests failed:
if test "$Fail" -ge 1; then
    exit 1
fi

# Skip if no transducer were found - failing is problematic for lexc tests:
if test "$Tests_found" = 0 ; then
    echo "No lexcy tests found"
    exit 77
fi

