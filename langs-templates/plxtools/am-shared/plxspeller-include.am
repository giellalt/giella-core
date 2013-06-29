# ==================================================== #
# Variable definitions				                   #
# ==================================================== #
####################################################################
# TOOL definitions.
####################################################################
# Polderland tools dir:
PLTOOLSDIR = $(GTPRIV)/polderland/bin

# Language-dependent Polderland tools:
ifeq ($(GTLANG), sme)
MKLEX  = $(PLTOOLSDIR)/mklexSamiNort
endif
ifeq ($(GTLANG), smj)
MKLEX  = $(PLTOOLSDIR)/mklexSamiLule
endif
ifeq ($(GTLANG), sma)
MKLEX  = $(PLTOOLSDIR)/mklexSamiSout
endif


# Some other tools
REZ  = /Developer/Tools/Rez
SETFILE = /Developer/Tools/SetFile
HYPHCORR = $(SCRIPTDIR)/hyphenConverter.sh

####################################################################
# COMMON variable definitions.
####################################################################

SRCSITE   = http://www.divvun.no/static_files
SCPSITE   = sd@divvun.no:xtdoc/sd/src/documentation/content/xdocs

####################################################################
# PLX variable definitions.
####################################################################

# MS Speller source files:
PLXSRCjava = \
		$(GTLANG)/polderland/numeral-$(GTLANG)-plx.txt \
		$(GTLANG)/polderland/num-$(GTLANG)-plx.txt

PLXSRCfst = \
		$(GTLANG)/polderland/spellerproper-$(GTLANG)-plx.txt \
		$(GTLANG)/polderland/spellernouns-$(GTLANG)-plx.txt \
		$(GTLANG)/polderland/spelleradjs-$(GTLANG)-plx.txt \
		$(GTLANG)/polderland/spellerabbrs-$(GTLANG)-plx.txt \
		$(GTLANG)/polderland/spellerverbs-$(GTLANG)-plx.txt \
		$(GTLANG)/polderland/mwe-$(GTLANG)-plx.txt

PLXSRCsuffix = $(GTLANG)/polderland/clitics-$(GTLANG)-plx.txt

# PLXSRCprefix = $(GTLANG)/polderland/middle-noun-$(GTLANG)-plx.txt

PLXSRCnum = $(GTLANG)/polderland/generated_nums-plx.txt

####################################################################
# PLX language-specific variable definitions.
####################################################################

# MS Speller resources and constants
ifeq ($(GTLANG), sme)
RSRCFILE = CatalanLex.rsrc.hex
ifneq "$(TEST)" "false"
WINSPELL = mssp3samiNorthern-test.lex
else
WINSPELL = mssp3samiNorthern.lex
endif
MACSPELL = SamiNortLexWithCatalanRez
HYPHPATT = SamiNorthy-patlx
HYPHDIC  = SamiNorthy-diclx
else ifeq ($(GTLANG), smj)
RSRCFILE = BasqueLex.rsrc.hex
WINSPELL = mssp3samiLule.lex
MACSPELL = SamiLuleLexWithBasqueRez
HYPHPATT = SamiLule_hy-pat.lex
HYPHDIC  = SamiLule_hy-dic.lex
else ifeq ($(GTLANG), sma)
# Awaiting a north/south split, all sma is SO, not NO.
DIALECT=SO
RSRCFILE = SlovakLex.rsrc.hex
WINSPELL = mssp3samiSout.lex
MACSPELL = SamiSoutLexWithSlovakRez
HYPHPATT = SamiLule_hy-pat.lex
HYPHDIC  = SamiLule_hy-dic.lex
else
WINSPELL = mssp3unknown.lex
HYPHPATT = unknown_hy-pat.lex
endif


# ==================================================== #
# Compile and upload MS Office speller                 #
# ==================================================== #

# ==================================================== #
# Upload MS Office lexicon                             #
# ==================================================== #
# Upload the speller lexicon when finished
# `make` uses lazy evaluation, meaning that the REVISION variable won't be set
# until needed, thus reflecting the true revision number fetched from victorio.
upload: REVISION = $(shell cat $(GTLANG)/polderland/revision.txt)
upload:
ifneq "$(TEST)" "false"
	@echo
	@echo "*** We're testing, nothing uploaded ***"
	@echo
else
	@echo
	@echo "*** Uploading $(WINSPELL) to our download site ***"
	@echo
	scp $(GTLANG)/polderland/$(WINSPELL) sd@divvun.no:staticfiles/$(DATE)-$(REVISION)-$(WINSPELL)
	$(SSH) sd@divvun.no "cd staticfiles/ && ln -sf $(DATE)-$(REVISION)-$(WINSPELL) $(WINSPELL)"
endif


# ==================================================== #
# Compile MS Office lexicon                            #
# ==================================================== #
# We compile the final MS Office speller lexicon here:
ms-win-speller: $(GTLANG)/polderland/$(WINSPELL)
$(GTLANG)/polderland/$(WINSPELL): \
		common/polderland/version.phon \
		tmp/all-plx-$(GTLANG).revsorted \
		$(GTPRIV)/polderland/src/phonrules-$(GTLANG).txt \
		ms-speller-version
	@echo
	@echo "*** cat-ing $(GTLANG) phon files ***"
	@echo
	@cat $(GTPRIV)/polderland/src/phonrules-$(GTLANG).txt \
		common/polderland/version.phon \
		tmp/$(GTLANG)-version.phon > tmp/$(GTLANG)-phon.txt
	@echo
	@echo "*** Compiling $(GTLANG) M$$ speller lexicon ***"
	@echo
