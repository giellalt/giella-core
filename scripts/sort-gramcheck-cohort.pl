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
# "<leat>" 
# "<daid>" 	"dat" &SUGGEST  	"dat" &syn-case-congruence-loc-part1  
# "<stuorámus>" 
# "<báikkiin>" 	"báiki" &syn-case-congruence-loc-part2  
# "<mátkin>" 	"mátki" &SUGGEST  	"mátki" &msyn-com-not-ess  	"mátki" &SUGGEST  	"mátki" &msyn-com-not-ess  
# "<gos>" 
# "<Balsan>" 	"Bals" &msyn-com-not-ess  	"Bals" &SUGGEST  
#
# Output:
# "<leat>" 
# "<daid>" 	&SUGGEST 	&syn-case-congruence-loc-part1  
# "<stuorámus>" 
# "<báikkiin>" 	&syn-case-congruence-loc-part2  
# "<mátkin>" 	&SUGGEST  	&msyn-com-not-ess  
# "<gos>" 
# "<Balsan>" 	&SUGGEST  	&msyn-com-not-ess  

# Read while not EOF:
while(<>) {
	if ($_ =~ m/\t/) { # Process line only if it contains a tab:
		chomp ;
		process_line($_);
	} else { # ... otherwise just print the line:
		print;
	}
}

sub process_line
  {
    my ($wordform, $rest) = split("\t",$_,2); # Split on the first tab only
    $rest =~ tr/\t/ /; # convert tab to space in the cohort part
    $rest =~ s/ +/ /g; # collaps multiple spaces into one
    my @cohort = split(" ", $rest); # split on space so that the cohort line becomes an array
    my @grep_sorted = grep(!/\"/, @cohort); # grep away the lemma strings, we don't need them

	my %hash   = map { $_, 1 } @grep_sorted; # Make a hash out of the array
	my @unique = keys %hash; # put the keys back into an array - they are by definition (of a hash) unique; see:
			# http://stackoverflow.com/questions/7651/how-do-i-remove-duplicate-items-from-an-array-in-perl
    my @sorted = sort @unique; # sort the array

    $rest = join("\t",@sorted); # Join the array elements with a tab
    print "$wordform\t$rest\n"; # print everything - we're done!
  }
