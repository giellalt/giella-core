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
   fst-filters/block-mwe-compounds.regex \
   fst-filters/convert_to_flags-CmpNP-tags.regex \
   fst-filters/extract-OLang_ENG-strings.regex \
   fst-filters/extract-OLang_FIN-strings.regex \
   fst-filters/extract-OLang_NNO-strings.regex \
   fst-filters/extract-OLang_NOB-strings.regex \
   fst-filters/extract-OLang_SME-strings.regex \
   fst-filters/extract-OLang_SWE-strings.regex \
   fst-filters/extract-Sem_Plc-strings.regex \
   fst-filters/make-optional-NGminip-tags.regex \
   fst-filters/make-optional-adv_comp-tags.regex \
   fst-filters/make-optional-final_full_stops.regex \
   fst-filters/make-optional-homonymy-tags.regex \
   fst-filters/make-optional-hyph-tags.regex \
   fst-filters/make-optional-transitivity-tags.regex \
   fst-filters/make-optional-v1-tags.regex \
   fst-filters/make-optional-variant-tags.regex \
   fst-filters/remove-ABBR-strings.regex \
   fst-filters/remove-ACR-strings.regex \
   fst-filters/remove-CLB-strings.regex \
   fst-filters/remove-MinusSpell-strings.regex \
   fst-filters/remove-NA-strings.regex \
   fst-filters/remove-NG-strings.regex \
   fst-filters/remove-NGminip-strings.regex \
   fst-filters/remove-OLang_ENG-strings.regex \
   fst-filters/remove-OLang_FIN-strings.regex \
   fst-filters/remove-OLang_NNO-strings.regex \
   fst-filters/remove-OLang_NOB-strings.regex \
   fst-filters/remove-OLang_SME-strings.regex \
   fst-filters/remove-OLang_SWE-strings.regex \
   fst-filters/remove-OLang_UND-strings.regex \
   fst-filters/remove-Orth_IPA-strings.regex \
   fst-filters/remove-Orth_Strd-strings.regex \
   fst-filters/remove-PUNCT-strings.regex \
   fst-filters/remove-Prop-strings.regex \
   fst-filters/remove-RCmpnd-strings.regex \
   fst-filters/remove-UseCirc-strings.regex \
   fst-filters/remove-Use_GC-strings.regex \
   fst-filters/remove-Use_GC-tags.regex \
   fst-filters/remove-Use_PMatch-strings.regex \
   fst-filters/remove-Use_PMatch-tags.regex \
   fst-filters/remove-Use_TTS-strings.regex \
   fst-filters/remove-Use_TTS-tags.regex \
   fst-filters/remove-Use_minusGC-strings.regex \
   fst-filters/remove-Use_minusGC-tags.regex \
   fst-filters/remove-Use_minusTTS-strings.regex \
   fst-filters/remove-Use_minusTTS-tags.regex \
   fst-filters/remove-Use_minus_PMatch-strings.regex \
   fst-filters/remove-Use_minus_PMatch-tags.regex \
   fst-filters/remove-adv_comp-tags.regex \
   fst-filters/remove-homonymy-tags.regex \
   fst-filters/remove-hyphenated-strings.regex \
   fst-filters/remove-hyphenation-marks.regex \
   fst-filters/remove-infl_boundary-marks.regex \
   fst-filters/remove-infl_deriv-borders.regex \
   fst-filters/remove-mwe-strings.regex \
   fst-filters/remove-mwe-tags.regex \
   fst-filters/remove-non_hyphenated-strings.regex \
   fst-filters/remove-nonfirst_infl_boundary-marks.regex \
   fst-filters/remove-norm-comp-tags.regex \
   fst-filters/remove-number-string-tags.regex \
   fst-filters/remove-orthography-tags.regex \
   fst-filters/remove-transitivity-tags.regex \
   fst-filters/remove-usage_except_NGminip-tags.regex \
   fst-filters/remove-usage_except_speller-tags.regex \
   fst-filters/remove-use_marg-strings.regex \
   fst-filters/remove-use_mt-strings.regex \
   fst-filters/remove-variant-strings.regex \
   fst-filters/remove-variant-tags.regex \
   fst-filters/remove-word-boundary.regex \
   fst-filters/reorder-subpos-tags.regex \
   fst-filters/replace-hyphenation-chars.regex \
   fst-filters/split-CmpNP-tags.regex \
   fst-filters/tag-lowercase_error-strings.regex \
   scripts/clean_weight_corpus.sh \
   scripts/convert-divvunsuggest-to-almostplain.awk \
   scripts/count-all-lemmas.sh \
   scripts/data/cohort_to_table_footer.html \
   scripts/data/cohort_to_table_header.html \
   scripts/doccomments2ghpages.awk \
   scripts/doccomments2ghpages-vislcg.awk \
   scripts/jspwiki-parser.py \
   scripts/jspwiki2md.awk \
   scripts/edit-distance.bash \
   scripts/editdist.py \
   scripts/extract-abbr.pl \
   scripts/Util.pm \
   scripts/extract-lemmas.sh \
   scripts/extract-tags.sh \
   scripts/extract-yaml-lemmas.sh \
   scripts/extract-used-tags.sh \
   scripts/extract-defined-tags.sh \
   scripts/generate-area-filter-regex.sh \
   scripts/generate-dialect-filter-regex.sh \
   scripts/generate-mixed_area-filter-regex.sh \
   scripts/generate-nfc-nfd-regex.bash \
   scripts/generate-nfd-nfc-regex.bash \
   scripts/generate-wordforms-for-cont_lexes.sh \
   scripts/grep_analysed_sentences.pl \
   scripts/gt-core.sh \
   scripts/gt-version.sh \
   scripts/include-scripts/yaml-runner-include.sh \
   scripts/iso3-to-2.sh \
   scripts/iso639-to-name.sh \
   scripts/iso-639-3.txt \
   scripts/lookup2cg \
   scripts/make_grammarchecker_zip.py \
   scripts/make-hfstspeller-version-easter-egg.sh \
   scripts/make-lemmacount.json.sh \
   scripts/make-maturity.json.sh \
   scripts/merge-templates.sh \
   scripts/morph-test.py \
   scripts/gramcheck-test.py \
   scripts/gramcheck_comparator.py \
   scripts/new-language.sh \
   scripts/patgen.exp \
   scripts/predict.py \
   scripts/preprocess \
   scripts/replace-dummy-langcode.sh \
   scripts/run_voikko_speller.sh \
   scripts/scripted-memusg.sh \
   scripts/spell-preprocess.pl \
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

distclean-local:
	-rm -f $(pkgconfig_DATA)
