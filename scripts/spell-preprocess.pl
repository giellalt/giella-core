#!/usr/bin/env perl
#
# spell-preprocess.pl
# Preprocesses input data before spell checking, to ensure
# consistent and valid data. The output format follows typos.txt.
#
# Usage: spell-preprocess.pl < INFILE > OUTFILE

use strict;
use utf8;

# These definitions ensure that the script works
# also in environments, where PERL_UNICODE is not set.
binmode( STDIN,  ':utf8' );
binmode( STDOUT, ':utf8' );
binmode( STDERR, ':utf8' );
use open 'utf8';

while(<>) {
    chomp;
    next if (/^[\#\!]/);
    next if (/^\s*$/);
    # if the line contains a tab, there is an error correction pair - all is ok:
    if (/.+\t.+/) { print $_ , "\n"; next; }

    # discard lines which don't contain any letters or numbers.
    next if (! /[\p{L}\p{Nd}]+/); # No letters or numbers
    next if (/^\p{P}+$/);         # Remove lines with only punctuation
    next if (/^[\p{P}\p{S}]+[\p{L}\p{N}]$/); # Remove smilies


    # Remove a few punctuation chars from the beginning and end of
    # the expression, preserving full stops at the end.
    s/^[".\(\/«”“]+//;  # Remove from the start of the word
    s/["),!?»”“]+\.?$//; # Remove from the end, including a final full stop
    s/[.]+$/./; # Collapse multiple full stops to one

    # add a tab and a newline to the end of the word, then print:
    my $word = $_ . "\t\n";
    print $word;
}
