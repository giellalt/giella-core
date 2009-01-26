# This is a makefile that builds the dictionaries

# java -Xmx2048m net.sf.saxon.Transform -it main collect-smanob-parts.xsl

# =========== Tools: ============= #
LEXC = lexc -utf8
XFST = xfst -utf8
JV   = java
MF   = -Xmx2048m
EF   = -it main
XSL  = net.sf.saxon.Transform
XQL  = net.sf.saxon.Query
SSH  = /usr/bin/ssh

# =========== Paths & files: ============= #
DICT_HOME     = ../../../words/dicts
GTHOME        = ../../gt
SMETESTING    = $(GTHOME)/sme/testing
DICTWORDS     = cips_dictwords.txt
ONE_UP      = ..
S_LANG      = xxx
T_LANG      = xxx
DICT_PATH   = $(S_LANG)$(T_LANG)
DICT_XML    = $(S_LANG)$(T_LANG).xml
MACDICT     = mac_$(DICT_XML)
COMPDICT    = collect-dict-parts.xsl
DICTTOMAC   = dict2macdict_smanob.xsl
GEN_INFO    = generate_infofile.xsl
GEN_MAKE    = generate_makefile.xsl
I_FILE      = Info.plist
M_FILE      = Makefile
MACDIR      = macdir
ORIG_SRC    = src
SRC         = ShortSrc
BIN         = bin
SCRIPTS     = scripts

GEN_TMP       = Gen_tmp
XMLOUT        = XML_out
XMLPARAD      = xml-rest-paradigm
PARADLIST     = generate-lemma_pos_pairs.xsl
RESTRPARAD    = restruct_paradigme.xsl
ADDPARAD      = add-paradigm.xsl

SL_ERROR    = @echo "Error: Source language not specified (e.g., S_LANG=sme)"
TL_ERROR    = @echo "Error: Target language(s) not specified (e.g., T_LANG=nob or T_LANG=\"nob swe\")"
BEGIN       = @echo "*** Generating $@-file ***"
END         = @echo "Done."
CLEAN       = @echo "Cleaning files."

# =========== Other: ============= #
DATE = $(shell date +%Y%m%d)

# gogo:
# ifeq ($(S_LANG), xxx)
# 	@echo
# 	$(SL_ERROR)
# 	@echo
# endif

# ifeq ($(T_LANG), xxx)
# 	@echo
# 	$(TL_ERROR)
# 	@echo
# endif

# Compile the dictionary xml-file by unifing the individual pos-files
$(DICT_PATH)/$(BIN)/$(DICT_XML): $(DICT_PATH)/$(SRC) \
                                    $(SCRIPTS)/$(COMPDICT)
	@echo 
	$(BEGIN)
	$(JV) $(MF) $(XSL) $(EF) $(SCRIPTS)/$(COMPDICT) dir=$(ONE_UP)/$< > $@
	@echo
	$(END)
	@echo

wordform_macdict: $(DICT_PATH)/$(BIN)/$(MACDICT)
$(DICT_PATH)/$(BIN)/$(MACDICT): $(DICT_PATH)/$(BIN)/$(DICT_XML) \
                                    $(SCRIPTS)/$(PARADLIST) \
                                    $(SCRIPTS)/$(RESTRPARAD) \
                                    $(SCRIPTS)/$(ADDPARAD) \
		                    $(SCRIPTS)/$(DICTTOMAC)
	@echo
	@echo "*** Extracting words from dictionary file. ***"
	@echo
	@$(JV) $(MF) $(XSL) $< $(SCRIPTS)/$(PARADLIST) > $(SMETESTING)/$(DICTWORDS)
	@echo
	@echo "*** Generating paradigms. ***"
	@echo
	cd $(SMETESTING) && ./gen-paradigms.sh $(DICTWORDS) $(DICT_HOME)/$(SCRIPTS)/$(RESTRPARAD) $(GEN_TMP)
	@echo
	@echo "*** Processing paradigmes. ***"
	@echo
	$(JV) $(MF) $(XSL) -s $< -o $@.interim.xml $(SCRIPTS)/$(ADDPARAD) gtpath=$(SMETESTING)/$(GEN_TMP)/$(XMLOUT) outputDir=$(XMLPARAD)
	@echo
	mv $@.interim.xml $(DICT_PATH)/$(BIN)/$(XMLPARAD)
	@echo
	@echo "*** Compiling the dictionary. ***"
	@echo
	$(JV) $(MF) $(XSL) -it main $(SCRIPTS)/$(COMPDICT) dir=$(ONE_UP)/$(DICT_PATH)/$(BIN)/$(XMLPARAD) > $@.tmp
	@echo
	@echo "*** Transforming the dictionary into mac-format. ***"
	@echo
	$(JV) $(MF) $(XSL) $@.tmp $(SCRIPTS)/$(DICTTOMAC) > $@
