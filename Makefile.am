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

SUBDIRS = . scripts

EXTRA_DIST = $(PACKAGE).pc.in

pkgconfigdir = $(prefix)/share/pkgconfig
pkgconfig_DATA = $(PACKAGE).pc

nobase_dist_pkgdata_SCRIPTS = \
   scripts/clean_weight_corpus.sh \
   scripts/data/cohort_to_table_footer.html \
   scripts/data/cohort_to_table_header.html \
   scripts/doccomments2jspwiki.awk \
   scripts/doccomments2rst.awk \
   scripts/doccomments2tex.awk \
   scripts/edit-distance.bash \
   scripts/editdist.py \
   scripts/extract-abbr.pl \
   scripts/Util.pm \
   scripts/extract-lemmas.sh \
   scripts/extract-tags.sh \
   scripts/extract-yaml-lemmas.sh \
   scripts/generate-area-filter-regex.sh \
   scripts/generate-dialect-filter-regex.sh \
   scripts/generate-wordforms-for-cont_lexes.sh \
   scripts/grep_analysed_sentences.pl \
   scripts/gt-core.sh \
   scripts/gt-version.sh \
   scripts/include-scripts/yaml-runner-include.sh \
   scripts/iso-639-3.readme.txt \
   scripts/iso-639-3_20140320.tab.txt \
   scripts/iso3-to-2.sh \
   scripts/iso639-to-name.sh \
   scripts/iso-639-3.txt \
   scripts/lookup2cg \
   scripts/make-hfstspeller-version-easter-egg.sh \
   scripts/merge-templates.sh \
   scripts/morph-test.py \
   scripts/new-language.sh \
   scripts/patgen.exp \
   scripts/preprocess \
   scripts/replace-dummy-langcode.sh \
   scripts/run_voikko_speller.sh \
   scripts/scripted-memusg.sh \
   scripts/set-svn-ignores-keyboards.sh \
   scripts/set-svn-ignores-langs.sh \
   scripts/set-svn-ignores-prooftesting.sh \
   scripts/spell-preprocess.pl \
   scripts/style/speller_xml.css \
   scripts/flaglist2make_flag_regex.sh \
   scripts/taglist2insert_semantic_tags_after_pos_regex.sh \
   scripts/taglist2make_CG_tags_regex.sh \
   scripts/taglist2make_optional_tags_regex.sh \
   scripts/taglist2remove_semantic_tags_regex.sh \
   scripts/taglist2remove_strings_regex.sh \
   scripts/taglist2remove_semantic_tags_before_pos_regex.sh \
   scripts/taglist2remove_semantic_tags_before_derivations_regex.sh \
   scripts/taglist2remove_tags_regex.sh \
   scripts/taglist2reorder_semantic_tags_regex.sh \
   scripts/uniq_count2tropical_weight.awk \
   scripts/update-all-ignores.sh \
   scripts/word_form_cohorts-to-table.pl \
   scripts/xsl/generate_lex-fileVM.xsl

# This makes the package depend on perl-Text-Brew, so don't include it in dist
# (still available through $GTCORE/scripts)
#   scripts/speller-testres.pl

# templates
