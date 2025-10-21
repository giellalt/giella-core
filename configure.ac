## Process this file with autoconf to produce the configure script

## Copyright (C) 2018-2025 Samediggi (Norway) & UiT The Arctic University of Norway

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
AC_INIT([giella-core], [1.3.1], [feedback@divvun.no], [giella-core], [https://github.com/giellalt/giella-core])
AC_REVISION([$Revision$])
AC_CONFIG_AUX_DIR([build-aux])
AM_INIT_AUTOMAKE([1.9 tar-pax -Wall -Werror foreign])

AC_ARG_ENABLE([configure-errors],
              [AS_HELP_STRING([--disable-configure-errors].
                              [disables fatal errors in configure script @<:@default=enabled@:>@])],
                              [enable_configure_errors=$enableval],
                              [enable_configure_errors=yes])
AC_DEFUN([gt_MSG_ERROR],
          [AS_IF([test x$enable_configure_errors != xno],
                 [tput setaf 1
                  AC_MSG_ERROR([$1])
                  tput sgr0],
                 [AC_MSG_NOTICE([ignored error: $1])])])



AC_MSG_CHECKING([whether we can define GIELLA_CORE])
AS_IF([test "x$GIELLA_CORE"  = x], [GIELLA_CORE=$(pwd); AC_MSG_RESULT([yes - from pwd])],
	  [test "x$GIELLA_CORE" != x], [AC_MSG_RESULT([yes - from env])],
      [gt_MSG_ERROR([no - could not define GIELLA_CORE])])
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
    [gt_MSG_ERROR([could not find sed that supports newlines - please install GNU sed. Hint: sudo port install gsed./c])])])
AC_SUBST([SED], [$ac_cv_path_SED])

# Check for awk with required feature:
AC_CACHE_CHECK([for awk that supports gensub], [ac_cv_path_GAWK],
  [AC_PATH_PROGS_FEATURE_CHECK([GAWK], [awk mawk nawk gawk],
    [[awkout=`$ac_path_GAWK 'BEGIN{gensub(/a/,"b","g");}'; exvalue=$?; echo $exvalue`
      test "x$awkout" = x0 \
      && ac_cv_path_GAWK=$ac_path_GAWK ac_path_GAWK_found=:]],
    [gt_MSG_ERROR([could not find awk that supports gensub - please install GNU awk. hint: sudo port install gawk])])])
AC_SUBST([GAWK], [$ac_cv_path_GAWK])

# pythony things
AM_PATH_PYTHON([3.5],, [:])
AC_PATH_PROG([PIPX], [pipx], [false], $PATH)
AS_IF([test x$PIPX = xfalse],
      [AC_MSG_WARN([we recommend using pipx to keep updated python scripts:
       on debian/ubuntu run: sudo apt update
            sudo apt install pipx
            pipx ensurepath
       on mac (brew) run: brew install pipx
            pipx ensurepath
       ])])
