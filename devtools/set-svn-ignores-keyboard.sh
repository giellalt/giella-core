#!/bin/bash

# Wrong usage - short instruction:
if ! test $# -eq 1 ; then
    echo "Usage: $0 KEYBOARD_DIR"
    exit 1
fi

if test ! -d $1/*.kbdgen ; then
    echo "This script must have a top-level keyboard directory as its only"
    echo "argument, and that dir must contain a kbdgen bundle. E.g."
    echo
    echo "/some/path/to/keyboard-sme/"
    echo
    echo and not:
    echo "$1"
    echo
    exit 1
fi

# The ignore command:
svnignore="svn -q propset svn:ignore"

# Define common ignore patterns:
mkfiles="Makefile
Makefile.in"

autofiles="autom4te.cache
build-aux
config.log
config.status
configure
aclocal.m4"

# Set svn:ignore props on all dirs:
for f in $(find $1/ \
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
			-type d) ; do
	$svnignore "$mkfiles" $f
done

# Set the svn:ignore prop on the top level lang dir:
$svnignore "$autofiles
$mkfiles
build
deps
*.zhfst" $1

# Set the svn:ignore prop on the macos dir:
$svnignore "*.unsigned.pkg" $1/macos

# Set the svn:ignore prop on the android dir:
$svnignore "deps
*.apk" $1/android

# Set the svn:ignore prop on the ios dir:
$svnignore "*build" $1/ios

# Set the svn:ignore prop on the win dir:
$svnignore "amd64
i386
*.iss
kbdi.exe
wow64" $1/win
