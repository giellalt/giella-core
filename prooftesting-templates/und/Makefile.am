## Process this file with automake to produce Makefile.in
## Copyright: Sámediggi/Divvun/UiT
## Licence: GPL v3+

ACLOCAL_AMFLAGS = -I m4
SUBDIRS = . hfst-mso plx voikko puki foma-trie hunspell

EXTRA_DIST = und.timestamp

configure: banner und.timestamp

.PHONY: banner
banner:
	@echo
	@echo "*** Testing the $(GTLANG) language. ***"
	@echo

if WANT_MAINTAIN
und.timestamp: ${GTCORE}/prooftesting-templates/und/und.timestamp
	@echo
	@echo "	The testing templates are newer than this language directory"
	@echo "	To get new testing rules and conventions, run: "
	@echo
	@echo "${GTCORE}/scripts/merge-templates.sh"
	@echo
	@echo "	The build will die now, but if you do not want to update your"
	@echo "	templates, touch $@ and run make again."
	@exit 1
else
# leave a small note for non-maintainers...
und.timestamp: ${GTCORE}/prooftesting-templates/und/und.timestamp
	-cp -v -f $< $@
endif

# Use all available data in the language's dir in GTFREE and GTBOUND:
GSDATA=
if FREESTABLE
GSDATA+=all-gs-stable-free.txt
endif # FREESTABLE
if FREEPRESTABLE
GSDATA+=all-gs-prestable-free.txt
endif # FREEPRESTABLE
if BOUNDSTABLE
GSDATA+=all-gs-stable-bound.txt
endif # BOUNDSTABLE
if BOUNDPRESTABLE
GSDATA+=all-gs-prestable-bound.txt
endif # BOUNDPRESTABLE

# Alternatively, specify a single document on the command line:
GSDOC=

# All input texts are concatenated into this file:
ALLDATA=all-gs-$(GTLANG).txt

noinst_DATA=$(ALLDATA) $(GSDATA)

$(ALLDATA): $(GSDOC) $(GSDATA)
	if test "x$(GSDOC)" != "x" ; then \
	ccat -l $(GTLANG) -a -S -ort -C -noforeign -f $< \
		| LOCALE=C sort \
		| $(SCRIPTDIR)/spell-preprocess.pl \
		> $@; \
	else \
		cat $^ > $@; fi

all-gs-%-bound.txt:
	ccat -l $(GTLANG) -a -S -ort -C -noforeign -f \
		$$GTBOUND/$*/goldstandard/converted/$(GTLANG)/ \
		| LOCALE=C sort \
		| $(SCRIPTDIR)/spell-preprocess.pl \
		> $@
	echo "Revision of $@: \
		$$(svn info $$GTBOUND/$*/goldstandard/converted/$(GTLANG)/ | \
		grep 'Last Changed Rev' | cut -d':' -f2);" >> corpusrevisions.txt

all-gs-%-free.txt:
	ccat -l $(GTLANG) -a -S -ort -C -noforeign -f \
		$$GTFREE/$*/goldstandard/converted/$(GTLANG)/ \
		| LOCALE=C sort \
		| $(SCRIPTDIR)/spell-preprocess.pl \
		> $@
	echo "Revision of $@: \
		$$(svn info $$GTFREE/$*/goldstandard/converted/$(GTLANG)/ | \
		grep 'Last Changed Rev' | cut -d':' -f2);" >> corpusrevisions.txt

clean-local:
	-rm -f *.txt