ifneq "$(TEST)" "false"
	cut -f1,2 < $(GTLANG)/polderland/testing/actual.plx | uniq \
		> $(GTLANG)/polderland/testing/actual.plx.tmp
	$(MKLEX) -M512 -p tmp/$(GTLANG)-phon.txt \
	$(GTLANG)/polderland/testing/actual.plx.tmp $@
else
	$(MKLEX) -M512 -p tmp/$(GTLANG)-phon.txt tmp/all-plx-$(GTLANG).revsorted $@
endif


# ==================================================== #
# Create MS Office speller version easter egg          #
# ==================================================== #
# Version easter egg generation:
ms-speller-version:
	@echo
	@echo "*** Creating $(GTLANG) M$$ speller version info easter egg ***"
	@echo
	svn info | grep Revision | cut -d ' ' -f2 > $(GTLANG)/polderland/revision.txt
	$(SCRIPTDIR)/prooftools/add-version-info.pl \
		--lang=$(GTLANG) \
		--version=$(GTLANG)/polderland/version.txt \
		--date=$(DATE) \
		--revision=$(GTLANG)/polderland/revision.txt \
		--plxfile=tmp/$(GTLANG)-version.plx \
		--phonfile=tmp/$(GTLANG)-version.phon



# ==================================================== #
# Prepare plx wordlist                                 #
# ==================================================== #

# ==================================================== #
# Reverse sort plx files                               #
# ==================================================== #

PRINTDIR = $(top_builddir)/tools/spellcheckers/plx/tmp
PLXSUFFIX = $(top_srcdir)/tools/spellcheckers/plx/src/sp-clitics-plx.txt
PLXSRC = $(PRINTDIR)/sp-propernoun-plx.txt \
		 $(PRINTDIR)/sp-noun-plx.txt \
		 $(PRINTDIR)/sp-adjs-plx.txt \
		 $(PRINTDIR)/sp-finite-plx.txt \
		 $(PRINTDIR)/sp-verb-plx.txt \
		 $(PRINTDIR)/sp-mwe-plx.txt
PLXALL = $(PLXSRC) $(PLXSUFFIX)

# Before we compile the plx speller lexicon, we collect all pieces and rev-sort them:
$(PRINTDIR)/all-plx.revsorted: \
		numlist-plx \
		common/polderland/version.plx \
		ms-speller-version \
		$(PLXSRC)
	@echo
	@echo "*** Sorting plx files ***"
	@echo
	@if [ ! -d $(PRINTDIR)/sort ]; then \
		mkdir $(PRINTDIR)/sort ; \
	fi
ifneq "$(TEST)" "false"
	@LC_ALL=C sort -S 6G -T $(PRINTDIR)/sort -ur -o \
		$(GTLANG)/polderland/testing/actual.plx \
		tmp/$(GTLANG)-version.plx \
		common/polderland/version.plx \
		$(GTLANG)/polderland/num-$(GTLANG)-plx.txt \
		$(PLXSRCsuffix) $(PLXSRCfst)
else
	@LC_ALL=C sort -S 6G -T $(PRINTDIR)/sort -ur -o $@ \
		$(PRINTDIR)/version.plx \
		common/polderland/version.plx \
		$(PRINTDIR)/num-$(GTLANG)-plx.txt \
		$(PRINTDIR)/numlist-$(GTLANG)-plx.txt \
		$(PLXALL)
endif


# ==================================================== #
# Print PLX files                                      #
# ==================================================== #
####################################################################
# PRINT from fst in two different ways depending on whether we're testing
####################################################################
ifneq "$(TEST)" "false"
FSTPRINT = -e "write spaced-text > $@"
else
FSTPRINT = -e "lower-side" -e "print words > $@"
endif

verblist: $(PRINTDIR)/sp-verb-plx.txt
abbrlist: $(PRINTDIR)/sp-finite-plx.txt
adjlist: $(PRINTDIR)/sp-adj-plx.txt
nounlist: $(PRINTDIR)/sp-noun-plx.txt
properlist: $(PRINTDIR)/sp-propernoun-plx.txt
$(PRINTDIR)/%.txt: $(GTLANG)/bin/%.fst common/bin/hyphen-convert.fst
	@echo
	@echo "*** Building $(@F) word list in PLX format ***"
	@echo
	$(CFST) -e "load stack < common/bin/hyphen-convert.fst" \
			-e "load stack < $<" \
			-e "compose net" \
			$(FSTPRINT) \
			-stop
# If we are testing:
ifneq "$(TEST)" "false"
	cat $@ | reformat-space-text.pl > $@.test
	mv -f $@.test $@
endif

