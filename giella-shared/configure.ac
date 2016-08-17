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
AC_INIT([giella-shared], [0.1.0], [bugs@divvun.no], [giella-shared], [http://divvun.no])
AC_REVISION([$Revision$])
AC_CONFIG_AUX_DIR([build-aux])
AM_INIT_AUTOMAKE([1.9 tar-pax -Wall -Werror foreign])

## Program checks:
AC_PROG_MKDIR_P()
AC_PROG_INSTALL()

AC_CONFIG_FILES([Makefile \
                 giella-shared])
AC_OUTPUT

cat<<EOF
-- Building $PACKAGE_STRING:

Running make here will compile all necessary scripts and auxiliary files.
EOF