# duplicate all pipx tests from template here, just in case
AC_PATH_PROG([GTGRAMTOOL], [gtgramtool], [false])
AC_PATH_PROG([GTLEMMATEST], [gtlemmatest], [false])
AC_PATH_PROG([GTSPELLTEST], [gtspelltest], [false])
AC_PATH_PROG([GTPARADIGMTEST], [gtparadigmtest], [false])
AC_PATH_PROG([GTMULTICHARTEST], [gtmultichartest], [false])
AC_PATH_PROGS([GTMORPHTEST], [gtmorphtest morph-test2], [false])
AS_IF([test x$GTGRAMTOOL = xfalse],
      [gt_MSG_ERROR([gtgramtool is needed for grammar checker tests
       do: pipx install git+https://github.com/divvun/GiellaLTGramTools/])])
AS_IF([test x$GTLEMMATEST = xfalse],
      [gt_MSG_ERROR([gtlemmatest is needed for HFST generation tests
       do: pipx install git+https://github.com/divvun/GiellaLTLexTools/])])
AS_IF([test x$GTMULTICHARTEST = xfalse],
      [gt_MSG_ERROR([gtmultichartest is needed for lexc Multichar_Symbols tests
       do: pipx install git+https://github.com/divvun/GiellaLTLexTools/
       (or: pipx upgrade giellaltlextools)])])
AS_IF([test x$GTMORPHTEST = xfalse],
      [gt_MSG_ERROR([Either gtmorphtest or morph-test2 is needed for YAML-based morphology tests
       do: pipx install git+https://github.com/divvun/morph-test
       or install https://github.com/divvun/morph-test-rs])])

# testing
AC_PATH_PROG([HFST_LOOKUP], [hfst-lookup], [false], $PATH)
AC_PATH_PROG([HFST_OPTIMISED_LOOKUP], [hfst-optimised-lookup], [false], $PATH)
AC_PATH_PROG([HFST_OPTIMIZED_LOOKUP], [hfst-optimized-lookup], [false], $PATH)
AC_PATH_PROG([LOOKUP], [lookup], [false], $PATH)
AC_PATH_PROG([FLOOKUP], [flookup], [false], $PATH)
AC_PATH_PROG([SEE], [see], [head], $PATH)
AC_PATH_PROG([HFST_OSPELL], [hfst-ospell], [false], $PATH)
AC_PATH_PROG([DIVVUN_CHECKER], [divvun-checker], [false], $PATH)
AC_PATH_PROG([DIVVUN_RUNTIME], [divvun-runtime], [false], $PATH)

# Enable .drb support if divvun-runtime is available
AM_CONDITIONAL([HAVE_DIVVUN_RUNTIME], [test x$DIVVUN_RUNTIME != xfalse])

# easter eggs
AC_PATH_PROG([HFST_INFO], [hfst-info], [false], $PATH)
# alphabets
AC_PATH_PROG([HFST_SUMMARISE], [hfst-summarize], [false], $PATH)
# unicode normalisation filters
AC_PATH_PROG([UCONV], [uconv], [false])
AS_IF([test x$UCONV = xfalse], 
      [gt_MSG_ERROR([needs uconv for unicode support
       uconv is a part of ICU 
       on debian/ubuntu: apt install icu-devtools
       on macports: port install icu
       on macbrew: brew install icu4c (and follow instructions:
                                       i.e. set your PATH if necessary)
       ])])
AC_PATH_PROG([PRECOMMIT], [pre-commit], [false])

# check for shared version (not fatal yet)
#
# c/p from giella-macros.m4:
# Get the relative path from pwd to where src dir is:
MYSRCDIR=$srcdir
# Get the absolute path to the present dir:
BUILD_DIR_PATH=$(pwd)
# Combine to get the full path to the scrdir:
THIS_TOP_SRC_DIR=$BUILD_DIR_PATH/$MYSRCDIR
_gt_shared_mul_min_version=0.0.3
AS_IF([test -d "$THIS_TOP_SRC_DIR"/../shared-mul],
      [flub=$PKG_CONFIG_PATH
       export PKG_CONFIG_PATH=$THIS_TOP_SRC_DIR/../shared-mul:$PKG_CONFIG_PATH
       PKG_CHECK_MODULES([SHARED_MUL], [giella-shared-mul >= $_gt_shared_mul_min_version],
             [AC_MSG_NOTICE([NB using shared-mul in $THIS_TOP_SRC_DIR/../shared-mul])],
             [AC_MSG_WARN([shared-mul needs to be updated, cd ../shared-mul and git pull and build])])
       export PKG_CONFIG_PATH=$flub],
      [PKG_CHECK_MODULES([SHARED_MUL], [giella-shared-mul >= $_gt_shared_mul_min_version],
             [AC_MSG_RESULT([NB using system shared-mul])],
             [AC_MSG_WARN([shared-mul needs to be updated and installed])])])

AC_CONFIG_FILES([Makefile \
                 $PACKAGE.pc \
                 scripts/Makefile])
AC_CONFIG_FILES([scripts/gt-version.sh], [chmod +x scripts/gt-version.sh])
AC_CONFIG_FILES([scripts/gt-core.sh],    [chmod +x scripts/gt-core.sh])
AC_CONFIG_FILES([scripts/generate-nfc-nfd-regex.bash],
                [chmod +x scripts/generate-nfc-nfd-regex.bash])
AC_CONFIG_FILES([scripts/generate-nfd-nfc-regex.bash],
                [chmod +x scripts/generate-nfd-nfc-regex.bash])
AC_CONFIG_FILES([scripts/make-hfstspeller-version-easter-egg.sh],
                [chmod +x scripts/make-hfstspeller-version-easter-egg.sh])
AC_CONFIG_FILES([scripts/run-morph-tester.sh],
                [chmod +x scripts/run-morph-tester.sh])
AC_CONFIG_FILES([scripts/run-yaml-testcases.sh],
                [chmod +x scripts/run-yaml-testcases.sh])
AC_CONFIG_FILES([scripts/generate-lemmas.sh],
                [chmod +x scripts/generate-lemmas.sh])
AC_CONFIG_FILES([scripts/accept-all-lemmas.sh],
                [chmod +x scripts/accept-all-lemmas.sh])
AC_CONFIG_FILES([scripts/missing-multichars.sh],
                [chmod +x scripts/missing-multichars.sh])
AC_CONFIG_FILES([scripts/regresstest-pipespec.sh],
                [chmod +x scripts/regresstest-pipespec.sh])
AC_CONFIG_FILES([scripts/simpler-yaml-runner.sh],
                [chmod +x scripts/simpler-yaml-runner.sh])

AC_OUTPUT


cat<<EOF
-- Building $PACKAGE_STRING:

Running make here will compile all necessary scripts and auxiliary files.
EOF
AS_IF([test x$PRECOMMIT = xfalse], 
      [AC_MSG_WARN([we recommend installing pre-commit for automatic checks and fixes

       on mac: brew install pre-commit
       others: python3 -m pip install pre-commit])])
AS_IF([test x$enable_configure_errors = xno],
      [AC_MSG_NOTICE([THIS BUILD HAS CONFIGURE ERRORS DISABLED AND YOU MAY NOT REPORT BUGS ABOUT IT])])
