#!/bin/bash

#set -x # this's neat debug stuff

if test -z "${GTCORE}" ; then
    echo "Unable to determine GTCORE, re-run gtsetup.sh and re-try"
    exit 1
fi

if test -z "${GTHOME}" ; then
    echo "Unable to determine GTHOME, re-run gtsetup.sh and re-try"
    exit 1
fi

function print_usage() {
    echo "Usage: $0 [OPTIONS...]"
    echo "Merges templates from giella-templates to current working dir"
    echo
    echo "  -h, --help                 print this usage info"
    echo "  --unsafe                   also try to merge unsafe mergables"
    echo "  -r, --revision REV         start merging from REV instead of timestamp's"
    echo "  -t, --template TPL         Only select TPL templates (bash glob)"
    echo "  -c, --templatecoll TPLCOLL Only select templates from TPLCOLL (bash glob)"
    echo "  -u, --username USER        Use username USER for the svn interaction"
    echo
}

SED=$(which sed 2>&1)
if grep -q 'no sed in' <<<$SED; then
	SED=
fi

# Prefer gnu sed if found:
GSED=$(which gsed 2>&1)
if ! grep -q 'no gsed in' <<<$GSED; then
	if ! test "x$GSED" == "x"; then
		SED=$GSED
	fi
fi

if test "x$SED" == "x"; then
    echo "Required tools sed or gsed not found, aborting."
    exit 1
fi

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
                forcerev=$(echo $1 | $SED -e 's/.*=//')
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
                tpl=$(echo $1 | $SED -e 's/.*=//')
            fi
        else
            tpl="$2"
            shift
        fi
    elif test x$1 = x--username -o x$1 = x-u ; then
        if test -z $2 ; then
            if ! echo $1 | fgrep = ; then
                echo "$1 requires user names"
                print_usage
                exit 1
            else
                user=$(echo $1 | $SED -e 's/.*=//')
            fi
        else
            user="$2"
            shift
        fi
    elif test x$1 = x--templatecoll -o x$1 = x-c ; then
        if test -z $2 ; then
            if ! echo $1 | fgrep = ; then
                echo "$1 requires template names"
                print_usage
                exit 1
            else
                tplcoll=$(echo $1 | $SED -e 's/.*=//')
            fi
        else
            tplcoll="$2"
            shift
        fi
    else
        echo "$0: unknown option $1"
        print_usage
        exit 1
    fi
    shift
done

username=""
if test "x$user" != "x"; then
  username="$user@"
fi

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

# Identify language:
CURLANG=$(fgrep 'AC_SUBST([GTLANG]' configure.ac \
		  | cut -d',' -f2 | cut -d'[' -f2 | cut -d']' -f1)
CUR2LANG=$( ${GTCORE}/scripts/iso3-to-2.sh $CURLANG )

# Identify template collection name from parent directory or from option:
if test "x$tplcoll" = "x" ; then
    CURTOPDIR=$(basename $(dirname $(pwd)))
else
    CURTOPDIR=$tplcoll
fi

