## Process this file with autoconf to produce configure script

## Copyright (C) 2011 Samediggi

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
AC_INIT([gtlang-scripts], [0.2.20], [bugs@divvun.no], [gtlang-scripts], [http://divvun.no])
AC_REVISION([$Revision$])
AC_CONFIG_AUX_DIR([build-aux])
AM_INIT_AUTOMAKE([-Wall -Werror foreign])

AC_MSG_CHECKING([whether we can define GTCORE])
AS_IF([test "x$GTCORE"  = x], [GTCORE=$(dirname $(pwd) ); AC_MSG_RESULT([yes - from pwd])],
	  [test "x$GTCORE" != x], [AC_MSG_RESULT([yes - from env])],
      [AC_MSG_RESULT([no])])
AC_ARG_VAR([GTCORE], [directory for Giellatekno/Divvun core data and scripts])

SVNREVISION="$Revision$"
SVNREVNUM=$(echo ${SVNREVISION} | cut -d' ' -f2)

AC_SUBST([GT_SCRIPTVERSION], [0.2.20-${SVNREVNUM}])

AC_CONFIG_FILES([Makefile])
AC_CONFIG_FILES([gt-version.sh], [chmod +x gt-version.sh])
AC_CONFIG_FILES([gt-core.sh],    [chmod +x gt-core.sh])

AC_OUTPUT

cat<<EOF
-- Building $PACKAGE_STRING:
	 * script version: $GT_SCRIPTVERSION
EOF

