#!/usr/bin/perl -w
use strict;
use utf8;

binmode( STDIN, ':utf8' );
binmode( STDOUT, ':utf8' );
use open 'utf8';

# abbr-extract
# Perl-script for extracting abbreviations from lexicon files.
#  - Reads different abbreviation classes from abbr-lang-lex.txt
#  - Searches through other files for multiword expressions.
#  - Prints abbreviation classes to file that is used by preprocess.
#
# Script is called from Makefile, command line parameters:
#  --output=<file_name> The filename for output.
#  --abbr_lex=<file_name> The filename for abbreviation lexicon.
#  --lex=<file_name1>,<file_name2> Comma-separated list of other lexicon files.
#
# $Id$

# permit named arguments
use Getopt::Long;

# Module to communicate with program's user interfaces
use langTools::Util;

my @lex_file_names;
my $lex_files;
my $abbr_file;
my $abbr_lex_file;
# Not all the languages are using paradigm generator, so no default for these.
#my $paradigmfile="/opt/smi/common/bin/paradigm.txt";
#my $tagfile="/opt/smi/common/bin/korpustags.txt";
my $paradigmfile;
my $tagfile;
my $fst;

# The numbers which are used as examples of number inflection in the preprocessor.
my @numbers = qw(1 17);

my %idioms;

GetOptions ("output=s" => \$abbr_file,
            "abbr_lex=s" => \$abbr_lex_file,
            "fst=s" => \$fst,
            "paradigm=s" => \$paradigmfile,
            "tags=s" => \$tagfile,
            "lex=s" => \$lex_files, );



my $noparadigm;
if(! $fst || !$paradigmfile || ! -f $paradigmfile) { $noparadigm=1; }

if ($lex_files) {
    @lex_file_names = split (/,/, $lex_files);
}

# Read from lex-file and write to abbr file.
open ABB, "> $abbr_file" or die "Cant open the output file: $!\n";

open LEX, "< $abbr_lex_file" or die "Cant open the abbreviation file: $!\n";


# read from the beginning of the file.
# idioms come first.
while (<LEX>) {
    if (/^LEXICON ITRAB/) {
        print ABB "$_\n";
        last;
    }
}

while (<LEX>) {
    chomp;

    if (/^LEXICON/) {
        print ABB "$_\n";
        next;
    }

    # Replace the incoming line ($_)
    # with the first group of the string ($1)
    # Assign the result to $abbr
    # The group ($1) consists of:
    # A string starting with one or more wordcharacters: [\w\.]+
    # Alternatively followed by a group consisting of
    # %, a space char and then one or more wordcharacters: % [\w\.]+
    # or (signaled by |)
    # by a - and one or more wordcharacters: -[\w\.]+
    if ((my $abbr = $_)    =~ s/^([\w\.]+(% [\w\.]+\+MWE|-[\w\.]+)*)[\s+:].*/$1/) {
        $abbr =~ s/%//g;
        print ABB "$abbr\n";
    }
}
close LEX;

# There are multi-word expressions also in other files.
# they go to IDIOM-category.
print ABB "LEXICON IDIOM\n";

my %lex_pos = ( 'noun' => 'N',
                'adv' => 'Adv',
                'adj' => 'Adj',
                'propernoun' => 'N+Prop',
                'verb' => 'V',
                'pronoun' => 'Pron',
                'numeral' => 'Num',
                );

# Initialize paradigm and generator
my %paradigms;
my $gen_lookup;
if (! $noparadigm) {
    generate_taglist($paradigmfile,$tagfile,\%paradigms);
    if ( $fst =~ /\.xfst$/ ) {
        $gen_lookup="lookup -flags mbTT -utf8 \"$fst\" 2>/dev/null";
    } elsif ( $fst =~ /\.hfst$/ ) {
        $gen_lookup="hfst-lookup -q \"$fst\" 2>/dev/null";
    }
    else {
        die "Can't find fst file: $fst!\n";
    }
}


for my $file (@lex_file_names) {

    print STDERR "abbr-extract: reading file $file\n";

    my $pos;
    for my $key (keys %lex_pos) {
        if ($file =~ /\/$key\-/) {
            $pos = $lex_pos{$key};
        }
    }

    open LEX, "< $file" or die "Cant open the file: $!\n";
    while (<LEX>) {
        chomp;
        if (! /^\!/) { #discard comments

            if ((my $abbr = $_) =~ s/^([\w\.\-^]+((% [\w\.\-^]+)+\+MWE)+).*?[\s|:].*/$1/) {
                $abbr =~ s/%//g;
                $abbr =~ s/\^//g;
                $abbr =~ s/0//g;
                $abbr =~ s/[987]$//g;

                my @idioms;
                if (! $pos || $noparadigm) {
                    print ABB "$abbr\n";
                }
                else {
                    my @all_a;
                    my $all;
                    my $i=0;

                    # Collect all possible strings for generator.
                    # The strings are splitted since there are so many possible
                    # forms for pronouns.
                    for my $a ( @{$paradigms{$pos}} ) {
                        if ($i++ > 1000) { push (@all_a, $all); $all=""; $i=0; }
                        my $string = "$abbr+$a";
                        $all .= $string . "\n";
                    }
                    if ($all) {
                        push (@all_a, $all);
                    }
                    for my $a (@all_a) {
                        call_gen(\@idioms,$a);
                    }

                    if (! @idioms) {
                        print ABB "$abbr\n";
                    }
                    else {
                        for my $idiom (@idioms) {
                            if ( $idiom =~ / /) { # print idiom only if it contains space
                                print ABB "$idiom\n";
                            }
                        }
                    }
                }
            }
        }
    }
    close LEX;
}

if( ! $noparadigm) {
    print ABB "\nLEXICON NUM\n";

    my $all;
    my %num_suffix;
    for my $n (@numbers) {
        for my $a ( @{$paradigms{"Num"}} ) {
            my $string = "$n+$a";
            $all .= $string . "\n";
        }
        my $generated = `echo \"$all\" | $gen_lookup`;
        my @analyses = split(/\n+/, $generated);

        for my $a (@analyses) {
            next if ($a =~ /\+\?/);
            next if ($a =~ /[\:\-]/);
            my ($word, $analysis) = split(/\t/, $a);
            next if (! $analysis);

            next if ($analysis =~ /^\s*$/);

            $analysis =~ s/$n//g;
            $analysis =~ s/1//g;
            $num_suffix{$analysis} = 1;
        }
    }
    for my $idiom (keys %num_suffix) {
        print ABB "$idiom\n";
    }
}


# Call generator for all word forms.
sub call_gen {
    my ($tmp_aref, $all) = @_;

    my $generated = `echo \"$all\" | $gen_lookup`;
    my @analyses = split(/\n+/, $generated);
    for my $idiom (@analyses) {
        next if ($idiom =~ /\+\?/);
        next if ($idiom =~ /[\:\-]/);
        my ($word, $analysis) = split(/\t/, $idiom);
        next if (! $analysis);

        push (@$tmp_aref, $analysis);
    }
}

close ABB;