# Get the list of available template collections:
availableTemplateColls=$(for t in \
            $GTHOME/giella-templates/*-templates; do n=$(basename $t); \
                        n2=${n%-templates}; echo "$n2"; done)

availableTemplateCollsAsList=$(echo $availableTemplateColls | tr ' ' '|')

# Check if the current directory name matches one of the template collection
# names by counting the matches (it should be 1 if it matches, 0 if not);
# if the test fails (i.e. we are in the wrong directory), write a message and
# exit:
if test $(echo "$availableTemplateColls" \
          | grep -c "^$CURTOPDIR\$" ) -eq 0 ; then
    echo "The parent directory is not named as one of the following:"
    echo
    echo "$availableTemplateColls"
    echo
    echo "You need to specify the appropriate template collection using the"
    echo "following option with one of the listed values:"
    echo
    echo "$0 --templatecoll [$availableTemplateCollsAsList]"
    exit 1
fi

TEMPLATEDIR=${CURTOPDIR}-templates
SVNMERGE_OPTIONS="--ignore-ancestry --accept postpone"
SVNREPOROOT="https://${username}gtsvn.uit.no/langtech"

for macrolangdir in ${GTHOME}/giella-templates/${TEMPLATEDIR}/${tpl} ; do
    macrolang=${macrolangdir#${GTHOME}/giella-templates/${TEMPLATEDIR}/}
    if test ! -r ${macrolang}.timestamp ; then
        # this is a macro language that has not been subscribed
        echo "Not merging ${macrolang} because ${CURLANG} is not in that set"
        continue
    fi
    if test -z ${forcerev} ; then
        # assume we are merging from the revision of timestamp to today
        macrolangrev=$(LC_ALL=C svn info ${macrolang}.timestamp \
            | fgrep 'Last Changed Rev' | $SED -e 's/Last Changed Rev: //')
        if test -z $macrolangrev ; then
            echo could not find revision of ${macrolang}.timestamp
            continue
        fi
        echo "Revision of ${macrolang}.timestamp is: $macrolangrev (merging all newer revisions)"
    else
        macrolangrev=${forcerev}
        echo "Merging from explicit version: $macrolangrev to HEAD"
    fi

    for f in $(svn diff -r${macrolangrev}:HEAD --summarize \
            ${SVNREPOROOT}/trunk/giella-templates/${TEMPLATEDIR}/${macrolang}/ \
            | awk '{print $2}' ) ; do
        localf_tmp=./${f#$SVNREPOROOT*${TEMPLATEDIR}/${macrolang}/}
        # Replace __UND__ in local filenames, so that merging can be done:
        localf=$( echo $localf_tmp | $SED -e "s/__UND__/$CURLANG/g" \
                                          -e "s/__UND2C__/$CUR2LANG/g" )
        if test ! -r ${localf} ; then
            svn cp ${f} ${localf}
        elif test -d ${localf} ; then
            if test x$unsafe = xunsafe ; then
                svn merge -r${macrolangrev}:HEAD \
                            ${f} ${localf} $SVNMERGE_OPTIONS
            else
                echo DIR ${localf} >> ${unmerged}
            fi
        else
            case ${f} in
                *.am | *.m4 | *.sh | *.sh.in | *configure.ac | *README)
                    svn merge -r${macrolangrev}:HEAD \
                                ${f} ${localf} $SVNMERGE_OPTIONS
                    ;;
                *.lexc | *.twolc | *.regex | *.xfstscript )
                    if test x$unsafe = xunsafe ; then
                        svn merge -r${macrolangrev}:HEAD \
                                    ${f} ${localf} $SVNMERGE_OPTIONS
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
                        svn merge -r${macrolangrev}:HEAD \
                                    ${f} ${localf} $SVNMERGE_OPTIONS
                    else
                        echo UNKNOWN_FILE ${localf} >> ${unmerged};
                    fi;
                    ;;
            esac
        fi

        # Replace placeholder language code with real language code in newly
        # added files:
        ${GTCORE}/scripts/replace-dummy-langcode.sh . $CURLANG langs ${localf}

    done

    # Make sure we know we have updated the templated files:
    # use plain cp until we have svn DIR merge in place:
    cp -v -f ${GTHOME}/giella-templates/${TEMPLATEDIR}/${macrolang}/${macrolang}.timestamp \
    		 ${macrolang}.timestamp
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

        The updates to the template(s) have been merged and the timestamp(s)
        updated. Do not forget to commit merged files along with the new
        ${macrolang}.timestamp

EOF
    fi

    if test x$unsafe != xunsafe ; then
        rm -f ${unmerged}
    fi
done

# Remove .tmp file if empty:
if test ! -s ${unmerged} ; then
    rm -f ${unmerged}
fi
