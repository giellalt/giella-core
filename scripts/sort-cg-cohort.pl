#!/usr/bin/perl
# -*- tab-width: 4 -*-

use strict;
use utf8;

# sort-cohort.pl
# Perl script for sorting the analyses in a CG stream cohort. The main
# purpose is to guarantee a consistent ordering of the analyses across
# invocations, versions and tools, so that it is possible to make meaningful
# diffs of the output of morphological analysis.
#
# Should keep subreadings along with their main readings (and like
# vislcg3, we assume subreadings never branch), and puts anything
# "non-reading-like" at the very end of the cohort. Example:
#
# Input:
#"<su>"
#	"son" Pron Pers Sg3 Acc <W:0>
#	"son" Pron Pers Sg3 Gen <W:0>
#: 
#"<su.>"
#	"." CLB <W:0> "<.>"
#		"son" Pron Pers Sg3 Gen <W:0> "<su>"
#	"." CLB <W:0> "<.>"
#		"son" Pron Pers Sg3 Acc <W:0> "<su>"
#	"." PUNCT <W:0> "<.>"
#		"su" Adv ABBR <W:0> "<su>"
#	"su" Adv ABBR <W:0>
#:\n
#
# Output:
#"<su>"
#	"son" Pron Pers Sg3 Gen <W:0>
#	"son" Pron Pers Sg3 Acc <W:0>
#: 
#"<su.>"
#	"su" Adv ABBR <W:0>
#	"." PUNCT <W:0> "<.>"
#		"su" Adv ABBR <W:0> "<su>"
#	"." CLB <W:0> "<.>"
#		"son" Pron Pers Sg3 Gen <W:0> "<su>"
#	"." CLB <W:0> "<.>"
#		"son" Pron Pers Sg3 Acc <W:0> "<su>"
#:\n


# Set the record separator to wordform-tag after newline, ie. start of cohort:
$/ = "\n\"<";

# Read while not eol
while (<>) {
    my @cohort = split(/(\n[^\t\n][^\n]*|\n$|\n\t")/, $_);
    my $wf = shift @cohort;
    print $wf;
    my @readings = ();
    my $insep = 1;
    my $postsep = "";
    foreach my $val (@cohort) {
        if($insep == 1) {
            if($val ne "\n\t\"") {
                $postsep .= $val;
            }
        }
        elsif($val ne undef){
            push @readings, "\n\t\"".$val;
        }
        $insep = !$insep;
    }
    print join("", sort{$b cmp $a} @readings);
    print $postsep;
}

# For testing purposes, here's a gawk script that should do the same thing:
#LC_ALL=C gawk '
#BEGIN{ RS="\n\"" }
#NR>1{ printf("\n\"") }
#{
#  split($0,rs,"\n[^\t\n][^\n]*|\n$|\n\t\"", seps)
#  printf "%s", rs[1]
#  delete rs[1]
#  PROCINFO["sorted_in"] = "@val_str_desc"
#  postsep = ""
#  for(i in rs) {
#    if(seps[i]!="\n\t\"")  {
#      postsep = postsep seps[i]
#    }
#    if(rs[i]) {
#      printf "\n\t\"%s", rs[i]
#    }
#  }
#  printf "%s", postsep
#}
#'

