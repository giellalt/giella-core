#!/bin/bash

# For debugging, uncomment this command:
# set -x

function print_usage() {
    echo "Usage: $0 INPUTDIR VARNAME [--label LABEL]"
    echo "Build version.json for INPUTDIR (language root dir)"
    echo
    echo "  VARNAME                 Version variable name (e.g., FST, SPELLER, GRAMCHECK)"
    echo "  -h, --help              Print this usage info"
    echo "  -l, --label LABEL       Badge label (default: derived from VARNAME)"
    echo
    echo "Examples:"
    echo "  $0 /path/to/lang-sme FST"
    echo "  $0 /path/to/lang-sme SPELLER --label 'Speller version'"
    echo
}

# Default values
label=""

# Wrong usage - short instruction:
if (( $# < 2 )) ; then
    print_usage
    exit 1
fi

# First positional argument is the input directory
inputdir="$1"
shift

# Second positional argument is the variable name
varname="$1"
shift

# manual getopt loop... Mac OS X does not have good getopt
while test $# -ge 1 ; do
    if test x$1 = x--help -o x$1 = x-h ; then
        print_usage
        exit 0
    elif test x$1 = x--label -o x$1 = x-l ; then
        label=$2
        shift
    else
        echo "$0: unknown option $1"
        print_usage
        exit 1
    fi
    shift
done

# Set default label if not provided
if test -z "$label" ; then
    case "$varname" in
        FST)
            label="FST version"
            ;;
        SPELLER)
            label="Speller version"
            ;;
        GRAMCHECK)
            label="GramCheck version"
            ;;
        *)
            label="${varname} version"
            ;;
    esac
fi

# Check if configure.ac exists
if test ! -f "$inputdir/configure.ac" ; then
    echo "$0: Error: configure.ac not found in $inputdir" >&2
    colour=grey
    message="N/A"
else
    # Extract version based on variable name
    if test "$varname" = "FST" ; then
        # Extract version from AC_INIT in configure.ac
        # AC_INIT([Giella sme], [0.2.0], ...)
        version=$(grep "^AC_INIT" "$inputdir/configure.ac" | sed 's/^AC_INIT(\[[^]]*\], *\[\([^]]*\)\].*/\1/')
    else
        # Extract version from AC_SUBST line
        # AC_SUBST([SPELLERVERSION], [4.5.2])
        varname_upper=$(echo "$varname" | tr '[:lower:]' '[:upper:]')
        version=$(grep "AC_SUBST(\[${varname_upper}VERSION\]" "$inputdir/configure.ac" | sed 's/.*\[\([^]]*\)\])/\1/')
    fi
    
    if test -z "$version" ; then
        colour=grey
        message="N/A"
    else
        # Parse version to determine color
        # Version format: major.minor.patch
        major=$(echo "$version" | cut -d. -f1)
        
        if test "$major" -eq 0 ; then
            # Pre-release (0.x.y)
            colour=yellow
        elif test "$major" -ge 1 ; then
            # Stable release (1.x.y or higher)
            colour=green
        else
            colour=grey
        fi
        
        message="v$version"
    fi
fi

echo "{ \"schemaVersion\": 1, \"label\": \"$label\", \"message\": \"$message\", \"color\": \"$colour\" }"
