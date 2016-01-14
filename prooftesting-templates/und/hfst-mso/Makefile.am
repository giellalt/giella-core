## Process this file with automake to produce Makefile.in
## Copyright: Sámediggi/Divvun/UiT
## Licence: GPL v3+

# Number of suggestions given by the speller:
NO_OF_SUGGS=5

# The target(s) to build:
noinst_DATA=
if CAN_HFST_OSPELL_OFFICE
noinst_DATA+=$(SPELLERVERSION) $(SPELLERTESTRESULT)

# if Forrest, then
if CAN_FORREST
FORRESTTESTRESULT=$(SPLTESTREPDIR)/$(GTLANG)/$(TESTTOOL)/goldstandard/$(DATE)-$(TESTTIME)-$(SPELLERTESTRESULT)

noinst_DATA+=$(FORRESTTESTRESULT)
endif # CAN_FORREST

endif # CAN_HFST_OSPELL_OFFICE

include $(top_srcdir)/am-shared/hfst-ospell-office-include.am
