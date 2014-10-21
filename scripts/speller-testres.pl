#!/usr/bin/env perl
#
# speller-testres.pl
# Combines speller input and output to test results.
# The default input format is typos.txt.
# Output format is one of:
#    Polderland          (pl)
#    AppleScript/MS Word (mw)
#    Hunspell            (hu)
#    Voikko              (vk)
# Prints to  an XML file.
#
# Usage: speller-testres.pl -h
#
# $Id: speller-testres.pl 83558 2013-11-14 09:01:35Z boerre $

use utf8; # The perl script itself is UTF-8, and this pragma will make perl obey
use strict;
use XML::LibXML;

use Carp qw(cluck confess);
use File::stat;
use Time::localtime;
use File::Basename;
use Text::Brew qw(distance);
use warnings;

my $help;
my $input;
my $input_type;
my $output;
my $print_xml;
my $forced=0;
my $polderland;
my $puki;
my $applescript;
my $foma;
my $hunspell;
my $voikko;
my $hfst;
my $ccat;
my $out_file;
my $typos=1; # Defaults to true - but is it needed? Cf ll 75-76
my $document;
my $version;
my $date;
my @originals;
my $toolversion;
my $memoryuse = "";
my $timeuse   = "";
my @alltime ;

use Getopt::Long;
Getopt::Long::Configure ("bundling");
GetOptions (
            "help|h"             => \$help,
            "input|i=s"          => \$input,
            "output|o=s"         => \$output,
            "document|d=s"       => \$document,
            "pl|p"               => \$polderland,
            "pk"                 => \$puki,
            "mw|m"               => \$applescript,
            "hu|u"               => \$hunspell,
            "fo"                 => \$foma,
            "vkmalaga|vkhfst|vk" => \$voikko,
            "hfst|hf"            => \$hfst,
            "typos|t"            => \$typos,
            "ccat|c"             => \$ccat,
            "forced|f"           => \$forced,
            "date|e=s"           => \$date,
            "xml|x=s"            => \$print_xml,
            "version|v=s"        => \$version,
            "toolversion|w=s"    => \$toolversion,
            "memoryuse|mem=s"    => \$memoryuse,
            "timeuse|ti=s"       => \$timeuse,
            );

if ($help) {
    &print_help;
    exit 1;
}

if (! $input || ! -f $input) { print STDERR "$0: No input file specified.\n"; exit; }
if (! $output) { print STDERR "$0: No speller output file specified.\n"; exit; }

if ($ccat) { read_ccat(); }
else { read_typos(); }

if(! @originals) { exit; }

# Clean $toolversion (ie replace all \n with ', '), to make it printable in all
# cases:
$toolversion =~ s/\n/, /g;
$toolversion =~ s/^, //;

# Convert the system time input data to usable strings in seconds:
@alltime = convert_systime( $timeuse );

if    ($applescript) { $input_type="mw"; read_applescript(); }
elsif ($hunspell)    { $input_type="hu"; read_hunspell();    }
elsif ($foma)        { $input_type="fo"; read_hunspell();    }
elsif ($polderland)  { $input_type="pl"; read_polderland();  }
elsif ($puki)        { $input_type="pk"; read_puki();        }
elsif ($voikko)      { $input_type="vk"; read_voikko();      }
elsif ($hfst)        { $input_type="hf"; read_hfst();        }
else { print STDERR "$0: Give the speller output type: --pl, --pk, --mw, --hu, --fo, --hf or --vk\n"; exit; }

if ($print_xml) { print_xml_output(); }
else { print_output(); }

sub convert_systime {
    my $times = shift(@_);
    if ( $times ) {
        my @alltimes = split /\n/, $times;
        my @real = grep /^real/, @alltimes;
        my @user = grep /^user/, @alltimes;
        my @sys  = grep /^sys/,  @alltimes;
        my $real = convert_systime_to_seconds( @real );
        my $user = convert_systime_to_seconds( @user );
        my $sys  = convert_systime_to_seconds( @sys  );
        return ($real, $user, $sys);
    } else {
        return ("", "", "");
    }
}

