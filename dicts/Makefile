# This is a makefile that builds the sme-nob translation parser

# It should be rewritten with Twig or something similar instead of 
# the shellscript we have now

# =========== Tools: ============= #
LEXC = lexc -utf8
XFST = xfst -utf8
SSH  = /usr/bin/ssh

# =========== Paths & files: ============= #
GTHOME      = ../../../../gt
SMETESTING  = $(GTHOME)/sme/testing
SMENOBMAC   = ../deliv/macdict/objects
SMENOBNAME  = Nordsamisk-norsk ordbok.dictionary
SMENOBZIP   = smenob-mac.dictionary.tgz
UPLOADDIR   = sd@giellatekno.uit.no:xtdoc/sd/src/documentation/content/xdocs
DOWNLOADDIR = http://www.divvun.no/static_files

# =========== Other: ============= #
DATE = $(shell date +%Y%m%d)

# fst for the sme-nob dictionary

#Pseudocode:											    
#Make a lexc file:										    
#Print the first line: LEXICON Root						    
#Then, for each entry, make lines of the format smelemma:firstnobtranslation # ;
#Then print the result to file.
#Then make xfst read it with the command read lexc.
# The trick is that only the first <t node may be chosen, there may be several.

smenob.fst: ../bin/smenob.fst ../bin/smedic.fst
../bin/smenob.fst: smenob.xml  ../bin/smenob.html
	@echo
	@echo "*** Building smenob.fst ***" 
	@echo
	@echo "*** Reading shellscript smenobpairs.sh ***"
	@../script/smenobpairs.sh
	@echo
	@echo "*** Calling xfst to compile lexc ***"
	@printf "read lexc < ../bin/sn.lexc \n\
	save ../bin/ismenob.fst \n\
	invert net \n\
	save ../bin/smenob.fst \n\
	quit \n" > ../../tmp/smenob-save-script
	$(XFST) < ../../tmp/smenob-save-script
	@rm -rf ../../tmp/smenob-save-script

smenob.html: ../bin/smenob.html
../bin/smenob.html: smenob.xml smenob.xsl
	@echo
	@echo "*** Building smenob.html ***" 
	@echo
	@echo "*** Note: We now use the xsltproc tool ***"
	@xsltproc smenob.xsl smenob.xml > ../bin/smenob.html

# Target to make a MacOS X/Dictionary.app compatible dictionary bundle:
macdict: macdict/smenob.xml
macdict/smenob.xml: smenob.xml smenob2macdict.xsl add-paradigm.xsl
	@echo
	@echo "*** Extracting words from dictionary file. ***"
	@echo
	grep '<l pos' $< | \
		perl -pe 's/^.*pos="([^"]+)">(.+)<.*$$/\2	\1/' | \
		grep '	[nav]$$' | grep -v '^-' | sort -u \
		> $(SMETESTING)/dictwords.txt
	@echo
	@echo "*** Generating paradigms. ***"
	@echo
	cd $(SMETESTING) && ./gen-paradigms.sh dictwords.txt
	@echo
	@echo "*** Building smenob.xml for MacOS X Dictionary ***" 
	@echo
	java -Xmx1024m \
		org.apache.xalan.xslt.Process \
		-in  $< \
		-out $@.tmp \
		-xsl add-paradigm.xsl \
		-param gtpath $(SMETESTING)
	@xsltproc smenob2macdict.xsl $@.tmp > $@
	rm -f $@.tmp
	@cd macdict && make

upload-macdict:
	@echo
	@echo "*** TAR-ing and ZIP-ing smenob Mac dictionary ***"
	@echo
	tar -czf $(SMENOBZIP) "$(SMENOBMAC)/$(SMENOBNAME)"
	@echo
	@echo "*** Uploading smenob Mac dictionary to www.divvun.no ***"
	@echo
	@scp $(SMENOBZIP) $(UPLOADDIR)/static_files/$(DATE)-$(SMENOBZIP)
	@$(SSH) sd@divvun.no \
		"cd staticfiles/ && ln -sf $(DATE)-$(SMENOBZIP) $(SMENOBZIP)"
	@echo
	@echo "*** New zip file for smenob Mac dictionary now available at: ***"
	@echo
	@echo "$(DOWNLOADDIR)/$(DATE)-$(SMENOBZIP)"
	@echo
	@echo "*** Permlink to newest version is always: ***"
	@echo
	@echo "$(DOWNLOADDIR)/$(SMENOBZIP)"
	@echo

# fst for the Sámi words in the dictionary

#Pseudocode:
#Pick the lemmas, and print them to list
#Read the list into xfst
#Save as an automaton.

# The perlscript for glossing should use smenob.lexc or something similar.

smedic.fst: ../bin/smedic.fst
../bin/smedic.fst: smenob.xml
	@echo
	@echo "*** Building smedic.fst ***" 
	@echo
	@cat smenob.xml | grep '<l pos=' | cut -d">" -f2 | \
		cut -d"<" -f1 > ../bin/s.dic
	@printf "read text < ../bin/s.dic \n\
	save stack ../bin/smedic.fst \n\
	quit \n" > ../../tmp/smedic-save-script
	$(XFST) < ../../tmp/smedic-save-script
	@rm -rf ../../tmp/smedic-save-script

clean:
	@rm -f ../bin/*fst ../bin/*dic ../bin/*lexc ../bin/*list ../bin/*html


