#!/usr/bin/perl
use strict;

use utf8;

# sort-cohort.pl
# Perl script for sorting the analyses in a CG stream cohort. The main
# purpose is to guarantee a consistent ordering of the analyses across
# invocations, versions and tools, so that it is possible to make meaningful
# diffs of the output of morphological analysis.
#
# This script differs from sort-cohort.pl in the type of input it takes:
# instead of Xerox lookup-type input, where the cohorts are separated
# by empty lines, and all analyses are preceeded with the lemma, and the
# lemma only, it takes a stream of cohorts separated by non-blank first
# characters.
#
# Input: 
# "<Iđđes>"
# 	 "iđđes" Adv
# "<dii.>"
# 	 "dii" N ABBR Nom
# 	 "dii" N ABBR Acc
# 	 "dii" N ABBR Attr
# 	 "dii" N ABBR Gen
#
# Output:
# "<Iđđes>"
# 	 "iđđes" Adv
# "<dii.>"
# 	 "dii" N ABBR Acc
# 	 "dii" N ABBR Attr
# 	 "dii" N ABBR Gen
# 	 "dii" N ABBR Nom

# Set the record separator to 2*newline, which is the separator between sentences
$/ = "\n\n";

# Read while not eol
while(<>) {
	chomp ;
	process_sentence($_);
}

sub process_sentence
  {
    my @cohort = split("\n\"", $_);
    
    foreach (@cohort) {
      my ($lemma, $lines) = split(/\n/, $_, 2);
      my @lines = split(/\n(?=\t\")/, $lines);
      my @newlines = sort @lines;
      my $sortlines = join("\n", @newlines);
      unless ($lemma =~ /^\"/) { $lemma = "\"".$lemma; }
      print "$lemma\n$sortlines\n";
    }
    print "\n";
  }