# ==================================================== #
# Multiword expressions                                #
# ==================================================== #
# Multiword printing. First it filters in all entries 
# containing space(s), then it separates last part and nonlast parts of these
# entries and replaces spaces with line breaks. Printed word list
# is sorted and plx tags are added to words.
sp-mwe-plx: $(PRINTDIR)/sp-mwe-plx.txt
$(PRINTDIR)/sp-mwe-plx.txt: \
		$(GTLANG)/bin/plxnonrec-$(GTLANG).fst \
		common/bin/mwe-filter.fst \
		common/bin/hyphen-convert.fst
	@echo
	@echo "*** Building multi-word fst ***" ;
	@echo
	$(CFST) -e "read regex @\"common/bin/mwe-filter.fst\" .o. @\"$<\" ; " \
			-e "define multi" \
			-e "read regex [0 <- ?* || \\\" \"* \" \" _ .#.] \
			.o. multi .o.  [?* -> 0 || \\\" \"* \" \" _ .#.] ; " \
			-e "define nonlast" \
			-e "read regex [0 <- ?* || .#. _ \" \" \\\" \"*] \
			.o. multi .o.  [?* -> 0 || .#. _ \" \" \\\" \"*] ; " \
			-e "define last" \
			-e "read regex [\"\n\" <- { }] .o. last .o. [{ } -> \"\n\"] ; " \
			-e "push nonlast" \
			-e "union net" \
			-e "load stack < common/bin/hyphen-convert.fst" \
			-e "turn stack" \
			-e "compose net" \
			-e "lower-side" \
			-e "print words > $@.tmp" \
			-stop
	LC_ALL=C cat $@.tmp | sort -ru | sed -e 's/\(.*\)/\1	NI/g' > $@




# ==================================================== #
# Building PLX transducers                             #
# ==================================================== #


# ==================================================== #
# Verb word file                                       #
# ==================================================== #
sp-verb-plx: $(GTLANG)/bin/sp-verb-$(GTLANG)-plx.fst
$(GTLANG)/bin/sp-verb-$(GTLANG)-plx.fst: \
		$(GTLANG)/bin/spellerverbs-$(GTLANG).fst
	@echo
	@echo "*** Building sp-verb-$(GTLANG)-plx.fst ***" ;
	@echo
	$(CFST) \
		-e "read regex @re\"common/polderland/V-Actio-filter.regex\" \
		.o. @\"$(GTLANG)/bin/spellerverbs-$(GTLANG).fst\" ; " \
		-e "define actio" \
		-e "read regex @\"$(GTLANG)/bin/spellerverbs-$(GTLANG).fst\" - actio; " \
		-e "define noactio" \
		-e "read regex @re\"common/polderland/V-Inf-filter.regex\" \
		.o. @\"$(GTLANG)/bin/spellerverbs-$(GTLANG).fst\" ; " \
		-e "define infinitive" \
		-e "read regex @re\"common/polderland/V-PrfPrc-filter.regex\" \
		.o. @\"$(GTLANG)/bin/spellerverbs-$(GTLANG).fst\" ; " \
		-e "define prfprc" \
		-e "read regex infinitive [{-	NIX,NtPABX} ]; " \
		-e "read regex prfprc     [{	NAIBE}      ]; " \
		-e "read regex actio      [{	VIBOE}      ]; " \
		-e "read regex noactio    [{	VI}         ]; " \
		-e "union net" \
		-e "turn stack" \
		-e "load stack < common/bin/usage-tags-remove.fst" \
		-e "compose net" \
		-e "save stack $@" \
		-stop


# ==================================================== #
# Finite POS word file                                 #
# ==================================================== #
# Encodes all uninflectable words + abbreviations, acronyms
# and (underived) pronouns
sp-finite-plx: $(GTLANG)/bin/sp-finite-$(GTLANG)-plx.fst
$(GTLANG)/bin/sp-finite-$(GTLANG)-plx.fst: \
		$(GTLANG)/bin/spellerabbrs-$(GTLANG).fst
	@echo
	@echo "*** Building spellerabbrs-$(GTLANG)-plx.fst ***" ;
	@echo
	$(CFST) -e "read regex @re\"common/polderland/ABBR-Cmp-filter.regex\" \
			.o. @\"$(GTLANG)/bin/spellerabbrs-$(GTLANG).fst\" ; " \
			-e "define abbrcmp" \
			-e "read regex @re\"common/polderland/ABBR-Cmp-nosugg-filter.regex\" \
			.o. @\"$(GTLANG)/bin/spellerabbrs-$(GTLANG).fst\" ; " \
			-e "define abbrcmpnosugg" \
			-e "read regex @re\"common/polderland/ACRO-Nocmp-filter.regex\" \
			.o. @\"$(GTLANG)/bin/spellerabbrs-$(GTLANG).fst\" ; " \
			-e "define acronocmp" \
			-e "read regex @re\"common/polderland/ABBR-Nocmp-filter.regex\" \
			.o. @\"$(GTLANG)/bin/spellerabbrs-$(GTLANG).fst\" ; " \
			-e "define abbrnocmp" \
			-e "read regex @re\"common/polderland/ACRO-Cmp-filter.regex\" \
			.o. @\"$(GTLANG)/bin/spellerabbrs-$(GTLANG).fst\" ; " \
			-e "define acrocmp" \
			-e "read regex @re\"common/polderland/Adv-Cmp-filter.regex\" \
			.o. @\"$(GTLANG)/bin/spellerabbrs-$(GTLANG).fst\" ; " \
			-e "define advcmp" \
			-e "read regex @\"$(GTLANG)/bin/spellerabbrs-$(GTLANG).fst\" \
					- [ abbrcmp \
					  | abbrcmpnosugg \
					  | abbrnocmp \
					  | acrocmp \
					  | advcmp \
					  | acronocmp]; " \
			-e "define therest" \
			-e "read regex abbrcmp        [{-	NePABX}            ] ; " \
			-e "read regex abbrcmpnosugg  [{	NePEX,UI}          ] ; " \
			-e "read regex abbrcmpnosugg  [{-	NIX,NePABX,NePEX}  ] ; " \
			-e "read regex abbrnocmp      [{	NI,UI}             ] ; " \
			-e "read regex acrocmp        [{	NePE,UI}           ] ; " \
			-e "read regex acrocmp        [{-	NIX,NePABO,NePEX} ] ; " \
			-e "read regex acronocmp      [{	NI,NePE,UI}        ] ; " \
			-e "read regex advcmp         [{	NAPBX,NtPAB,NIX}   ] ; " \
			-e "read regex therest        [{	NI,NePEX,UI}       ] ; " \
			-e "union net" \
			-e "turn stack" \
			-e "load stack < common/bin/usage-tags-remove.fst" \
			-e "compose net" \
			-e "save stack $@ " \
			-stop


