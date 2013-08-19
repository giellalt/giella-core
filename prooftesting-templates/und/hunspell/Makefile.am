## Process this file with automake to produce Makefile.in
## Copyright: Sámediggi/Divvun/UiT
## Licence: GPL v3+

# Files and filenames:
GSDATA=../all-gs.txt
SPELLERINPUT=goldstandard.spin.txt
SPELLEROUTPUT=goldstandard.spout.txt
SPELLERVERSION=sp-version.txt
SPELLERTESTRESULT=GoldstandardTexts.txt.xml

# The target(s) to build:
noinst_DATA=
if CAN_HUNSPELL
noinst_DATA+=$(SPELLERVERSION) $(SPELLERTESTRESULT)

# if Forrest, then
if CAN_FORREST
FORRESTTESTRESULT=$(SPLTESTREPDIR)/$(GTLANG)/$(TESTTOOL)/goldstandard/$(DATE)-$(TESTTIME)-$(SPELLERTESTRESULT)

noinst_DATA+=$(FORRESTTESTRESULT)
endif # CAN_FORREST

endif # CAN_HUNSPELL

include $(top_srcdir)/am-shared/hunspell-include.am
