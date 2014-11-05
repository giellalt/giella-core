## Process this file with automake to produce Makefile.in
## Copyright: Sámediggi/Divvun/UiT
## Licence: GPL v3+

EXTRA_DIST =

all: ios android

deps:
	$(MKDIR_P) deps
	cd deps && \
	git clone https://github.com/bbqsrc/tasty-imitation-keyboard.git && \
	git clone https://github.com/bbqsrc/sami-ime.git

ios: deps
	python3.4 $(GTCORE)/scripts/keyboards/softkbdgen.py -t ios \
		-r deps/tasty-imitation-keyboard/ -b master \
		project.yaml

android: deps
	if ! [[ -z "$(ANDROID_SDK)" ]]; then \
	python3.4 $(GTCORE)/scripts/keyboards/softkbdgen.py -t android \
		-r deps/sami-ime/ -b master \
		project.yaml ; \
	else \
		echo "$$ANDROID_SDK is not defined!";\
		echo "Unable to build the Android keyboard";\
		echo "See the following URL for details, section Installation:";\
		echo "https://github.com/bbqsrc/softkbdgen/blob/master/doc/android.osx.md";\
	fi

clean-local:
	-rm -rf *.txt build deps