# ==================================================== #
# Adjective word file                                  #
# ==================================================== #
sp-adj-plx: $(GTLANG)/bin/sp-adj-$(GTLANG)-plx.fst
$(GTLANG)/bin/sp-adj-$(GTLANG)-plx.fst: \
		$(GTLANG)/bin/spelleradjs-$(GTLANG).fst
	@echo
	@echo "*** Building spelleradjs-$(GTLANG)-plx.fst ***" ;
	@echo
	$(CFST) \
		-e "read regex @re\"common/polderland/N-None-Cmp-filter.regex\" \
		.o. @\"$(GTLANG)/bin/spelleradjs-$(GTLANG).fst\" ; " \
		-e "define none" \
		-e "read regex @re\"common/polderland/N-Last-Cmp-filter.regex\" \
		.o. @\"$(GTLANG)/bin/spelleradjs-$(GTLANG).fst\" ; " \
		-e "define last" \
		-e "read regex @re\"common/polderland/A-Adv-filter.regex\" \
		.o. @\"$(GTLANG)/bin/spelleradjs-$(GTLANG).fst\" ; "\
		-e "define adv" \
		-e "read regex @re\"common/polderland/A-Sg-Nom-filter.regex\" \
		.o. @\"$(GTLANG)/bin/spelleradjs-$(GTLANG).fst\" ; " \
		-e "define sgnom" \
		-e "read regex @re\"common/polderland/A-Sg-Gen-filter.regex\" \
		.o. @\"$(GTLANG)/bin/spelleradjs-$(GTLANG).fst\" ; " \
		-e "define sggen" \
		-e "read regex @re\"common/polderland/A-Pl-Gen-filter.regex\" \
		.o. @\"$(GTLANG)/bin/spelleradjs-$(GTLANG).fst\" ; " \
		-e "define plgen" \
		-e "read regex @re\"common/polderland/A-Sg-Nom-Cmp-filter.regex\" \
		.o. @\"$(GTLANG)/bin/spelleradjs-$(GTLANG).fst\" ; " \
		-e "define sgnomcmp" \
		-e "read regex @re\"common/polderland/A-Sg-Gen-Cmp-filter.regex\" \
		.o. @\"$(GTLANG)/bin/spelleradjs-$(GTLANG).fst\" ; " \
		-e "define sggencmp" \
		-e "read regex @re\"common/polderland/A-Pl-Gen-Cmp-filter.regex\" \
		.o. @\"$(GTLANG)/bin/spelleradjs-$(GTLANG).fst\" ; " \
		-e "define plgencmp" \
		-e "read regex @re\"common/polderland/A-Def-Sg-Gen-Cmp-filter.regex\" \
		.o. @\"$(GTLANG)/bin/spelleradjs-$(GTLANG).fst\" ; " \
		-e "define defsggencmp" \
		-e "read regex @re\"common/polderland/A-Def-Pl-Gen-Cmp-filter.regex\" \
		.o. @\"$(GTLANG)/bin/spelleradjs-$(GTLANG).fst\" ; " \
		-e "define defplgencmp" \
		-e "read regex @re\"common/polderland/A-Sg-Gen-Cmp-X-filter.regex\" \
		.o. @\"$(GTLANG)/bin/spelleradjs-$(GTLANG).fst\" ; " \
		-e "define sggencmpx" \
		-e "read regex @re\"common/polderland/A-Pl-Gen-Cmp-X-filter.regex\" \
		.o. @\"$(GTLANG)/bin/spelleradjs-$(GTLANG).fst\" ; " \
		-e "define plgencmpx" \
		-e "read regex @re\"common/polderland/A-Sg-Nom-Left-filter.regex\" \
		.o. @\"$(GTLANG)/bin/spelleradjs-$(GTLANG).fst\" ; " \
		-e "define sgnomleft" \
		-e "read regex @re\"common/polderland/A-Sg-Gen-Left-filter.regex\" \
		.o. @\"$(GTLANG)/bin/spelleradjs-$(GTLANG).fst\" ; " \
		-e "define sggenleft" \
		-e "read regex @re\"common/polderland/A-Pl-Gen-Left-filter.regex\" \
		.o. @\"$(GTLANG)/bin/spelleradjs-$(GTLANG).fst\" ; " \
		-e "define plgenleft" \
		-e "read regex @re\"common/polderland/A-Attr-Cmp-filter.regex\" \
		.o. @\"$(GTLANG)/bin/spelleradjs-$(GTLANG).fst\" ; " \
		-e "define attrcmp" \
		-e "read regex @re\"common/polderland/A-Attr-filter.regex\" \
		.o. @\"$(GTLANG)/bin/spelleradjs-$(GTLANG).fst\" ; "\
		-e "define allattr" \
		-e "read regex @re\"common/polderland/A-Attr-Sharp-filter.regex\" \
		.o. @\"$(GTLANG)/bin/spelleradjs-$(GTLANG).fst\"; " \
		-e "define attrder" \
		-e "read regex allattr - attrder;" \
		-e "define attr" \
		-e "read regex @\"$(GTLANG)/bin/spelleradjs-$(GTLANG).fst\" \
					- [ none        | last        | adv       \
					  | sgnom       | sggen       | plgen     \
					  | sgnomcmp    | sggencmp    | plgencmp  \
					  | defsggencmp | defplgencmp \
					  | sggencmpx   | plgencmpx   \
					  | sgnomleft   | sggenleft   | plgenleft \
					  | attrcmp     | attr]; "    \
		-e "define otherforms" \
		-e "read regex  none                                  [{	NI,UI}                      ]; " \
		-e "read regex  last                                  [{	NAIE,UI}                    ]; " \
		-e "read regex  adv                                   [{	NAI,UI}                     ]; " \
		-e "read regex [sgnom       .o. ~[ a a ?* | e e ?* ]] [{	NAIOE,NePOE,UI}             ]; " \
		-e "read regex [sgnom       .o.  [ a a ?* | e e ?* ]] [{	NePIE,UI}                   ]; " \
		-e "read regex [sgnom       .o. ~[ a a ?* | e e ?* ]] [{-	NABOX,NtPABIEX,NePAEBOX}    ]; " \
		-e "read regex [sgnom       .o.  [ a a ?* | e e ?* ]] [{-	NAB,NIX,NePOE}              ]; " \
		-e "read regex [sggen       .o. ~[ a a ?* | e e ?* ]] [{	GaBO,NAIE,UI}               ]; " \
		-e "read regex [sggen       .o. ~[ a a ?* | e e ?* ]] [{	NAIE,NePAE,UI}              ]; " \
		-e "read regex [sggen       .o.  [ a a ?* | e e ?* ]] [{	NePBO,NAB,NePIE,UI}         ]; " \
		-e "read regex [plgen       .o. ~[ a a ?* | e e ?* ]] [{	GpBO,NAIE,NePAE,UI}         ]; " \
		-e "read regex [plgen       .o.  [ a a ?* | e e ?* ]] [{	GpBO,NePIE,UI}              ]; " \
		-e "read regex [sgnomcmp    .o. ~[ a a ?* | e e ?* ]] [{	NABO,UI}                    ]; " \
		-e "read regex [sgnomcmp    .o.  [ a a ?* | e e ?* ]] [{	NePOE,NAB,UI}               ]; " \
		-e "read regex [sgnomcmp    .o. ~[ a a ?* | e e ?* ]] [{-	NABOIEX,NtPABIX,NePAEBOX}   ]; " \
		-e "read regex  sggencmp                              [{	GaBO,UI}                    ]; " \
		-e "read regex [sggencmp    .o. ~[ a a ?* | e e ?* ]] [{-	NABOIEX,NtPABIX,NePAEBOX}   ]; " \
		-e "read regex [sggencmp    .o.  [ a a ?* | e e ?* ]] [{-	NAPIX,NAPB,NePABO}          ]; " \
		-e "read regex [sggencmp    .o. ~[ a a ?* | e e ?* ]] [{	NABO,UI}                    ]; " \
		-e "read regex [sggencmp    .o.  [ a a ?* | e e ?* ]] [{-	NABOIEX,NtPABX,NePAEOX}     ]; " \
		-e "read regex  plgencmp                              [{	GpBO,UI}                    ]; " \
		-e "read regex [plgencmp    .o. ~[ a a ?* | e e ?* ]] [{	NABOIEX,NtPABIX,NePAEBOX}   ]; " \
		-e "read regex [plgencmp    .o.  [ a a ?* | e e ?* ]] [{-	NAPIX,NAPB,NePABO}          ]; " \
		-e "read regex  defsggencmp                           [{	GaBO,UI}                    ]; " \
		-e "read regex [defsggencmp .o. ~[ a a ?* | e e ?* ]] [{	NABOIEX,NtPABIX,NePAEBOX}   ]; " \
		-e "read regex  defplgencmp                           [{	GpBO,UI}                    ]; " \
		-e "read regex  defplgencmp                           [{	NABOIEX,NtPABIX,NePAEOX}    ]; " \
		-e "read regex  sggencmpx                             [{	NePBO,NePIE,NAB,UI}         ]; " \
		-e "read regex [sggencmpx   .o. ~[ a a ?* | e e ?* ]] [{	NABOIEX,NtPABIX,NePAEBOX}   ]; " \
		-e "read regex [plgencmpx   .o. ~[ a a ?* | e e ?* ]] [{	NABO,UI}                    ]; " \
		-e "read regex [plgencmpx   .o. ~[ a a ?* | e e ?* ]] [{	NABOIEX,NtPABIX,NePAEBOX}   ]; " \
		-e "read regex [plgencmpx   .o.  [ a a ?* | e e ?* ]] [{-	NePABO}                     ]; " \
		-e "read regex  sgnomleft                             [{	NAIOE,UI}                   ]; " \
		-e "read regex  sggenleft                             [{	NaAIOE,UI}                  ]; " \
		-e "read regex  plgenleft                             [{	NpAIOE,UI}                  ]; " \
		-e "read regex  attrcmp							      [{-	NePABO,UIX}                 ]; " \
		-e "read regex  attr                                  [{	NAIBOE,UI}                  ]; " \
		-e "read regex [otherforms  .o. ~[ a a ?* | e e ?* ]] [{	NAIE,NePAE,UI}              ]; " \
		-e "read regex [otherforms  .o.  [ a a ?* | e e ?* ]] [{	NtPA+,NePIE,UI}             ]; " \
		-e "union net" \
		-e "turn stack" \
		-e "load stack < common/bin/usage-tags-remove.fst" \
		-e "compose net" \
		-e "save stack $@" \
		-stop


