## Process this file with automake to produce Makefile.in
## Copyright: Sámediggi/Divvun/UiT
## Licence: GPL v3+

# Files and filenames:
GSDATA=../all-gs.txt
SPELLERINPUT=goldstandard.spin.txt
SPELLEROUTPUT=goldstandard.spout.txt
SPELLERVERSION=sp-version.txt
SPELLERTESTRESULT=goldstandard.xml

# The target(s) to build:
noinst_DATA=
if CAN_VOIKKOSPELL
noinst_DATA+=$(SPELLERVERSION) $(SPELLERTESTRESULT)
endif # CAN_VOIKKOSPELL

include $(top_srcdir)/am-shared/voikko-include.am
