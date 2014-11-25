## Process this file with automake to produce Makefile.in
## Copyright: Sámediggi/Divvun/UiT
## Licence: GPL v3+

EXTRA_DIST =

IOS_IME=tasty-imitation-keyboard
ANDROID_IME=giella-ime

all: ios android

.PHONY: deps
deps:
	echo "*** Deps check! ***"
	$(MKDIR_P) deps
	cd deps; \
	if ! [ -d $(IOS_IME) ]; then\
		git clone https://github.com/bbqsrc/$(IOS_IME).git ; \
	fi ; \
	cd $(IOS_IME)/ && git pull && cd .. ; \
	if ! [ -d $(ANDROID_IME) ]; then\
		git clone https://github.com/bbqsrc/$(ANDROID_IME).git ; \
	fi ; \
	cd $(ANDROID_IME)/ && git pull && cd ..

ios: deps
	echo "*** iOS build! ***"
	python3.4 $(GTCORE)/scripts/keyboards/softkbdgen.py -t ios \
		-r deps/$(IOS_IME)/ -b master \
		project.yaml

android: deps
	echo "*** Android build! ***"
	if ! [[ -z "$(ANDROID_SDK)" ]]; then \
	python3.4 $(GTCORE)/scripts/keyboards/softkbdgen.py -t android \
		-r deps/$(ANDROID_IME)/ -b master \
		project.yaml ; \
	else \
		echo "$$ANDROID_SDK is not defined!";\
		echo "Unable to build the Android keyboard";\
		echo "See the following URL for details, section Installation:";\
		echo "https://github.com/bbqsrc/softkbdgen/blob/master/doc/android.osx.md";\
	fi

clean-local:
	-rm -rf *.txt build deps
