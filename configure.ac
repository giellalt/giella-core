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
AC_INIT([giella-core], [0.21.1], [feedback@divvun.no], [giella-core], [https://github.com/giellalt/giella-core])
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

# Check for sed with required feature:
AC_CACHE_CHECK([for sed that supports newlines and pipes], [ac_cv_path_SED],
  [AC_PATH_PROGS_FEATURE_CHECK([SED], [gnused gsed sed],
              [[m4out=`echo aaa | $ac_path_SED 's/a/\n/g' | wc -l | tr -d '[:space:] '`
                test "x$m4out" = x4\
      && ac_cv_path_SED=$ac_path_SED ac_path_SED_found=:]],
    [AC_MSG_ERROR([could not find sed that supports newlines - please install GNU sed. Hint: sudo port install gsed./c])])])
AC_SUBST([SED], [$ac_cv_path_SED])

# Check for awk with required feature:
AC_CACHE_CHECK([for awk that supports gensub], [ac_cv_path_GAWK],
  [AC_PATH_PROGS_FEATURE_CHECK([GAWK], [awk mawk nawk gawk],
    [[awkout=`$ac_path_GAWK 'BEGIN{gensub(/a/,"b","g");}'; exvalue=$?; echo $exvalue`
      test "x$awkout" = x0 \
      && ac_cv_path_GAWK=$ac_path_GAWK ac_path_GAWK_found=:]],
    [AC_MSG_ERROR([could not find awk that supports gensub - please install GNU awk. hint: sudo port install gawk])])])
AC_SUBST([GAWK], [$ac_cv_path_GAWK])

AC_PATH_PROG([HFST_INFO], [hfst-info], [false], $PATH)
AC_PATH_PROG([HFST_SUMMARISE], [hfst-summarize], [false], $PATH)
AC_PATH_PROG([UCONV], [uconv], [false])
AS_IF([test x$UCONV = xfalse], 
      [AC_MSG_ERROR([needs uconv for unicode support
       uconv is a part of ICU 
       on debian/ubuntu: apt install icu-devtools
       on macports: port install icu
       on macbrew: brew install icu4c (and follow instructions:
                                       i.e. set your PATH if necessary)
       ])])

AC_CONFIG_FILES([Makefile \
                 $PACKAGE.pc \
                 scripts/Makefile])
AC_CONFIG_FILES([scripts/gt-version.sh], [chmod +x scripts/gt-version.sh])
AC_CONFIG_FILES([scripts/gt-core.sh],    [chmod +x scripts/gt-core.sh])
AC_CONFIG_FILES([scripts/generate-nfc-nfd-regex.bash],    [chmod +x scripts/generate-nfc-nfd-regex.bash])
AC_CONFIG_FILES([scripts/generate-nfd-nfc-regex.bash],    [chmod +x scripts/generate-nfd-nfc-regex.bash])
AC_CONFIG_FILES([scripts/make-hfstspeller-version-easter-egg.sh],
                [chmod +x scripts/make-hfstspeller-version-easter-egg.sh])

AC_OUTPUT

cat<<EOF
-- Building $PACKAGE_STRING:

Running make here will compile all necessary scripts and auxiliary files.
EOF
AC_MSG_WARN([January 2024: this version involves whole move of src/fst to src/fst/morphology])
