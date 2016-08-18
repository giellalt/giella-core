## Process this file with automake to produce Makefile.in

## Copyright (C) 2011 Samediggi

## This program is free software: you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation, either version 3 of the License, or
## (at your option) any later version.

## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.

## You should have received a copy of the GNU General Public License
## along with this program.  If not, see <http://www.gnu.org/licenses/>.

SRC_DIRS = common eng smi urj-Cyrl

EXTRA_DIST = $(SRC_DIRS) giella-common.pc.in

pkgconfigdir = $(prefix)/share/pkgconfig
pkgconfig_DATA = $(PACKAGE).pc

install-data-hook:
	$(MKDIR_P) $(DESTDIR)$(pkgdatadir)
	for dir in $(SRC_DIRS); do \
		cp -R $(srcdir)/$$dir $(DESTDIR)$(pkgdatadir)/ ;\
	done
	chmod -R 644 $(DESTDIR)$(pkgdatadir)

uninstall-local:
	rm -rf $(DESTDIR)$(pkgdatadir)