sub convert_systime_to_seconds {
    my $time = shift(@_);
    my ($text, $digits) = split /\t/, $time;
    my ($minutes, $seconds) = split /m/, $digits;

    # Remove the final 's' in the input string:
    chop $seconds;
    return $minutes * 60 + $seconds;
}

sub read_applescript {

    print STDERR "Reading AppleScript output from $output\n";
    open(FH, $output);

    my $i=0;
    my @suggestions;
    my @numbers;
    while(<FH>) {
        chomp;

        if (/Prompt\:/) {
            confess "Probably reading Polderland format, start again with option --pl\n\n";
        }
        my ($orig, $error, $sugg) = split(/\t/, $_, 3);
        if ($sugg) { @suggestions = split /\t/, $sugg; }
        $orig =~ s/^\s*(.*?)\s*$/$1/;

        # Some simple adjustments to the input and output lists.
        # First search the output word from the input list.
        my $j = $i;
#        print "$originals[$j]{'orig'}\n";
        while($originals[$j] && $originals[$j]{'orig'} ne $orig) { $j++; }

        # If the output word was not found in the input list, ignore it.
        if (! $originals[$j]) {
            print STDERR "$0: Output word $orig was not found in the input list.\n";
            next;
        }
        # If it was found, mark the words in between.
        elsif ($originals[$j] && $originals[$j]{'orig'} eq $orig) {
            for (my $p=$i; $p<$j; $p++){ $originals[$p]{'error'} = "Error"; }
            $i=$j;
        }

        if ($originals[$i] && $originals[$i]{'orig'} eq $orig) {
            if ($error) { $originals[$i]{'error'} = $error; }
            else { $originals[$i]{'error'} = "not_known"; }
            $originals[$i]{'sugg'} = [ @suggestions ];
            $originals[$i]{'num'} = [ @numbers ];
        }
        $i++;
    }
    close(FH);
}

