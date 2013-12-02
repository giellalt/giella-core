#!/usr/bin/env perl
#
# A script to grep for occurences of a string within an analysed sentence.
#
# Usage: $0 G3 filename
#
# where 'G3' is the string to be grepped for.

local $grepstring=$ARGV[0];
shift;

local $/ = "";      # Empty line separator

while (<>) {
    @lines = $_ ;
    print @lines if grep /$grepstring/, @lines ;
}
