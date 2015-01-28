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
#use Data::Dumper; # for DEBUGging %paradigms

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

my %lex_pos = ( 'nouns' => 'N',
                'adverbs' => 'Adv',
                'adjectives' => 'Adj',
                'propernouns' => 'N+Prop',
                'verbs' => 'V',
                'pronouns' => 'Pron',
                'numerals' => 'Num',
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


for my $file (@lex_file_names) {

    print STDERR "$0: reading file $file\n";

    my $pos;
    for my $key (keys %lex_pos) {
#         print "138 $key $file\n";
        if ($file =~ /$key\.lexc/) {
            $pos = $lex_pos{$key};
            print "140 $pos $file\n";
        }
    }

    my $x=0;
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
                    print STDERR "165 Ingen paradigme!\n"; # DEBUG
                }
                else {
                    print STDERR "$abbr $pos $file\n"; # DEBUG
                    my @all_a;
                    my $all;
                    my $i=0;

                    # Collect all possible strings for generator.
                    # The strings are splitted since there are so many possible
                    # forms for pronouns.
                    for my $a ( @{$paradigms{$pos}} ) {
#                         print "177 $a\n";
                        if ($i++ > 1000) { push (@all_a, $all); $all=""; $i=0; }
                        my $string = "$abbr+$a";
                        $string =~ s/\+MWE//;
                        $all .= $string . "\n";
#                        print STDERR "+"; # DEBUG
                    }
                    if ($all) {
#                        print STDERR "184\n"; # DEBUG
                        push (@all_a, $all);
                    }
                    for my $a (@all_a) {
                        $x++;
                       print STDERR "\tgenerating forms for $abbr $file\n"; # DEBUG
                        call_gen(\@idioms,$a);
                    }
                    if (! @idioms) {
#                        print STDERR ":"; # DEBUG
                        print ABB "$abbr\n";
                    }
                    else {
                        for my $idiom (@idioms) {
                            if ( $idiom =~ / /) { # print idiom only if it contains space
                                print ABB "$idiom\n";
#                                print STDERR "|"; # DEBUG
                            }
                        }
                    }
                }
            }
        }
    }
    close LEX;
#    print STDERR "\n"; # DEBUG - print a newline after each file and row of .:-+|
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


# Call generator for all word forms.
sub call_gen {
    my ($tmp_aref, $all) = @_;

#     print STDERR "248 $gen_lookup\n";
#     print STDERR "249 $all\n";
    my $generated = `echo \"$all\" | $gen_lookup`;
#     print STDERR "251 $generated\n";
#     die "AHHHHHHHHHHH!!!!!";
    my @analyses = split(/\n+/, $generated);

    my $useless = 0;
    my $not_wanted_sign = 0;
    my $contains_tab = 0;
    my $usefull = 0;
    for my $idiom (@analyses) {
        if ($idiom =~ /\+\?/) {
            $useless++;
            next;
        }
        if ($idiom =~ /[\:\-]/) {
            $not_wanted_sign++;
            next;
        }
        my ($word, $analysis) = split(/\t/, $idiom);
        if (! $analysis) {
            $contains_tab++;
            next;
        }

        push (@$tmp_aref, $analysis);
        $usefull++;
    }
    print STDERR "\ttotal analyses: $#analyses\n";
    print STDERR "\t\tusefull: $usefull\n";
    print STDERR "\t\tuseless: $useless\n";
    print STDERR "\t\tnot_wanted_sign: $not_wanted_sign\n";
    print STDERR "\t\tcontains_tab: $contains_tab\n";
}

close ABB;