# 	rm -f $@.tmp
	@echo
	$(END)
	@echo
	@echo "*** Generating mac-object files ***"
	$(JV) $(MF) $(XSL) $(EF) $(SCRIPTS)/$(GEN_INFO) S_LANG=$(S_LANG) T_LANG=$(T_LANG) DATE=$(DATE) > $(DICT_PATH)/$(MACDIR)/$(I_FILE)
	@echo
	$(JV) $(MF) $(XSL) $(EF) $(SCRIPTS)/$(GEN_MAKE) S_LANG=$(S_LANG) T_LANG=$(T_LANG) DICT_PATH=$(ONE_UP)/$(BIN)/$(MACDICT) > $(DICT_PATH)/$(MACDIR)/$(M_FILE)
	@echo
	$(END)
	@echo "*** Building the mac dictionary ***"
	@cd $(DICT_PATH)/$(MACDIR) && make
	@echo
	$(END)




# lemma_macdict: $(DICT_PATH)/$(BIN)/$(MACDICT)
# $(DICT_PATH)/$(BIN)/$(MACDICT): $(DICT_PATH)/$(BIN)/$(DICT_XML)
# 	@echo
# 	$(BEGIN)
# 	$(JV) $(MF) $(XSL) $< $(SCRIPTS)/$(DICTTOMAC) > $@
# 	@echo
# 	$(END)
# 	@echo
# 	@echo "*** Generating mac-object files ***"
# 	$(JV) $(MF) $(XSL) $(EF) $(SCRIPTS)/$(GEN_INFO) S_LANG=$(S_LANG) T_LANG=$(T_LANG) DATE=$(DATE) > $(DICT_PATH)/$(MACDIR)/$(I_FILE)
# 	@echo
# 	$(JV) $(MF) $(XSL) $(EF) $(SCRIPTS)/$(GEN_MAKE) S_LANG=$(S_LANG) T_LANG=$(T_LANG) DICT_PATH=$(ONE_UP)/$(BIN)/$(MACDICT) > $(DICT_PATH)/$(MACDIR)/$(M_FILE)
# 	@echo
# 	$(END)
# 	@echo "*** Building the mac dictionary ***"
# 	@cd $(DICT_PATH)/$(MACDIR) && make
# 	@echo
# 	$(END)



# # saxonxsl smenob.xml ../_restruct/MyScripts/transform_nc.xsl > nobsme.xml


# # Target to make a MacOS X/Dictionary.app compatible dictionary bundle:
# nsmacdict: $(MACMAC)/$(NOBSME) # variable depending on the dictionary
# $(MACMAC)/$(NOBSME): $(CIPSTEST)/$(NOBSME) \
#                      $(SCRIPTS)/$(DICTTOMAC)
# 	@echo
# 	@echo "*** Generating the mac-version of the nobsme-dict ***"
# 	@echo

# 	$(XSLT) $(CIPSTEST)/$(NOBSME) $(SCRIPTS)/$(DICTTOMAC) > $@
# 	@cd $(MACMAC) && make



clean:
	@echo
	$(CLEAN)
	rm -f $(DICT_PATH)/$(BIN)/*
	rm -f $(SMETESTING)/$(GEN_TMP)/* $(SMETESTING)/$(DICTWORDS)
	@echo
	$(END)
	@echo
#	@rm -f bin/*fst bin/*dic bin/*lexc bin/*list bin/*html bin/*xml #macdict/smenob.xml macdict/nobsme.xml


