## Process this file with autoconf to produce the configure script

## Copyright (C) 2018 Samediggi (Norway) & UiT The Arctic University of Norway

## This program is free software: you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation, either version 3 of the License, or
## (at your option) any later version.

## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.

## You should have received a copy of the GNU General Public License
## along with this program.  If not, see <http://www.gnu.org/licenses/>.
AC_INIT([giella-core], [0.9.11], [bugs@divvun.no], [giella-core], [https://github.com/giellalt/giella-core])
AC_REVISION([$Revision$])
AC_CONFIG_AUX_DIR([build-aux])
AM_INIT_AUTOMAKE([1.9 tar-pax -Wall -Werror foreign])

AC_MSG_CHECKING([whether we can define GIELLA_CORE])
AS_IF([test "x$GIELLA_CORE"  = x], [GIELLA_CORE=$(pwd); AC_MSG_RESULT([yes - from pwd])],
	  [test "x$GIELLA_CORE" != x], [AC_MSG_RESULT([yes - from env])],
      [AC_MSG_ERROR([no - could not define GIELLA_CORE])])
AC_ARG_VAR([GIELLA_CORE], [directory holding core scripts and data for the Giella infrastructure])

SVNREVISION="$Revision$"
SVNREVNUM=$(echo ${SVNREVISION} | cut -d' ' -f2)

AC_SUBST([GIELLA_CORE_VERSION], [$VERSION-${SVNREVNUM}])

AC_PATH_PROG([HFST_INFO], [hfst-info], [false], $PATH)

AC_CONFIG_FILES([Makefile \
                 $PACKAGE.pc \
                 scripts/Makefile])
AC_CONFIG_FILES([scripts/gt-version.sh], [chmod +x scripts/gt-version.sh])
AC_CONFIG_FILES([scripts/gt-core.sh],    [chmod +x scripts/gt-core.sh])
AC_CONFIG_FILES([scripts/make-hfstspeller-version-easter-egg.sh],
                [chmod +x scripts/make-hfstspeller-version-easter-egg.sh])

AC_OUTPUT

cat<<EOF
-- Building $PACKAGE_STRING:

Running make here will compile all necessary scripts and auxiliary files.
EOF