sub read_hunspell {

    print STDERR "Reading Hunspell output from $output\n";
    open(FH, $output);

    my $i=0;
    my @suggestions;
    my $error;
    #my @numbers;
    my @tokens;
    while(<FH>) {
        chomp;
        # An empty line marks the beginning of next input
        if (/^\s*$/) {
            if ($originals[$i] && ! $originals[$i]{'error'}) {
                $originals[$i]{'error'} = "TokErr";
                $originals[$i]{'tokens'} =  [ @tokens ];
            }
            @tokens = undef;
            pop @tokens;
            $i++;
            next;
        }
        if (! $originals[$i]) {
            cluck "Warning: the number of output words did not match the input\n";
            cluck "Skipping part of the output..\n";
            last;
        }
        # Typical input:
        # & Eskil 4 0: Esski, Eskaleri, Skilla, Eskaperi
        # & = misspelling with suggestions
        # Eskil = original input
        # 4 = number of suggestions
        # 0: offset in input line of orig word
        # The rest is the comma-separated list of suggestion
        my $root;
        my $suggnr;
        my $compound;
        my $orig;
        my $offset;
        my ($flag, $rest) = split(/ /, $_, 2);
      READ_OUTPUT: {
          # Error symbol conversion:
          if ($flag eq '*') {
              $error = 'SplCor' ;
              last READ_OUTPUT;
          }
          if ($flag eq '+') {
              $error = 'SplCor' ;
              $root = $rest;
              last READ_OUTPUT;
          }
          if ($flag eq '-') {
              $error = 'SplCor' ;
              $compound =1;
              last READ_OUTPUT;
          }
          if ($flag eq '#') {
              $error = 'SplErr' ;
              ($orig, $offset) = split(/ /, $rest, 2);
              last READ_OUTPUT;
          }
          if ($flag eq '&') {
              $error = 'SplErr' ;
              my $sugglist;
              ($orig, $suggnr, $offset, $sugglist) = split(/ /, $rest, 4);
              @suggestions = split(/\, /, $sugglist);
          }
      }
        # Debug prints
        #print "Flag: $flag\n";
        #print "ERROR: $error\n";
        #if ($orig) { print "Orig: $orig\n"; }
        #if (@suggestions) { print "Suggs: @suggestions\n"; }

        # remove extra space from original
        if ($orig) { $orig =~ s/^\s*(.*?)\s*$/$1/; }
        if ($offset) { $offset =~ s/\://; }

        if ($error && $error eq "SplCor") {
            $originals[$i]{'error'} = $error;
        } elsif ($orig && $originals[$i] && $originals[$i]{'orig'} ne $orig) {
            # Some simple adjustments to the input and output lists.
            # First search the output word in the input list.
            push (@tokens, $orig);
        } elsif ($originals[$i] && (! $orig || $originals[$i]{'orig'} eq $orig)) {
            if ($error) { $originals[$i]{'error'} = $error; }
            else { $originals[$i]{'error'} = "not_known"; }
            $originals[$i]{'sugg'} = [ @suggestions ];
            if ($suggnr) { $originals[$i]{'suggnr'} = $suggnr; }
            #$originals[$i]{'num'} = [ @numbers ];
        }
    }
    close(FH);
}

sub read_puki {

    print STDERR "Reading Púki output from $output\n";
    open(FH, $output);

    my $i=0;
    my $error;
    my @numbers = ();
    my @suggestions = ();
    while(<FH>) {
        my $line = $_ ;
        chomp $line ;
        my $root;
        my $suggnr;
        my $compound;
        my $orig;
        my $offset;

        # Warn if the output list is longer than the input list:
        if (! $originals[$i]) {
            cluck "Warning: the number of output words did not match the input\n";
            cluck "Skipping part of the output..\n";
            last;
        }

        # If the line starts with a star, the speller didn't recognise the word:
        if ( $line =~ /^\*/ ) {
            $error = 'SplErr' ;
            my $sugglist = "";
            my $empty;
            my $rest;
            ($empty, $orig, $sugglist, $rest) = split(/\*/, $line, 4);
            # if there are suggestions, split them and add empty weights:
            if ( $sugglist ) {
                @suggestions = split(/\#/, $sugglist);
                @numbers = @suggestions;
                my $suggnr = @suggestions;
                my $j;
                for ($j=0; $j<$suggnr; $j++) {
                    $numbers[$j] = ''; # No weights available from Púki
                }
            }
        # Otherwise it is a correct word, according to the speller
        } else {
            $error = 'SplCor' ;
            $orig = $line ;
        }

# Debug prints:
#        print "Speller: $error\n";
#        if ($orig) { print "Orig: $orig\n"; }
#        if (@suggestions) { print "Suggs: @suggestions\n"; }
#        if (@numbers) { print "Nums: @numbers\n"; }

        # remove extra space from original
        if ($orig) { $orig =~ s/^\s*(.*?)\s*$/$1/; }

        if ($error eq "SplCor") {
            $originals[$i]{'error'} = $error;
        }
        # Some simple adjustments to the input and output lists.
        # First search the output word in the input list.

# Debug prints:
#        print "$originals[$j]{'orig'}\n";
#        print "-----------\n";

        # Assign error codes, suggestions and weights to the global entry list:
        if ($originals[$i] && $originals[$i]{'orig'} eq $orig) {
            if ($error) {
                # Assign the proper error code:
                $originals[$i]{'error'} = $error;
            }
            else {
                # Assign a fallback code if there was no error code:
                $originals[$i]{'error'} = "not_known";
            }
            $originals[$i]{'sugg'} = [ @suggestions ]; # Store each suggestion
            if ($suggnr) { $originals[$i]{'suggnr'} = $suggnr; } # # of suggs
            $originals[$i]{'num'} = [ @numbers ]; # Store the weight of the sugg
        }
        @suggestions = ();
        @numbers = ();
        $error = '';
        $i++;
    }
    close(FH);
    print STDERR "\n";
}


sub read_polderland {

    print STDERR "$0: Reading Polderland output from $output\n";
    open(FH, $output) or die "Could not open file $output. $!";

    # Read until "Prompt"
    while(<FH>) {
        last if (/Prompt/);
    }

    my $i=0;
    my $line = $_;

    if ($line) {
        my $orig;
        # variable to check whether the suggestions are already started.
        # this is because the line "check returns" may be missing.
        my $reading=0;

        if ($line =~ /Check returns/) {
            ($orig = $line) =~ s/.*?Check returns .*? for \'(.*?)\'\s*$/$1/;
            $reading=1;
        }
        elsif ($line =~ /Getting suggestions/) {
            $reading=1;
            ($orig = $line) =~ s/.*?Getting suggestions for (.*?)\.\.\.\s*$/$1/;
        }
        else {
            confess "could not read $output: $line";
        }

        if (!$orig || $orig eq $line) {
            confess "Probably wrong format, start again with --mw\n";
        }

        while($originals[$i] && $originals[$i]{'orig'} ne $orig) {
            #print STDERR "$0: Input and output mismatch, removing $originals[$i]{'orig'}.\n";
            splice(@originals,$i,1);
        }

        my @suggestions;
        my @numbers;

        while(<FH>) {

            $line = $_;
            next if ($reading && /Getting suggestions/);
            next if ($line =~ /End of suggestions/);
            last if ($line =~ /Terminate/);

            if ($line =~ /Suggestions:/) {
                $originals[$i]{'error'} = "SplErr";
            }

            if ($line =~ /Check returns/ || $line =~ /Getting suggestions/) {
                $reading=1;
                #Store the suggestions from the last round.
                if (@suggestions) {
                    $originals[$i]{'sugg'} = [ @suggestions ];
                    $originals[$i]{'num'} = [ @numbers ];
                    $originals[$i]{'error'} = "SplErr";
                    @suggestions = ();
                    pop @suggestions;
                    @numbers = ();
                    pop @numbers;
                    $reading = 0;
                }
                elsif (! $originals[$i]{'error'}) {
                    $originals[$i]{'error'} = "SplCor";
                }

                if ($line =~ /Check returns/) {
                    $reading = 1;
                    ($orig = $line) =~ s/^.*?Check returns .* for \'(.*?)\'\s*$/$1/;
                }
                elsif (! $reading && $line =~ /Getting suggestions/) {
                    $reading = 1;
                    ($orig = $line) =~ s/^.*?Getting suggestions for (.*?)\.\.\.\s*$/$1/;
                }
                $i++;

                # Some simple adjustments to the input and output lists.
                # First search the output word in the input list.
                my $j = $i;
                while($originals[$j] && $originals[$j]{'orig'} ne $orig) {
                    $j++;
                }

                # If the output word was not found in the input list, ignore it.
                if (! $originals[$j]) {
                    cluck "WARNING: Output word $orig was not found in the input list.\n";
                    $orig=undef;
                    $i--;
                    next;
                }

                # If it was found later, mark the intermediate input as correct.
                elsif($j != $i) {
                    my $k=$j-$i;
                    for (my $p=$i; $p<$j; $p++){
                        $originals[$p]{'error'}="SplCor";
                        $originals[$p]{'sugg'}=();
                        pop @{ $originals[$p]{'sugg'} };
                        #print STDERR "$0: Removing input word $originals[$p]{'orig'}.\n";
                    }
                    $i=$j;
                }
                next;
            }

            next if (! $orig);
            chomp $line;
            my ($num, $suggestion) = split(/\s+/, $line, 2);
            #print STDERR "$_ SUGG $suggestion\n";
            if ($suggestion) {
                push (@suggestions, $suggestion);
                push (@numbers, $num);
            }
        }
        close(FH);
        if ($orig) {
            #Store the suggestions from the last round.
            if (@suggestions) {
                $originals[$i]{'sugg'} = [ @suggestions ];
                $originals[$i]{'num'} = [ @numbers ];
                $originals[$i]{'error'} = "SplErr";
                @suggestions = ();
                pop @suggestions;
                @numbers = ();
                pop @numbers;
            }
            elsif (! $originals[$i]{'error'}) {
                $originals[$i]{'error'} = "SplCor";
            }
        }
        $i++;
        while($originals[$i]) {
            $originals[$i]{'error'} = "SplCor"; $i++;
        }
    }
}

sub read_voikko {

    print STDERR "$0: Reading Voikko output from $output\n";
    open(FH, $output) or die "Could not open file $output. $!";

    my $i=0;
    my $line;

    my $orig = "";
    # variable to check whether the suggestions are already started.
    # this is because the line "check returns" may be missing.
    my $reading=0;

    my @suggestions;
    my @numbers;
    my $num = 0;

    while(<FH>) {

        $line = $_;
        chomp($line);

        if ($line =~ s/^S: //) {
            push(@suggestions, $line);
        };

        if ($line =~ /^W: / || $line =~ /^C: /) {
            #Store the suggestions from the last round.
            if (@suggestions) {
                $originals[$i]{'sugg'} = [ @suggestions ];
                @suggestions = ();
            }
            $i++;
            if ($line =~ s/^W: //) {
                $originals[$i]{'error'}="SplErr";
                $orig = $line;
            }
            elsif ($line =~ s/^C: //) {
                $originals[$i]{'error'}="SplCor";
                $orig = $line;
            }
            # Some simple adjustments to the input and output lists.
            # First search the output word in the input list.
            my $j = $i;
            while($originals[$j] && $originals[$j]{'orig'} ne $orig) { $j++; }

            # If the output word was not found in the input list, ignore it.
            if (! $originals[$j]) {
                cluck "WARNING: Output word $orig was not found in the input list.\n";
                $orig=undef;
                $i--;
                next;
            }

            # If it was found later, mark the intermediate input as correct.
            elsif($j != $i) {
                my $k=$j-$i;
                for (my $p=$i; $p<$j; $p++){
                    $originals[$p]{'error'}="SplCor";
                    $originals[$p]{'sugg'}=();
                    pop @{ $originals[$p]{'sugg'} };
                    #print STDERR "$0: Removing input word $originals[$p]{'orig'}.\n";
                }
                $i=$j;
            }
            next;
        }

        next if (! $orig);
    }
    close(FH);
    if ($orig) {
        #Store the suggestions from the last round.
        if (@suggestions) {
            $originals[$i]{'sugg'} = [ @suggestions ];
            $originals[$i]{'num'} = [ @numbers ];
            $originals[$i]{'error'} = "SplErr";
            @suggestions = ();
            pop @suggestions;
            @numbers = ();
            pop @numbers;
        }
        elsif (! $originals[$i]{'error'}) { $originals[$i]{'error'} = "SplCor"; }
    }
    $i++;
    while($originals[$i]) { $originals[$i]{'error'} = "SplCor"; $i++; }
}

sub read_hfst {

    my $eol = $/ ; # store default value of record separator
    $/ = "";       # set record separator to blank lines

    print STDERR "Reading HFST output from $output\n";
    open(FH, $output);

    my $i=0;
#    my $hfst-ospell-version = <FH>; # Only if we know we have a real lex version info string!

    while(<FH>) {
        # Typical input:
        #
        # Unable to correct "beena"!
        #
        # Corrections for "girja":
        # girje    1
        # girju    1
        # girji    1
        # girjá    1
        #
        # "girji" is in the lexicon
        #

        my @suggestions;
        my @numbers;
        my @tokens;
        my $error     = "PARSINGERROR";

        my $root      = "";
        my $suggnr    = "";
        my $compound  = "";
        my $orig      = "";
        my $offset    = "";
        my $flag      = "FLAG";
        my $rest      = "";
        my ($firstline, $suggs) = split(/\n/, $_, 2);

        # Speller didn't recognise, no suggestions provided:
        if ($firstline  =~ m/Unable to correct/ ) {
            ($flag, $orig, $rest) = split(/"/, $firstline, 3); #"# Reset sntx clr
            $error = 'SplErr' ;
        # Speller did recognise the input:
        } elsif ($firstline  =~ m/is in the lexicon/ ) {
            ($rest, $orig, $flag) = split(/"/, $firstline, 3); #"# Reset sntx clr
            $error = 'SplCor' ;
        # Speller didn't recognise, suggestions provided on the following lines:
        } elsif ($firstline  =~ m/Corrections for/ ) {
            ($flag, $orig, $rest) = split(/"/, $firstline, 3); #"# Reset sntx clr
            @suggestions = split(/\n/, $suggs);
            $error = 'SplErr' ;
            @numbers = @suggestions;
            my $size = @suggestions;
            my $j;
            for ($j=0; $j<$size; $j++) {
                ($suggestions[$j], $numbers[$j]) = split(/\s+/, $suggestions[$j]);
#                cluck "INFO: Version string is: $version\n";
            }
        } else {
            cluck "Warning: Something is wrong with the input data!\n";
        }

# Debug prints:
#        print "Flag: $flag\n";
#        print "ERROR: $error\n";
#        if ($orig) { print "Orig: $orig\n"; }
#        if (@suggestions) { print "Suggs: @suggestions\n"; }
#        if (@numbers) { print "Nums: @numbers\n"; }

        # remove extra space from original
        if ($orig) { $orig =~ s/^\s*(.*?)\s*$/$1/; }

        # Some simple adjustments to the input and output lists.
        # First search the output word from the input list.
        my $j = $i;

# Debug prints:
#        print "$originals[$j]{'orig'}\n";
#        print "-----------\n";

        while($originals[$j] && $originals[$j]{'orig'} ne $orig) { $j++; }

        # If the output word was not found in the input list, ignore it.
        if (! $originals[$j]) {
            print STDERR "$0: Output word $orig was not found in the input list.\n";
            next;
        }
        # If it was found, mark the words in between.
        elsif ($originals[$j] && $originals[$j]{'orig'} eq $orig) {
            for (my $p=$i; $p<$j; $p++){ $originals[$p]{'error'} = "Error"; }
            $i=$j;
        }

        if ($originals[$i] && $originals[$i]{'orig'} eq $orig) {
            if ($error) { $originals[$i]{'error'} = $error; }
            else { $originals[$i]{'error'} = "not_known"; }
            $originals[$i]{'sugg'} = [ @suggestions ];
            $originals[$i]{'num'} = [ @numbers ];
            $i++;
        }
    @suggestions = ();
    @numbers = ();
    $error = '';
    }
    close(FH);
    $/ = $eol; # restore default value of record separator
}

# This function reads the correct data to evaluate the performance of the speller
# The data is structured as in the typos file, hence the name.
sub read_typos {

    print STDERR "Reading typos from $input\n";
    open(FH, "<$input") or die "Could not open $input";

    while(<FH>) {
        chomp;
        next if (/^[\#\!]/);
        next if (/^\s*$/);
#        s/[\#\!].*$//; # not applicable anymore - we want to preserve comments
        my ($testpair, $comment) = split(/[\#\!]\s*/);
        my ($orig, $expected) = split(/\t+/,$testpair);
#        print STDERR "Original: $orig\n";
#        print STDERR "Expected: $expected\n" if $expected;
#        print STDERR "Comment:  $comment\n" if $comment;
        if ( $orig ) {
            my $rec = {};
            $orig =~ s/\s*$//;
            $rec->{'orig'} = $orig;
            if ($expected) {
                $expected =~ s/\s*$//;
                $rec->{'expected'} = $expected;
            }
            if ($comment) {
                $comment =~ s/\s*$//;
                $comment =~ s/^\s*//;
                # IF BUG ID: either numbers only, or numbers followed by whitespace,
                # or, IF PARADIGM, string followed by inflection tags, no whitespace
                if ($comment =~ m/^[\#\!]*\d+$/  ||
                    $comment =~ m/^[\#\!]*\d+\s/ ||
                    $comment =~ m/^[\#\!]*\w+\+/) {
                    my $bugID = "";
                    my $restcomment = "";
                    if ($comment =~ m/\s+/ ) {
                        ($bugID, $restcomment) = split(/\s+/,$comment,2);
                    } else {
                        ($bugID, $restcomment) = split(/\+/,$comment,2);
                    }
                    $bugID =~ s/^[\#\!]//;
                    $rec->{'bugID'} = $bugID;
                    #print STDERR $bugID.".";
                    $comment = $restcomment;
                }
                # If the comment was a bug ID only, there's no comment any more
                if ($comment) {
                    $comment =~ s/^[-\!\# ]*//;
    #                print STDERR $comment.".";
                    $rec->{'comment'} = $comment;
                }
            }
            push @originals, $rec;
        }
    }
    close(FH);
#    print STDERR " - end of bugs.\n";
}

sub print_xml_output {

    if (! $print_xml) {
        die "Specify the output file with option --xml=<file>\n";
    }

    my $doc = XML::LibXML::Document->new('1.0', 'utf-8');

    my $spelltestresult = $doc->createElement('spelltestresult');

    my $header = $doc->createElement('header');

    $spelltestresult->appendChild($header);

    # Get version info if it's available
    my $rec = $originals[0];
    if ($rec->{'orig'} eq "nuvviD" || $rec->{'orig'} eq "nuvviDspeller") {
#        cluck "INFO: nuvviDspeller found.\n";
        shift @originals;
        if ($rec->{'sugg'}) {
#            cluck "INFO: nuvviDspeller contains suggestions.\n";
            my @suggestions = @{$rec->{'sugg'}};
            for my $sugg (@suggestions) {
#                print "SUGG $sugg\n";
                if ($sugg && $sugg =~ /[0-9]/) {
                    $version = $sugg;
#                    cluck "INFO: Version string is: $version\n";
                    last;
                }
            }
        } else {
#            cluck "INFO: nuvviDspeller contains NO suggestions.\n";
        }
    }

    # Print some header information
    my $tool = $doc->createElement('tool');
    $tool->setAttribute('lexversion' => $version);
    $tool->setAttribute('toolversion' => $toolversion);
    $tool->setAttribute('type' => $input_type);
    $tool->setAttribute('memoryusage' => $memoryuse);
    $tool->setAttribute('realtime' => $alltime[0]);
    $tool->setAttribute('usertime' => $alltime[1]);
    $tool->setAttribute('systime' =>  $alltime[2]);
    $header->appendChild($tool);

    # what was the checked document
    my $docu = $doc->createElement('document');
    if (!$document) {
        $document=basename($input);
    }
    $docu->appendTextNode($document);
    $header->appendChild($docu);

    # The date is the timestamp of speller output file if not given.
    my $date_elt = $doc->createElement('date');
    if (!$date ) {
        $date = ctime(stat($output)->mtime);
        #print "file $input updated at $date\n";
    }
    $date_elt->appendTextNode($date);
    $header->appendChild($date_elt);

    # Start the results-section
    my $results = $doc->createElement('results');

    for my $rec (@originals) {

        my $word = $doc->createElement('word');
        if ($rec->{'orig'}) {
            my $original = $doc->createElement('original');
            $original->appendTextNode($rec->{'orig'});
            $word->appendChild($original);
        }
        if ($rec->{'expected'}){
            my $expected = $doc->createElement('expected');
            $expected->appendTextNode($rec->{'expected'});
            $word->appendChild($expected);
            my $distance=distance($rec->{'orig'},$rec->{'expected'},{-output=>'distance'});
            my $edit_dist = $doc->createElement('edit_dist');
            $edit_dist->appendTextNode($distance);
            $word->appendChild($edit_dist);
        }
        if ($rec->{'error'}){
            my $error = $doc->createElement('status');
            $error->appendTextNode($rec->{'error'});
            $word->appendChild($error);
        }
        if ($rec->{'forced'}){ $word->setAttribute('forced' => "yes"); }

        if ($rec->{'error'} && $rec->{'error'} eq "SplErr") {
            my $suggestions_elt = $doc->createElement('suggestions');
            my $sugg_count=0;
            if ($rec->{'sugg'}) { $sugg_count = scalar @{ $rec->{'sugg'}} };
            $suggestions_elt->setAttribute('count' => $sugg_count);
            my $position = $doc->createElement('position');
            my $pos=0;
            my $near_miss_count = 0;
            if ($rec->{'suggnr'}) { $near_miss_count = $rec->{'suggnr'}; }
            if ($rec->{'sugg'}) {

                my @suggestions = @{$rec->{'sugg'}};
                my @numbers;
                if ($rec->{'num'}) { @numbers =  @{$rec->{'num'}}; }
                for my $sugg (@suggestions) {
                    next if (! $sugg);
                    my $suggestion = $doc->createElement('suggestion');
                    $suggestion->appendTextNode($sugg);
                    if ($rec->{'expected'} && $sugg eq $rec->{'expected'}) {
                        $suggestion->setAttribute('expected' => "yes");
                    }
                    my $num;
                    if (@numbers) {
                        $num = shift @numbers;
                        $suggestion->setAttribute('penscore' => $num);
                    }
                    if ($near_miss_count > 0) {
                        $suggestion->setAttribute('miss' => "yes");
                        $near_miss_count--;
                    }

                    $suggestions_elt->appendChild($suggestion);
                }
                my $i=0;
                if ($rec->{'expected'}) {
                    while ($suggestions[$i] && $rec->{'expected'} ne $suggestions[$i]) { $i++; }
                    if ($suggestions[$i]) { $pos = $i+1; }
                }
            }
            $position->appendTextNode($pos);
            $word->appendChild($position);
            $word->appendChild($suggestions_elt);
        }
        if ($rec->{'tokens'}) {
            my @tokens = @{$rec->{'tokens'}};
            my $tokens_num = scalar @tokens;
            my $tokens_elt = $doc->createElement('tokens');
            $tokens_elt->setAttribute('count' => $tokens_num);
            for my $t (@tokens) {
                my $token_elt = $doc->createElement('token');
                $token_elt->appendTextNode($t);
                $tokens_elt->appendChild($token_elt);
            }
            $word->appendChild($tokens_elt);
        }
        if ($rec->{'bugID'}){
            my $bugID = $doc->createElement('bug');
            $bugID->appendTextNode($rec->{'bugID'});
            $word->appendChild($bugID);
#            print STDERR ".";
        }
        if ($rec->{'comment'}){
            my $comment = $doc->createElement('comment');
            $comment->appendTextNode($rec->{'comment'});
            $word->appendChild($comment);
        }

        $results->appendChild($word);
    }

    $spelltestresult->appendChild($results);

    $doc->setDocumentElement($spelltestresult);
    $doc->toFile($print_xml, 1);
}

sub print_output {

    for my $rec (@originals) {
        my @suggestions;
        if ($rec->{'orig'}) { print "Orig: $rec->{'orig'} | "; }
        if ($rec->{'expected'}) { print "Expected: $rec->{'expected'} | "; }
        if ($rec->{'error'}) { print "Error: $rec->{'error'} | "; }
        print "Forced: $forced | ";
        if ($rec->{'sugg'}) {
            print "Suggs: @{$rec->{'sugg'}} | ";
            my @suggestions = @{$rec->{'sugg'}};
            my $i=0;
            if ($rec->{'expected'}) {
                while ($suggestions[$i] && $rec->{'expected'} ne $suggestions[$i]) { $i++; }
                if ($suggestions[$i]) { print $i+1; }
            }
        }
        print "\n";
    }
}
sub print_help {
    print << "END";
Combines speller input and output into an xml file.
Usage: speller-testres.pl [OPTIONS]

--help            Print this help text and exit.
-h

--input=<file>    The original speller input.
-i <file>

--output=<file>   The speller output.
-o <file>

--document=<name> The name of the original speller input, if not the input file name.
-d <name>

--pl              The speller output is in Polderland format.
-p

--pk              The speller output is in the Icelandic Púki format.

--mw              The speller output is in AppleScript+MSWord format.
-m

--hu              The speller output is in Hunspell format.
--fo              (This includes also the foma-trie speller)
-u

--vkmalaga        The speller output is in Voikko format.
--vkhfst
--vk

--ccat            The input is from ccat, the default is typos.txt. Not yet in use.
-c

--forced          The speller was forced to make suggestions.
-f

--date <date>     Date when the test was run, if not the output file timestamp.
-e

--xml=<file>      Print output in xml to file <file>.
-x

--version=<num>   Speller version information.
-v <num>

--toolversion     Hyphenator tool version information.
-w

--memoryuse       Max memory consumption of the speller process.
--mem

--timeuse         Time used by the speller process, as reported by 'time'.
--ti
END

}
