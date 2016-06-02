## Process this file with automake to produce Makefile.in

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

# The name of the template for this Makefile.am:
TEMPLATENAME=langs

# All languages that can be built
ALL_LANGS=

# Languages that need to be bootstrapped
NEW_LANGS=

if COMPILE_ALL
LANG_TARGETS=$(ALL_LANGS)
else !COMPILE_ALL
LANG_TARGETS=$(ENABLED_LANGS)
endif

all-local: $(srcdir)/Makefile.am \
		   $(srcdir)/configure.ac
	$(AM_V_GEN)for ll in $(NEW_LANGS) ; do \
		if ! test -d $(abs_top_srcdir)/$$ll ; then \
			cd $(abs_top_srcdir) ; \
			${GTCORE}/scripts/new-language.sh $$ll $(TEMPLATENAME) ; \
			cd $$ll && ./autogen.sh ; \
		fi ; \
	done ; \
	if test "x$(NEW_LANGS)" != x; then \
		echo "***" ; \
		echo "*** The language(s) \"$(NEW_LANGS)\" has/have been added! " ; \
		echo "*** Please review & commit/revert before continuing! " ; \
		echo "***" ; \
		exit 1 ; \
	fi

SUBDIRS = . $(LANG_TARGETS)

### Template merge targets and variables below here ###

# svn username for the repository being merged from
USERNAME=

# Target to merge in changes from the langs template by calling the merge script
# in every language directory.
.PHONY: templatemerge
templatemerge:
	$(AM_V_GEN)for ll in $(ALL_LANGS) ; do \
	    Language=$$( ${GTCORE}/scripts/iso639-to-name.sh $$ll); \
	    cd $(abs_top_srcdir); \
	    if test x$(USERNAME) != "x"; then \
	       USERNAMEOPTION="--username $(USERNAME)" ; \
	    fi ; \
	    if test x$(REVISION) != "x"; then \
	       REVISIONOPTION="--revision $(REVISION)" ; \
	    fi ; \
	    if test x$(UNSAFE) == "xyes"; then \
	       UNSAFEOPTION="--unsafe" ; \
	    fi ; \
	    if test -d $$ll ; then \
	        echo ; \
	        echo "*** Updating language $$ll - $$Language ***"; \
	        echo ; \
	        cd $$ll \
	           && ${GTCORE}/scripts/merge-templates.sh \
	               -t und \
	               --templatecoll $(TEMPLATENAME) \
	               $$USERNAMEOPTION \
	               $$REVISIONOPTION \
	               $$UNSAFEOPTION ; \
	    else \
	        echo ; \
	        echo "### WARNING!!! Directory for language $$ll - \
	$$Language missing ###"; \
	        echo ; \
	    fi \
	done

# Target for updating svn ignores using a script in $GTCORE:
.PHONY: svnignores
svnignores:
	$(AM_V_GEN)for ll in $(ALL_LANGS) ; do \
	    Language=$$( ${GTCORE}/scripts/iso639-to-name.sh $$ll); \
	    cd $(abs_top_srcdir) ; \
	    echo "- setting svn:ignore's for $$ll - $$Language" ; \
	    if test -d $$ll ; then \
	        cd $$ll ; ${GTCORE}/scripts/set-svn-ignores-$(TEMPLATENAME).sh \
	        	$(abs_top_srcdir)/$$ll ; \
	    fi \
	done

# Update the Makefile.am when the one in $GTCORE is updated, using svn merge,
# then stop to allow for committing the changes before continuing:
#
# Do NOT add a @, echo or $(AM_V_GEN) in front of the first shell command - it
# creates a shell syntax error after M4 processing!
$(srcdir)/Makefile.am: $(GTCORE)/$(TEMPLATENAME)-templates/Makefile.am
	makefilerevdate=$$( LC_ALL=C svn info  --xml $@ \
			| fgrep '<date>' | sed -e 's/date//g' | tr -d '<>/') ; \
		svn merge -r{$$makefilerevdate}:HEAD $< $@ \
			--ignore-ancestry --accept postpone ; \
		echo " *** " ; \
		echo " *** The file $(abs_top_srcdir)/Makefile.am has been updated! " ;\
		echo " *** Please review and commit the changes before continuing! " ; \
		echo " *** " ; \
		exit 1

# Update the configure.ac when the one in $GTCORE is updated, using svn merge,
# then stop to allow for committing the changes before continuing:
#
# Do NOT add a @, echo or $(AM_V_GEN) in front of the first shell command - it
# creates a shell syntax error after M4 processing!
$(srcdir)/configure.ac: $(GTCORE)/$(TEMPLATENAME)-templates/configure.ac
	makefilerevdate=$$( LC_ALL=C svn info  --xml $@ \
			| fgrep '<date>' | sed -e 's/date//g' | tr -d '<>/') ; \
		svn merge -r{$$makefilerevdate}:HEAD $< $@ \
			--ignore-ancestry --accept postpone ; \
		echo " *** " ; \
		echo " *** The file $(abs_top_srcdir)/configure.ac has been updated! ";\
		echo " *** Please review and commit the changes before continuing! " ; \
		echo " *** " ; \
		exit 1
