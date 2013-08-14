## Process this file with autoconf to produce configure script

## Copyright (C) 2011 Samediggi/Divvun/UiT

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

# Following things just need to be at top of all configure.ac files:

# AC_INIT sets up project metadata:
# first field the name of the "software"
# second field is version identifie iso 8901 date is good if you have no other
#   versioining schemes in mind
# third is email address for bug reports
# fourth is name of packages made by make dist, excluding .tar.gz
# fifth is the project web address
AC_INIT([testbench-__UND__], [20130628], [feesback@divvun.no], [testbench-__UND__],
        [http://divvun.no])
# AC_REVISION is used to get SVN revision into bug reports
AC_REVISION([$Revision$])
# These configuration dirs hide some extra cruft
AC_CONFIG_AUX_DIR([build-aux])
AC_CONFIG_MACRO_DIR([m4])
# AM_INIT_AUTOMAKE sets up make conventions
AM_INIT_AUTOMAKE([1.11 -Wall -Werror foreign -Wno-portability])
m4_ifdef([AM_SILENT_RULES], [AM_SILENT_RULES([yes])])

# Some software that we either depend on or we need for certain functionality:

# Following Giellatekno specific variables are used to make external software
# work; HFST analysers, spell-checkers and so on. These also control
# some temporary file names etc.

# GTLANG is the language code used to identify this project; it should be same
# as the directory name in gtsvn and same as ISO 639 three-letter code for the
# language if possible
AC_SUBST([GTLANG], [__UND__])
# GTLANG2 is the shortest unambiguous language code for this project; it
# should be the ISO 639-1 two-letter code if possible, otherwise usually same
# as above
AC_SUBST([GTLANG2], [__UND2C__])

# GTCORE and GTFREE env. variables are required by the testbench
AC_ARG_VAR([GTCORE], [gtcore path should always be declared by gtsetup.sh])
AC_ARG_VAR([GTFREE], [gtfree path must be defined for the test bench to work])

AM_CONDITIONAL([BOUNDSTABLE],
               [test -d ${GTBOUND}/stable/goldstandard/converted/__UND__/])
AM_CONDITIONAL([BOUNDPRESTABLE],
               [test -d ${GTBOUND}/prestable/goldstandard/converted/__UND__/])
AM_CONDITIONAL([FREESTABLE],
               [test -d ${GTFREE}/stable/goldstandard/converted/__UND__/])
AM_CONDITIONAL([FREEPRESTABLE],
               [test -d ${GTFREE}/prestable/goldstandard/converted/__UND__/])

# Tests and sets up giellatekno directories and scripts
gt_PROG_SCRIPTS_PATHS

# Check for Hunspell
AC_PATH_PROG([HUNSPELL], [hunspell], [], [$PATH$PATH_SEPARATOR$with_hunspell])
AC_MSG_CHECKING([whether we can enable hunspell testing])
AS_IF([test "x$HUNSPELL" != "x" -a -d hunspell/$GTLANG2-latest/ ],
      [hunspell_test=yes],
      [hunspell_test=no])
AC_MSG_RESULT([$hunspell_test])
AM_CONDITIONAL([CAN_HUNSPELL], [test "x$hunspell_test" != "xno"])

# Check for Foma, and the trie-spell-foma tool
AC_PATH_PROG([TRIE_SPELL_FOMA], [trie-spell-foma], [],
             [$PATH$PATH_SEPARATOR$with_trie_spell_foma])
AC_PATH_PROG([FLOOKUP], [flookup], [],
             [$PATH$PATH_SEPARATOR$with_flookup])
AC_MSG_CHECKING([whether we can enable foma testing])
AS_IF([test "x$TRIE_SPELL_FOMA" != "x" -a "x$FLOOKUP" != "x" -a -d foma-trie/$GTLANG2-latest/ ],
      [trie_spell_foma_test=yes],
      [trie_spell_foma_test=no])
AC_MSG_RESULT([$trie_spell_foma_test])
AM_CONDITIONAL([CAN_FOMASPELL], [test "x$trie_spell_foma_test" != "xno"])

# Check for and configure PLX-spell-smX - only available for SME, SMJ and SMA
AC_ARG_VAR([GTPRIV], [gtpriv path must be defined for the plx tests to work])
AC_PATH_PROG([PLXSPELLSME], [spellSamiNort], [],
   [$GTPRIV/polderland/bin$PATH_SEPARATOR$PATH$PATH_SEPARATOR$with_plxspellsme])
AC_PATH_PROG([PLXSPELLSMJ], [spellSamiLule], [],
   [$GTPRIV/polderland/bin$PATH_SEPARATOR$PATH$PATH_SEPARATOR$with_plxspellsmj])
AC_PATH_PROG([PLXSPELLSMA], [spellSamiSout], [],
   [$GTPRIV/polderland/bin$PATH_SEPARATOR$PATH$PATH_SEPARATOR$with_plxspellsma])
AC_MSG_CHECKING([whether we can enable PLX speller testing])
AS_IF([test "x$PLXSPELLSME" != "x" -a \
            "x$PLXSPELLSMJ" != "x" -a \
            "x$PLXSPELLSMA" != "x" -a \
            -d plx/$GTLANG2-latest/ ],
      [plxspell_test=yes],
      [plxspell_test=no])
AC_MSG_RESULT([$plxspell_test])
AM_CONDITIONAL([CAN_PLXSPELL], [test "x$plxspell_test" != "xno"])
AM_CONDITIONAL([CAN_PLXSPELLSME],
               [test "x$plxspell_test" != "xno" -a "x$GTLANG" = "xsme"])
AM_CONDITIONAL([CAN_PLXSPELLSMJ],
               [test "x$plxspell_test" != "xno" -a "x$GTLANG" = "xsmj"])
AM_CONDITIONAL([CAN_PLXSPELLSMA],
               [test "x$plxspell_test" != "xno" -a "x$GTLANG" = "xsma"])

# Check for Voikkospell
AC_PATH_PROG([VOIKKOSPELL], [voikkospell], [],
             [$PATH$PATH_SEPARATOR$with_voikkospell])
AC_MSG_CHECKING([whether we can enable voikkospell testing])
AS_IF([test "x$VOIKKOSPELL" != "x" -a -d voikko/$GTLANG2-latest/ ],
      [voikkospell_test=yes],
      [voikkospell_test=no])
AC_MSG_RESULT([$voikkospell_test])
AM_CONDITIONAL([CAN_VOIKKOSPELL], [test "x$voikkospell_test" != "xno"])

# List all non-script files processed by Autoconf.
AC_CONFIG_FILES([Makefile           \
                 hunspell/Makefile  \
                 foma-trie/Makefile \
                 plx/Makefile       \
                 voikko/Makefile])

# This must be near the end of all configure.ac files:
AC_OUTPUT

# Prints the informative blurb at the end of ./configure command
gt_PRINT_FOOTER
