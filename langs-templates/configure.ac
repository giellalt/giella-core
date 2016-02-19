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
AC_INIT([gtlangs-langs], [0.1], [bugs@divvun.no], [gtlangs], [http://divvun.no])
AC_REVISION([$Revision$])
AC_CONFIG_AUX_DIR([build-aux])
AM_INIT_AUTOMAKE([1.11 -Wall -Werror foreign])
m4_ifdef([AM_SILENT_RULES], [AM_SILENT_RULES([yes])])

AC_ARG_ENABLE([langs],
	      [AS_HELP_STRING([--enable-langs],
			      [select languages to build @<:@default=all@>:@])],
	      [enable_langs=$enableval],
	      [enable_langs=all])
AM_CONDITIONAL([COMPILE_ALL], [test "x$enable_langs" = xall])
AC_SUBST(ENABLED_LANGS, $enable_langs)

AC_CONFIG_FILES([Makefile])
AC_CONFIG_SUBDIRS([])
AC_OUTPUT

cat<<EOF
-- Building $PACKAGE_STRING:
    * included languages: $enable_langs

Running make here will compile all of the included languages mentioned above;
to compile only one language, say (to compile several languages but not all
list the codes space-separated between double quotes):
    ./configure --enable-langs=langcode
EOF