# ==================================================== #
# Noun word file                                       #
# ==================================================== #
sp-noun-plx: $(GTLANG)/bin/sp-noun-$(GTLANG)-plx.fst
$(GTLANG)/bin/sp-noun-$(GTLANG)-plx.fst: \
		$(GTLANG)/bin/spellernouns-$(GTLANG).fst
	@echo
	@echo "*** Building spellernouns-$(GTLANG)-plx.fst ***" ;
	@echo
## Positional tags:
# +None
# +Last
	$(CFST) \
		-e "read regex @re\"common/polderland/N-None-Cmp-filter.regex\"  \
			.o. @\"$(GTLANG)/bin/spellernouns-$(GTLANG).fst\" ; " \
		-e "define none" \
		-e "read regex @re\"common/polderland/N-Last-Cmp-filter.regex\"  \
			.o. @\"$(GTLANG)/bin/spellernouns-$(GTLANG).fst\" ; " \
		-e "define last" \
		-e "read regex @re\"common/polderland/N-Pref-Cmp-filter.regex\"  \
			.o. @\"$(GTLANG)/bin/spellernouns-$(GTLANG).fst\" ; " \
		-e "define pref" \
		-e "read regex @re\"common/polderland/N-Sg-Nom-filter.regex\"    \
			.o. @\"$(GTLANG)/bin/spellernouns-$(GTLANG).fst\" ; " \
		-e "define sgnom" \
		-e "read regex @re\"common/polderland/N-Sg-Gen-filter.regex\"    \
			.o. @\"$(GTLANG)/bin/spellernouns-$(GTLANG).fst\" ; " \
		-e "define sggen" \
		-e "read regex @re\"common/polderland/N-Pl-Gen-filter.regex\"    \
			.o. @\"$(GTLANG)/bin/spellernouns-$(GTLANG).fst\" ; " \
		-e "define plgen" \
		-e "read regex @re\"common/polderland/N-Sg-Nom-Cmp-filter.regex\" \
			.o. @\"$(GTLANG)/bin/spellernouns-$(GTLANG).fst\" ; "  \
		-e "define sgnomcmp" \
		-e "read regex @re\"common/polderland/N-Sg-Gen-Cmp-filter.regex\" \
			.o. @\"$(GTLANG)/bin/spellernouns-$(GTLANG).fst\" ; "  \
		-e "define sggencmp" \
		-e "read regex @re\"common/polderland/N-Pl-Gen-Cmp-filter.regex\" \
			.o. @\"$(GTLANG)/bin/spellernouns-$(GTLANG).fst\" ; "  \
		-e "define plgencmp" \
		-e "read regex @re\"common/polderland/N-Def-Sg-Gen-Cmp-filter.regex\" \
			.o. @\"$(GTLANG)/bin/spellernouns-$(GTLANG).fst\" ; "      \
		-e "define defsggencmp" \
		-e "read regex @re\"common/polderland/N-Def-Pl-Gen-Cmp-filter.regex\" \
			.o. @\"$(GTLANG)/bin/spellernouns-$(GTLANG).fst\" ; "      \
		-e "define defplgencmp" \
		-e "read regex @re\"common/polderland/N-Sg-Gen-Cmp-X-filter.regex\" \
			.o. @\"$(GTLANG)/bin/spellernouns-$(GTLANG).fst\" ; "    \
		-e "define sggencmpx" \
		-e "read regex @re\"common/polderland/N-Pl-Gen-Cmp-X-filter.regex\" \
			.o. @\"$(GTLANG)/bin/spellernouns-$(GTLANG).fst\" ; "    \
		-e "define plgencmpx" \
		-e "read regex @re\"common/polderland/N-Sg-Nom-Left-filter.regex\" \
			.o. @\"$(GTLANG)/bin/spellernouns-$(GTLANG).fst\" ; "   \
		-e "define sgnomleft" \
		-e "read regex @re\"common/polderland/N-Sg-Gen-Left-filter.regex\" \
			.o. @\"$(GTLANG)/bin/spellernouns-$(GTLANG).fst\" ; "   \
		-e "define sggenleft" \
		-e "read regex @re\"common/polderland/N-Pl-Gen-Left-filter.regex\" \
			.o. @\"$(GTLANG)/bin/spellernouns-$(GTLANG).fst\" ; "   \
		-e "define plgenleft" \
		-e "read regex @re\"common/polderland/N-RCmpnd-filter.regex\" \
			.o. @\"$(GTLANG)/bin/spellernouns-$(GTLANG).fst\" ; "   \
		-e "define nrcmpnd" \
		-e "read regex @\"$(GTLANG)/bin/spellernouns-$(GTLANG).fst\" \
					- [ none        | last        | pref        \
					  | sgnom       | sggen       | plgen       \
					  | sgnomcmp    | sggencmp    | plgencmp    \
					  | defsggencmp | defplgencmp               \
					  | sggencmpx   | plgencmpx   | nrcmpnd     \
					  | sgnomleft   | sggenleft   | plgenleft ] ; " \
		-e "define otherforms" \
		-e "read regex  none                                  [{	NI,UI}                      ]; " \
		-e "read regex  last                                  [{	NIE,UI}                     ]; " \
		-e "read regex  pref                                  [{	NAB}                        ]; " \
		-e "read regex  pref                                  [{	NAIX,NePABX}                ]; " \
		-e "read regex [sgnom       .o. ~[ a a ?* | e e ?* ]] [{	NAIE,NePOE,UI}              ]; " \
		-e "read regex [sgnom       .o.  [ a a ?* | e e ?* ]] [{	NePIE,UI}                   ]; " \
		-e "read regex [sgnom       .o. ~[ a a ?* | e e ?* ]] [{-	NABOX,NtPABIEX,NePAEBOX}    ]; " \
		-e "read regex [sgnom       .o.  [ a a ?* | e e ?* ]] [{-	NIX,NePABO,NePEX}           ]; " \
		-e "read regex [sggen       .o. ~[ a a ?* | e e ?* ]] [{	GaBO,NAIE,UI}               ]; " \
		-e "read regex [sggen       .o. ~[ a a ?* | e e ?* ]] [{	NAIE,NePAE,UI}              ]; " \
		-e "read regex [sggen       .o.  [ a a ?* | e e ?* ]] [{	NePBO,NAB,NePIE,UI}         ]; " \
		-e "read regex [plgen       .o. ~[ a a ?* | e e ?* ]] [{	GpBO,NAIE,NePAE,UI}         ]; " \
		-e "read regex [plgen       .o.  [ a a ?* | e e ?* ]] [{	GpBO,NePIE,UI}              ]; " \
		-e "read regex [sgnomcmp    .o. ~[ a a ?* | e e ?* ]] [{	NABO,UI}                    ]; " \
		-e "read regex [sgnomcmp    .o.  [ a a ?* | e e ?* ]] [{	NePOE,NAB,UI}               ]; " \
		-e "read regex [sgnomcmp    .o. ~[ a a ?* | e e ?* ]] [{-	NABOIEX,NtPABIX,NePAEBOX}   ]; " \
		-e "read regex  sggencmp                              [{	GaBO,UI}                    ]; " \
		-e "read regex [sggencmp    .o. ~[ a a ?* | e e ?* ]] [{-	NABOIEX,NtPABIX,NePAEBOX}   ]; " \
		-e "read regex [sggencmp    .o.  [ a a ?* | e e ?* ]] [{-	NAPIX,NAPB,NePABO}          ]; " \
		-e "read regex [sggencmp    .o. ~[ a a ?* | e e ?* ]] [{	NABO,UI}                    ]; " \
		-e "read regex [sggencmp    .o.  [ a a ?* | e e ?* ]] [{-	NABOIEX,NtPABX,NePAEOX}     ]; " \
		-e "read regex  plgencmp                              [{	GpBO,UI}                    ]; " \
		-e "read regex [plgencmp    .o. ~[ a a ?* | e e ?* ]] [{	NABOIEX,NtPABIX,NePAEBOX}   ]; " \
		-e "read regex [plgencmp    .o.  [ a a ?* | e e ?* ]] [{-	NAPIX,NAPB,NePABO}          ]; " \
		-e "read regex  defsggencmp                           [{	GaBO,UI}                    ]; " \
		-e "read regex [defsggencmp .o. ~[ a a ?* | e e ?* ]] [{	NABOIEX,NtPABIX,NePAEBOX}   ]; " \
		-e "read regex  defplgencmp                           [{	GpBO,UI}                    ]; " \
		-e "read regex  defplgencmp                           [{	NABOIEX,NtPABIX,NePAEOX}    ]; " \
		-e "read regex  sggencmpx                             [{	NePBO,NePIE,NAB,UI}         ]; " \
		-e "read regex [sggencmpx   .o. ~[ a a ?* | e e ?* ]] [{	NABOIEX,NtPABIX,NePAEBOX}   ]; " \
		-e "read regex [plgencmpx   .o. ~[ a a ?* | e e ?* ]] [{	NABO,UI}                    ]; " \
		-e "read regex [plgencmpx   .o. ~[ a a ?* | e e ?* ]] [{	NABOIEX,NtPABIX,NePAEBOX}   ]; " \
		-e "read regex [plgencmpx   .o.  [ a a ?* | e e ?* ]] [{-	NePABO}                     ]; " \
		-e "read regex  sgnomleft                             [{	NAIOE,UI}                   ]; " \
		-e "read regex  sggenleft                             [{	NaAIOE,UI}                  ]; " \
		-e "read regex  plgenleft                             [{	NpAIOE,UI}                  ]; " \
		-e "read regex  nrcmpnd                               [{	NePABO}                  	]; " \
		-e "read regex  nrcmpnd                               [{-	NePABO,UI}                  ]; " \
		-e "read regex [otherforms  .o. ~[ a a ?* | e e ?* ]] [{	NAIE,NePAE,UI}              ]; " \
		-e "read regex [otherforms  .o.  [ a a ?* | e e ?* ]] [{	NtPA+,NePIE,UI}             ]; " \
		-e "union net" \
		-e "turn stack" \
		-e "load stack < common/bin/usage-tags-remove.fst" \
		-e "compose net" \
		-e "save stack $@" \
		-stop


