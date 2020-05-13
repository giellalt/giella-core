#!/usr/bin/env perl

# This Perl script takes three input argument, and produces an html table in
# the file specified in the fourth argument. The arguments are:
#
# --input       - generated word forms in xerox style cohorts
# --lemlex      - the lemmas and their corresponding continuation lexicons,
#                 as given as input to the word form generation
# --codelist    - list of morphosyntactic tags used to generate word forms
# --output      - name of file containing the produced html table
#
# The cohorts are read and put into a table with the corresponding lemma and
# continuation lexicon. The list of morphosyntactic tags is used as column
# headers.
#
# This script is part of a number of scripts that together produce an overview
# of what the specified fst will produce in terms of word forms.

use strict;
use utf8;
use open 'utf8';
use Getopt::Long;

binmode( STDIN, ':utf8' );
binmode( STDOUT, ':utf8' );

# Variables:
my $word_form_file;
my $word_form_table_file;
my $lemma_lexicon_list;
my $code_list;
my $number_of_codes;
my @code_array;

GetOptions ("input=s"    => \$word_form_file,
            "lemlex=s"   => \$lemma_lexicon_list,
            "codelist=s" => \$code_list,
            "output=s"   => \$word_form_table_file );

$code_list =~ s/ +/ /g;
$number_of_codes = @code_array = split(' ',$code_list);

# DEBUG prints:
# print "Morph Code List: $code_list\n";
# print "#Morph codes: $number_of_codes\n";
# print "Actual Morph Codes:\n";
# print "$code_array[0]\n";
# print "$code_array[1]\n";
# print "$code_array[2]\n";
# print "---\n";

open (WORDFORMS,"$word_form_file");
my @word_form_array;
{
  local $/ = '';
  @word_form_array = <WORDFORMS>;
}
close (WORDFORMS);

chomp @word_form_array ;

# Protect homonymy tags:
s/\+Hom/_Hom/ for @word_form_array ;

open (LEMLEX,"$lemma_lexicon_list");
my @lemlex_array = <LEMLEX>;
close (LEMLEX);

# DEBUG prints:
# print "Word form array 6: $word_form_array[6]\n";

# Start printing the html table:
open (HTMLTABLE,'>',"$word_form_table_file");

print HTMLTABLE "<table>\n";
print HTMLTABLE "<tr>\n";
print HTMLTABLE "<th>Lemma</th>";
print HTMLTABLE "<th>Lexicon</th>";
for my $code (@code_array) { print HTMLTABLE "<th>$code</th>" ; }
print HTMLTABLE "\n";
print HTMLTABLE "</tr>\n";

# Here we print the real table content:
for (my $ix = 0; $ix <= $#word_form_array; $ix += $number_of_codes ) {
    # Extract lemma and print it:
    my ($lemma, $rest) = split('\+',$word_form_array[$ix],2);
    # Clean the homonymy marker before printout:
    $lemma =~ s/_Hom/, Hom/;
    my $lemlexindex=(($ix+1+$number_of_codes) / $number_of_codes)-1;
    my ($lemlexlem, $lemlexlex) = split('\t', $lemlex_array[$lemlexindex]);
    print HTMLTABLE "<tr><th>$lemma</th>";
    print HTMLTABLE "<td>$lemlexlex</td>";

    # For each of the codes, extract the generated word forms and print them:
    for (my $j = 0; $j < $number_of_codes; $j += 1 ) {
        my $word_forms = $word_form_array[$ix + $j];
        #DEBUG:
        # print "\n";
        # print "Ordformer:\n$word_forms";
        my @word_forms = split ('\n',$word_forms);
        print HTMLTABLE "<td>";
        for my $wordform (@word_forms) {
            my ($input, $word, $questionmark) = split ('\t',$wordform);
            # If the question mark field contains weights, just skip the field
            # and print the generated word form(s):
            if ($questionmark =~ /[0-9]/) {
                print HTMLTABLE "$word</br>";
                #DEBUG:
                # print "Ordform med vekt (vekt ignorert): $word\n";
            } # Or: if the question mark field contains something else, like ?
            elsif ($questionmark) {
                print HTMLTABLE "$questionmark";
                #DEBUG:
                # print "Ordform med problem: $questionmark\n";
            } # Or: no extra weight or other information was found, print it:
            else {
                print HTMLTABLE "$word</br>";
                #DEBUG:
                # print "Ordform utan vekt og utan problem: $word\n";
            }
        }
        print HTMLTABLE "</td>";
    }

#    my $j = $word_form_array[$ix + 1];

    print HTMLTABLE "</tr>\n";
}

print HTMLTABLE "</table>\n";
# When all is done:
close (HTMLTABLE);
