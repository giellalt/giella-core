## Process this file with automake to produce Makefile.in
## Copyright: Sámediggi/Divvun/UiT
## Licence: GPL v3+

SUBDIRS=.

EXTRA_DIST = und.timestamp

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

clean-local:
	-rm -f *.txt
