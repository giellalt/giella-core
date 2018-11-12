#!/bin/bash

# Debug:
#set -x

# This shell script takes five or six options, and produce (with the help of a)
# perl script and some html fragment files) an html table containing up to N
# word forms for each continuation lexicon used in a given lexc lexicon source
# file. The options are:
#
# $1    - path to giella-core (we don't use Autotools for this script)
# $2    - the set of morphosyntactic tags used for word form generation
# $3    - the source lexc file
# $4    - the generator file (without suffix)
# $5    - the max N number of lemmas to generate for each contlex, default=10
# $6    - [OPTIONAL] list of lexicons NOT to include in the table

#### User variables from the calling shell script: ####
# Location of giella-core:
giella_core="$1"

# Codes for the word forms to be generated:
morf_codes="$2"

# Lexicon source file for lexicons and lemmas:
source_file="$3"

# FST used for generation:
generator_file="$4"

# Max number of lemmas to generate:
lemmacount=$5

# Lexicons that should not be used to extract lemmas, egrep expression:
exception_lexicons="$6"

#### Script-internal variables: ####
lexicon_filename=$(basename $source_file .lexc)
generator_filename=$(basename $generator_file)
fst_types="hfst hfstol xfst foma"

#Filenames:
lemma_lexicon_list=lemma_lexicon_list_${lexicon_filename}.txt
generated_word_forms=word_form_list_${lexicon_filename}.txt
generated_table=word_form_${lexicon_filename}_${generator_filename}_table.html
html_header=$giella_core/scripts/data/cohort_to_table_header.html
html_footer=$giella_core/scripts/data/cohort_to_table_footer.html

######## Check that the source lexicon file exists:
if ! test -e "$source_file" ; then
    echo "ERROR: Source LEXC file \"$source_file\" NOT found!"
    exit 1
fi

if test "x$lemmacount" = "x"; then
    lemmacount=10
fi

################ Subroutines ################

######## Find available/newest generator:
find_generator () {
fst_file=
suffix=
lookuptool=
# Loop through the fst suffixes, and find the newest fst:
for suff in $fst_types ; do
    if test -e $generator_file.$suff ; then
        # If it is the first fst found, use it:
        if test "x$fst_file" = "x" ; then
            fst_file="$generator_file.$suff"
            suffix=$suff
        else
            # If we already found one, use the newest of the two:
            if test "$generator_file.$suff" -nt "$fst_file" ; then
                fst_file="$generator_file.$suff"
                suffix=$suff
            fi
        fi
    fi
done
# If we didn't find a generator, bail out:
if test "x$fst_file" = "x" ; then
    echo "ERROR: No generator file found!"
    exit 1
fi
# Pick the optimal/correct lookup tool depending on fst type:
if test "$suffix" = "xfst" ; then
    lookuptool=lookup
elif test "$suffix" = "hfst" ; then
    lookuptool=hfst-lookup
elif test "$suffix" = "hfstol" ; then
    lookuptool=hfst-optimized-lookup
elif test "$suffix" = "foma" ; then
    lookuptool=flookup
else
    echo "ERROR: No lookup tool found!"
    exit 1
fi
}

######## Only grep if there is a pattern to grep on, or everything will vanish:
exclgrep () {
    # Check that the grep pattern isn't empty:
    if test "x$@" != "x"; then
        egrep -v "$@"
    # If it is, just let everything pass through using cat:
    else
        cat
    fi
}

######## Extract all continuation lexicons being used, excluding
######## $exception_lexicons:
lexicon_extraction () {
grep ";" $@ \
   | egrep -v "^[[:space:]]*(\!|\@|<)" \
   | egrep -v "^[[:space:]]*[[:alpha:]]+[[:space:]]*;" \
   | sed 's/% /€/g' \
   | tr -s ' ' \
   | cut -d' ' -f2 \
   | grep -v ';' \
   | exclgrep "$exception_lexicons" \
   | sort -u
}

######## For each lexicon found, extract the N(=$lemmacount) first entries:
lemma_extraction () {
for lexicon in $@; do
    ${GTCORE}/scripts/extract-lemmas.sh \
        --include "($lexicon)" \
        --keep-contlex \
        --keep-homonyms \
        $source_file \
        | head -n $lemmacount
done
}

######## Add the morphosyntactic codes to each lemma:
add_morf_codes () {
lemmalist=$(printf "$@" | sed 's/ /__XXYYZZ__/g')
for lemma in $lemmalist; do
    for code in $morf_codes; do
        echo "$lemma$code"
    done
done
}

######## Generate the word forms:
generate_word_forms () {
    printf "$@\n" | $lookuptool -q $fst_file
}

######## Open in default browser if on Mac:
macopen() {
    if hash xdg-open 2> /dev/null; then
        xdg-open "$@"
    elif hash open 2>/dev/null; then
        open "$@"
    fi
}

################ The main processing ################
lexicon_list=$(lexicon_extraction "$source_file")
#echo "$lexicon_list" > lexicon_list.txt

lemma_lex_list_tmp=$(lemma_extraction "$lexicon_list")
lemma_lex_list=$(echo "$lemma_lex_list_tmp" | sort --key=2)

echo "$lemma_lex_list" > $lemma_lexicon_list

lemma_list=$(printf "$lemma_lex_list\n" | cut -f1 )
#echo "$lemma_list" > lemma_list.txt

lemma_code_list=$(add_morf_codes "$lemma_list" | sed 's/__XXYYZZ__/ /g')
#echo "$lemma_code_list" > lemma_code_list.txt

find_generator
generate_word_forms "$lemma_code_list" > $generated_word_forms

$GTCORE/scripts/word_form_cohorts-to-table.pl   \
            --input    "$generated_word_forms"  \
            --output   "${generated_table}.tmp" \
            --lemlex   "$lemma_lexicon_list"    \
            --codelist "$morf_codes"

# Add html header & footer with css styling:
cat $html_header \
    ${generated_table}.tmp \
    $html_footer \
    > ${generated_table}

# Open html file in default browser (only on MacOSX(?))
macopen ${generated_table}

# Remove temporary files:
rm -f "${generated_table}.tmp" \
      "$generated_word_forms" \
      "$lemma_lexicon_list"
