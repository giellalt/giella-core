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
binmode( STDIN, ':utf8' );
binmode( STDOUT, ':utf8' );
binmode( STDERR, ':utf8' );
use open 'utf8';

while(<>) {
	# if the line contains a tab, there is an error correction pair - all is ok:
	if (/.+\t.+/) { print; next; }

	# discard lines which don't contain any letters.
	next if (! /^\p{L}/);

	chomp;

	# replace anything that is not a letter or dash
	# from the beginning and end of the expression.
	# Preserves full stop at the end.
	s/^[^\p{L}\p{Pd}]+//;
	s/[^\p{L}\p{Pd}\.]+$//;

	# remove the full stop if preceded by punctuation 
	# for example: word).
	s/[^\p{L}]+\.$//;

	# add a tab and a newline to the end of the word, then print:
	my $word = $_ . "\t\n";
	print $word;
}
