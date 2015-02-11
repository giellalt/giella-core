#!/usr/bin/perl -w
use strict;
use utf8;
use open 'utf8';
# permit named arguments
use Getopt::Long;
#use Data::Dumper; # for DEBUGging %paradigms

# Module to communicate with program's user interfaces
use langTools::Util;


binmode( STDIN, ':utf8' );
binmode( STDOUT, ':utf8' );

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

# Count analyses
my $total_to_generate = 0;
my $total_generated = 0;

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
if(! $fst || ! -f $fst || !$paradigmfile || ! -f $paradigmfile) {
    $noparadigm=1;
    print STDERR "$0: No paradigm - no fst or paradigm file.\n";
}

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
        my $lex = $_;
        $lex =~ s/\!.+//;
        print ABB "$lex\n";
        last;
    }
}

while (<LEX>) {
    chomp;

    if (/^LEXICON/) {
        my $lex = $_;
        $lex =~ s/\!.+//;
        print ABB "$lex\n";
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

my %lex_pos = ( 'nouns' => 'N',
                'adverbs' => 'Adv',
                'propernouns' => 'N', # should just accept N+Prop when generating
                'pronouns' => 'Pron',
                );

# Initialize paradigm and generator
my %paradigms;
my $gen_lookup;
if (! $noparadigm) {
    generate_taglist($paradigmfile,$tagfile,\%paradigms);
#    print Dumper(\%paradigms); # DEBUG
    if ( $fst =~ /\.xfst$/ ) {
        $gen_lookup="lookup -flags mbTT -utf8 \"$fst\" 2>/dev/null";
    } elsif ( $fst =~ /\.hfst$/ ) {
        $gen_lookup="hfst-lookup -q \"$fst\" 2>/dev/null";
    }
    else {
        die "Can't find fst file: $fst!\n";
    }
}

my %all_idioms;

for my $file (@lex_file_names) {

    print STDERR "$0: reading file $file\n";

    my $pos;

    if ($file =~ /pronouns/) {
        $pos = 'Pron';
    } elsif ($file =~ /adverbs/) {
        $pos = 'Adv';
    } elsif ($file =~ /nouns/) {
        $pos = 'N';
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
#                     print STDERR __LINE__ . " Ingen paradigme\n"; # DEBUG
                }
                else {
                    my $this_abbr = $abbr;
                    $this_abbr =~ s/\+MWE//;
                    my @all_a;
                    my $all;
                    my $i=0;

                    # Collect all possible strings for generator.
                    # The strings are splitted since there are so many possible
                    # forms for pronouns.
                    for my $a ( @{$paradigms{$pos}} ) {
                        if ($i++ > 1000) { push (@all_a, $all); $all=""; $i=0; }
                        if (!($file =~ /propernouns/ && $a !~ /\+Prop/)) {
                            my $string = "$this_abbr+$a";
                            $all .= $string . "\n";
                        }
                    }
                    if ($all) {
                        push (@all_a, $all);
                    }

                    my $to_generate = 0;

                    for my $a (@all_a) {
                        my @number_a = split(/\n+/, $a);
                        $to_generate += $#number_a;
                        @idioms = call_gen($a);
                    }

                    $total_to_generate += $to_generate;
                    my $generated = 0;
                    if (! @idioms) {
                        $all_idioms{$abbr} = 1;
                    }
                    else {
                        for my $idiom (@idioms) {
                            if ( $idiom =~ / /) { # print idiom only if it contains space
                                $generated += 1;
                                $all_idioms{$idiom} = 1;
                            }
                        }
                        $total_generated += $generated;
                    }
                    print STDERR __LINE__ . "\t$pos $generated of $to_generate potential forms for $this_abbr were generated\n"; # DEBUG
                }
            }
        }
    }
    close LEX;
#    print STDERR "\n"; # DEBUG - print a newline after each file and row of .:-+|
}

for my $idiom (sort(keys %all_idioms)) {
    print ABB "$idiom\n";
}

if( ! $noparadigm) {
    print ABB "\nLEXICON NUM\n";
    # assign empty string to the $all variable
    # in order to prevent 'Use of uninitialized value' messages
    my %num_suffix;
    for my $n (@numbers) {
        my $all='';
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

conclusion();
close ABB;

sub conclusion {
    print STDERR "\nThis program sent $total_to_generate strings to $gen_lookup\n";
    print STDERR sprintf("lookup recognised %d (%.2f percent) of these\n", $total_generated, $total_generated/$total_to_generate*100);
}

# Call generator for all word forms.
sub call_gen {
    my ($all) = @_;

    my @idioms;

    my $generated = `echo \"$all\" | $gen_lookup`;
    my @analyses = split(/\n+/, $generated);

    for my $idiom (@analyses) {
        if ($idiom =~ /\+\?/) {
#             print __LINE__ . "\t\tnot accepted $idiom\n";
            next;
        }
#         if ($idiom =~ /[\:\-]/) {
#             next;
#         }
        my ($word, $analysis) = split(/\t/, $idiom);
        if (! $analysis) {
            next;
        }

        push (@idioms, $analysis);
    }

    return @idioms;
}


