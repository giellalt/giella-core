# This is a simple helper shell script to be included by every yaml test runner.

# Find relative path from test script to test runner:
relpath=.
maintestrunner=run-morph-tester.sh
helpertestrunner=run-yaml-testcases.sh

# We use the maintestrunner to find the relative path, because it will be in
# the path of the build tree - the helpertestrunner will only be in the path
# of the source tree, and will not be found if using VPATH building.
while test ! -x $relpath/$maintestrunner ; do
    relpath="$relpath/.."                        # if not found, go one level up
#   echo relpath: $relpath                       # debug
    if test "$(cd $relpath && pwd)" = "/" ; then # have we reached the root?
        echo "$0: No test runner found!"
        exit 77
    fi
done

testrunner="$srcdir/$relpath/$helpertestrunner"

source $testrunner $transducer $yaml_file_subdir $halftest