# ==================================================== #
# Propernoun word file                                 #
# ==================================================== #
ifeq ($(GTLANG), sma)
PROPERSMA = -e "read regex [ @re\"common/polderland/N-Sg-Gen-filter.regex\" \
		.o. @\"$(GTLANG)/bin/spellerproper-$(GTLANG).fst\" \
		.o. ~[ A a ?* | E e ?* ] ] [{	NAIE}]; " \
		-e "read regex @re\"common/polderland/N-Sg-Gen-filter.regex\" \
		.o. @\"$(GTLANG)/bin/spellerproper-$(GTLANG).fst\" \
		[{-	NABOX,NtPAB,NePAEOX}]; " \
		-e "read regex @re\"common/polderland/N-Sg-Gen-Cmp-filter.regex\" \
		.o. @\"$(GTLANG)/bin/spellerproper-$(GTLANG).fst\" \
		[{	NABO}]; " \
		-e "read regex @re\"common/polderland/N-Sg-Gen-Cmp-filter.regex\" \
		.o. @\"$(GTLANG)/bin/spellerproper-$(GTLANG).fst\" \
		[{-	NABOIEX,NtPAB,NePAEOX}]; " 
else
PROPERSMA = 
endif

sp-propernoun-plx: $(GTLANG)/bin/sp-propernoun-$(GTLANG)-plx.fst
$(GTLANG)/bin/sp-propernoun-$(GTLANG)-plx.fst: \
		$(GTLANG)/bin/spellerproper-$(GTLANG).fst
	@echo
	@echo "*** Building spellerproper-$(GTLANG)-plx.fst ***" ;
	@echo
	$(CFST) \
		-e "read regex @re\"common/polderland/N-None-Cmp-filter.regex\" \
		.o. @\"$(GTLANG)/bin/spellerproper-$(GTLANG).fst\" ; " \
		-e "define none" \
		-e "read regex @re\"common/polderland/N-Last-Cmp-filter.regex\" \
		.o. @\"$(GTLANG)/bin/spellerproper-$(GTLANG).fst\" ; " \
		-e "define last" \
		-e "read regex @re\"common/polderland/Prop-Sg-Nom-filter.regex\" \
		.o. @\"$(GTLANG)/bin/spellerproper-$(GTLANG).fst\" ; " \
		-e "define sgnom" \
		-e "read regex @re\"common/polderland/Prop-Sg-Gen-filter.regex\" \
		.o. @\"$(GTLANG)/bin/spellerproper-$(GTLANG).fst\" ; " \
		-e "define sggen" \
		-e "read regex @re\"common/polderland/Prop-Pl-Gen-filter.regex\" \
		.o. @\"$(GTLANG)/bin/spellerproper-$(GTLANG).fst\" ; " \
		-e "define plgen" \
		-e "read regex @re\"common/polderland/N-Sg-Nom-Cmp-filter.regex\" \
		.o. @\"$(GTLANG)/bin/spellerproper-$(GTLANG).fst\" ; " \
		-e "define sgnomcmp" \
		-e "read regex @re\"common/polderland/N-Sg-Gen-Cmp-filter.regex\" \
		.o. @\"$(GTLANG)/bin/spellerproper-$(GTLANG).fst\" ; " \
		-e "define sggencmp" \
		-e "read regex @re\"common/polderland/N-Pl-Gen-Cmp-filter.regex\" \
		.o. @\"$(GTLANG)/bin/spellerproper-$(GTLANG).fst\" ; " \
		-e "define plgencmp" \
		-e "read regex @re\"common/polderland/N-Sg-Gen-Cmp-X-filter.regex\" \
		.o. @\"$(GTLANG)/bin/spellerproper-$(GTLANG).fst\" ; " \
		-e "define sggencmpx" \
		-e "read regex @re\"common/polderland/N-Pl-Gen-Cmp-X-filter.regex\" \
		.o. @\"$(GTLANG)/bin/spellerproper-$(GTLANG).fst\" ; " \
		-e "define plgencmpx" \
		-e "read regex @\"$(GTLANG)/bin/spellerproper-$(GTLANG).fst\" \
					- [ none        | last      \
					  | sgnom       | sggen     | plgen    \
					  | sgnomcmp    | sggencmp  | plgencmp \
					  | sggencmpx   | plgencmpx ]; " \
		-e "define otherforms" \
		-e "read regex  none        [{	NI,UI}              ]; " \
		-e "read regex  last        [{	NePE,UI}            ]; " \
		-e "read regex  sgnom       [{	NePIE,UI}           ]; " \
		-e "read regex  sggen       [{	NePIE,UI}           ]; " \
		-e "read regex  plgen       [{	NePIE,UI}           ]; " \
		-e "read regex  sgnomcmp    [{	NePIE,UI}           ]; " \
		-e "read regex  sgnomcmp    [{-	NIX,NePABO,NePEX}]; " \
		-e "read regex  sggencmp    [{	NePIE,UI}           ]; " \
		-e "read regex  sggencmp    [{-	NIX,NePABO,NePEX}]; " \
		-e "read regex  plgencmp    [{	NePIE,UI}           ]; " \
		-e "read regex  plgencmp    [{-	NIX,NePABO,NePEX}]; " \
		-e "read regex  sggencmpx   [{	NePIE,UI}           ]; " \
		-e "read regex  sggencmpx   [{-	NIX,NePABO,NePEX}]; " \
		-e "read regex  plgencmpx   [{	NePIE,UI}           ]; " \
		-e "read regex  plgencmpx   [{-	NIX,NePABO,NePEX}]; " \
		-e "read regex  otherforms  [{	NePIE,UI}           ]; " \
		-e "union net" \
		-e "turn stack" \
		-e "load stack < common/bin/usage-tags-remove.fst" \
		-e "compose net" \
		-e "save stack $@" \
		-stop
