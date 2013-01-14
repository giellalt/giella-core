#!/bin/bash

#set -x # this's neat debug stuff

if test -z "${GTCORE}" ; then
    echo "Unable to determine GTCORE, re-run gtsetup.sh and re-try"
    exit 1
fi

function print_usage() {
    echo "Usage: $0 [OPTIONS...]"
    echo "Merges templates from gtcore to current working dir"
    echo
    echo "  -h, --help           print this usage info"
    echo "  --unsafe             also try to merge unsafe mergables"
    echo "  -r, --revision=REV   start merging from REV instead of timestamp's"
    echo "  -t, --template=TPL   Only select TPL templates (bash glob)"
    echo
}

# option variables
unsafe=""
forcerev=""
tpl="*"

# manual getopt loop... Mac OS X does not have good getopt
while test $# -ge 1 ; do
    if test x$1 = x--unsafe ; then
        unsafe=unsafe
    elif test x$1 = x--help -o x$1 = x-h ; then
        print_usage
        exit 0
    elif test x$1 = x--revision -o x$1 = x-r ; then
        if test -z $2 ; then
            if ! echo $1 | fgrep = ; then
                echo "$1 requires SVN version identifier"
                print_usage
                exit 1
            else
                forcerev=$(echo $1 | sed -e 's/.*=//')
            fi
        else
            forcerev="$2"
            shift
        fi
    elif test x$1 = x--template -o x$1 = x-t ; then
        if test -z $2 ; then
            if ! echo $1 | fgrep = ; then
                echo "$1 requires template names"
                print_usage
                exit 1
            else
                tpl=$(echo $1 | sed -e 's/.*=//')
            fi
        else
            tpl="$2"
        fi
    else
        echo "$0: unknown option $1"
        print_usage
        exit 1
    fi
    shift
done

unmerged=.tmp.unsafe.unmerged
if test x$unsafe != xunsafe ; then
    if test -f ${unmerged} ; then
        rm -f ${unmerged}
    fi
    touch ${unmerged}
fi

# require und for all languages
if test ! -r und.timestamp ; then
    echo "This script must be run from the top-level language directory;"
    echo "e.g. ${GTHOME}/langs/fao/"
    exit 1
fi

CURLANG=$(pwd | rev | cut -d'/' -f1 | rev)
SVNMERGE_OPTIONS="--ignore-ancestry --accept postpone"

for macrolangdir in ${GTCORE}/templates/${tpl} ; do
    macrolang=${macrolangdir#${GTCORE}/templates/}
    if test ! -r ${macrolang}.timestamp ; then
        # this is a macro language that has not been subscribed
        echo "Not merging ${macrolang} because ${CURLANG} is not in that set"
        continue
    fi
    if test -z ${forcerev} ; then
        # assume we are merging from the revision of timestamp to today
        macrolangrev=$(LC_ALL=C svn info ${macrolang}.timestamp | fgrep 'Last Changed Rev' | sed -e 's/Last Changed Rev: //')
        if test -z $macrolangrev ; then
            echo could not find revision of ${macrolang}.timestamp
            continue
        fi
        echo "Revision of ${macrolang}.timestamp is: $macrolangrev (merging all newer revisions)"
    else
        macrolangrev=${forcerev}
        echo "Merging from explicit version: $macrolangrev to HEAD"
    fi

    for f in $(svn diff -r${macrolangrev}:HEAD --summarize ${GTCORE}/templates/${macrolang}/ | awk '{print $2}' ) ; do
        localf=./${f#$GTCORE*templates/${macrolang}/}
        if test ! -r ${localf} ; then
            svn cp ${f} ${localf}
        elif test -d ${localf} ; then
            if test x$unsafe = xunsafe ; then
                svn merge -r${macrolangrev}:HEAD ${f} ${localf} $SVNMERGE_OPTIONS
            else
                echo DIR ${localf} >> ${unmerged}
            fi
        else
            case ${f} in
                *.am | *.m4 | *configure.ac | *autogen.sh | *README )
                    svn merge -r${macrolangrev}:HEAD ${f} ${localf} $SVNMERGE_OPTIONS
                    ;;
                *.lexc | *.twolc | *.regex | *.xfstscript )
                    if test x$unsafe = xunsafe ; then
                        svn merge -r${macrolangrev}:HEAD ${f} ${localf} $SVNMERGE_OPTIONS
                    else
                        echo UNSAFE_FILE ${localf} >> ${unmerged};
                    fi;
                    ;;
                *.timestamp)
                    # ignoring timestamps, they are to be handled manually by
                    # this script?
                    ;;
                *)
                    if test x${unsafe} = xunsafe ; then
                        svn merge -r${macrolangrev}:HEAD ${f} ${localf} $SVNMERGE_OPTIONS
                    else
                        echo UNKNOWN_FILE ${localf} >> ${unmerged};
                    fi;
                    ;;
            esac
        fi
    done

    # Replace placeholder language code with real language code in newly added files:
    ${GTCORE}/scripts/replace-dummy-langcode.sh . $CURLANG

    # Make sure we know we have updated the templated files:
    # use plain cp until we have svn DIR merge in place:
    cp -v -f ${GTCORE}/templates/${macrolang}/${macrolang}.timestamp ${macrolang}.timestamp
    if test -s ${unmerged} ; then
        echo There were files that are not safe to merge:
        cat ${unmerged}
        echo To merge above files as well, do:
        echo "  (svn revert --depth infinity *)"
        echo   $0 --unsafe
        echo
        echo The timestamp file ${macrolang}.timestamp has been updated as well.
        echo
        echo If you commit the merge, the unsafe changes will be discarded.
        echo Review the local changes, and do 'svn revert' on the files you
        echo want to restore to the previous state, or 'svn revert .' to
        echo undo the whole merge.
    else
        cat<<EOF

        The updates to templates have been merged and the timestamp updated.
        Do not forget to commit merged files along with new ${macrolang}.timestamp

EOF
    fi

    if test x$unsafe != xunsafe ; then
        rm -f ${unmerged}
    fi
done
