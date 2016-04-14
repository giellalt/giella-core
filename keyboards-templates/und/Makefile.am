## Process this file with automake to produce Makefile.in
## Copyright: Sámediggi/Divvun/UiT
## Licence: GPL v3+

EXTRA_DIST = und.timestamp

IOS_AUTOTOOLS=ios-autotools
IOS_AUTOTOOLS_PATH=$(shell echo $$(pwd)/deps/$(IOS_AUTOTOOLS))
IOS_IME=tasty-imitation-keyboard
ANDROID_IME=giella-ime
SOFTKBDGEN=kbdgen
# RELEASE=-R

# XML_SRC can be a language code or the full xml file name, both given
# by the user
XML_SRC=
CLDR_SRC=$(shell if test ${file: -4} == ".xml" ; then \
                    echo $(XML_SRC) ; \
                else \
                    echo "$(XML_SRC)-t-k0-osx-extended.xml" ; \
                fi )

configure: banner

.PHONY: banner
banner:
	@echo
	@echo "*** Building keyboards for the $(GTLANG) language. ***"
	@echo

if WANT_MAINTAIN
und.timestamp: ${GTCORE}/keyboards-templates/und/und.timestamp
	@echo
	@echo "	The keyboards templates are newer than this language directory"
	@echo "	To get updated keyboard data and build support, run: "
	@echo
	@echo "${GTCORE}/scripts/merge-templates.sh"
	@echo
	@echo "	The build will die now, but if you do not want to update your"
	@echo "	templates, touch $@ and run make again."
	@exit 1
else
# leave a small note for non-maintainers...
und.timestamp: ${GTCORE}/keyboards-templates/und/und.timestamp
	-cp -v -f $< $@
endif


all-local: mobile

.PHONY: deps mobile ios android desktop svg osx win x11 draft
deps:
	@echo
	@echo "*** Deps check! ***"
	@echo
	$(MKDIR_P) deps
	cd deps; \
	if ! [ -d $(IOS_AUTOTOOLS) ]; then\
		git clone https://github.com/bbqsrc/$(IOS_AUTOTOOLS).git ; \
	fi ; \
	cd $(IOS_AUTOTOOLS)/ && git pull --all && cd ../ ; \
	if ! [ -d $(IOS_IME) ]; then\
		git clone https://github.com/bbqsrc/$(IOS_IME).git ; \
	fi ; \
	cd $(IOS_IME)/ && git checkout hfst && git pull --all && cd .. ; \
	if ! [ -d $(ANDROID_IME) ]; then\
		git clone https://github.com/bbqsrc/$(ANDROID_IME).git ; \
	fi ; \
	cd $(ANDROID_IME)/ && git pull --all && cd .. ; \
	if ! [ -d $(SOFTKBDGEN) ]; then\
		git clone https://github.com/bbqsrc/$(SOFTKBDGEN).git ; \
	fi ; \
	cd $(SOFTKBDGEN)/ && git pull --all && cd ..

mobile: ios android

ios: deps
	@echo
	@echo "*** iOS build! ***"
	@echo
	PYTHONPATH=deps/$(SOFTKBDGEN) \
	PATH=$(IOS_AUTOTOOLS_PATH):$(PATH) \
	python3.5 -m $(SOFTKBDGEN) -t ios \
		-b hfst -r deps/$(IOS_IME) $(RELEASE) \
		project.yaml

android: deps
	@echo
	@echo "*** Android build! ***"
	@echo
	if ! [[ -z "$(ANDROID_SDK)" ]]; then \
	PYTHONPATH=deps/$(SOFTKBDGEN) python3.5 -m $(SOFTKBDGEN) -t android \
		-r deps/$(ANDROID_IME) -b master $(RELEASE) \
		project.yaml \
		-K targets.android.keyStore=$(GTPRIV)/admin/dev-accounts/dev_keys/sami_keyboard.keystore ; \
	else \
		echo "$$ANDROID_SDK is not defined!";\
		echo "Unable to build the Android keyboard";\
		echo "See the following URL for details, section Installation:";\
		echo "https://github.com/bbqsrc/$(SOFTKBDGEN)/blob/master/doc/targets/android.md";\
	fi

desktop: svg osx win x11

osx: deps
	@echo
	@echo "*** OSX build! ***"
	@echo
	PYTHONPATH=deps/$(SOFTKBDGEN) \
	python3.5 -m $(SOFTKBDGEN) -t osx \
		-b hfst $(RELEASE) \
		project.yaml

svg: deps
	@echo
	@echo "*** SVG build! ***"
	@echo
	PYTHONPATH=deps/$(SOFTKBDGEN) \
	python3.5 -m $(SOFTKBDGEN) -t svg \
		-b hfst $(RELEASE) \
		project.yaml

win: deps
	@echo
	@echo "*** Windows build! ***"
	@echo
	PYTHONPATH=deps/$(SOFTKBDGEN) \
	python3.5 -m $(SOFTKBDGEN) -t win \
		-b hfst $(RELEASE) \
		project.yaml

x11: deps
	@echo
	@echo "*** X11 build! ***"
	@echo
	PYTHONPATH=deps/$(SOFTKBDGEN) \
	python3.5 -m $(SOFTKBDGEN) -t x11 \
		-b hfst $(RELEASE) \
		project.yaml

draft: $(GTLANG)-draft.yaml
$(GTLANG)-draft.yaml: deps \
				$(GTCORE)/keyboards-templates/cldr/keyboards/osx/$(CLDR_SRC)
	@echo
	@echo "*** Building draft keyboard yaml file based on: ***"
	@echo "*** $$GTCORE/keyboards-templates/cldr/keyboards/osx/$(CLDR_SRC)"
	@echo
	PYTHONPATH=deps/$(SOFTKBDGEN) \
	python3.5 -m kbdgen.cldr cldr2kbdgen \
		$(GTCORE)/keyboards-templates/cldr/keyboards/osx/$(CLDR_SRC) \
		$@

clean-local:
	-rm -rf *.txt build deps
