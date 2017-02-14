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
# $Id$

use warnings;
use utf8; # The perl script itself is UTF-8, and this pragma will make perl obey
use strict;

use Carp qw(cluck confess);
use File::stat;
use Time::localtime;
use File::Basename;
use Text::Brew qw(distance);
use XML::LibXML;

my $help;
my $input;
my $input_type;
my $output;
my $lang;
my $print_xml;
my $forced=0;
my $engine = "";
my $ccat;
my $out_file;
my $typos=1; # Defaults to true - but is it needed? Cf ll 75-76
my $document;
my $version;
my $date;
my @originals;
my $toolversion;
my $corpusversion;
my $memoryuse = "";
my $timeuse   = "";
my $suggtiming = "";
my $corrsugg = 0; # whether to set the corrsugg attribute in word elements

use Getopt::Long;
Getopt::Long::Configure ("bundling");
GetOptions (
            "help|h"             => \$help,
            "input|i=s"          => \$input,
            "output|o=s"         => \$output,
            "document|d=s"       => \$document,
            "engine|eng=s"       => \$engine,
            "typos|t"            => \$typos,
            "ccat|c"             => \$ccat,
            "forced|f"           => \$forced,
            "date|e=s"           => \$date,
            "lang|l=s"           => \$lang,
            "xml|x=s"            => \$print_xml,
            "version|v=s"        => \$version,
            "toolversion|w=s"    => \$toolversion,
            "corpusversion|co=s" => \$corpusversion,
            "memoryuse|mem=s"    => \$memoryuse,
            "timeuse|ti=s"       => \$timeuse,
            "suggtiming|st=s"    => \$suggtiming,
            "corrsugg"           => \$corrsugg,
            );

if ($help) {
    &print_help;
    exit 1;
}

if (! $input || ! -f $input) {
    print STDERR "$0: No input file specified.\n"; exit;
}

if (! $output) {
    print STDERR "$0: No speller output file specified.\n"; exit;
}

if ((-s $output) == 0) {
    die "Warning: No output from speller\nCheck that the testing setup works as it should\n";
}

if ($ccat) {
    read_ccat();
} else {
    read_typos();
}

if(! @originals) {
    exit;
}

# Clean $toolversion (ie replace all \n with ', '), to make it printable in all
# cases:
$toolversion =~ s/\n/, /g;
$toolversion =~ s/^, //;

if ( $engine eq "mw") {
    $input_type="mw";
    read_applescript();
} elsif ( $engine eq "hu") {
    $input_type="hu";
    read_hunspell();
} elsif ( $engine eq "fo") {
    $input_type="fo";
    read_hunspell();
} elsif ( $engine eq "pl") {
    $input_type="pl";
    read_polderland();
} elsif ( $engine eq "pk") {
    $input_type="pk";
    read_puki();
} elsif ( $engine eq "vk") {
    $input_type="vk";
    read_voikko();
} elsif ( $engine eq "hf") {
    $input_type="hf";
    read_hfst();
} elsif ( $engine eq "to") {
    $input_type="to";
    read_hfst_tino();
} else {
    print STDERR
        "$0: Specify the speller engine: --engine=[pl|pk|mw|hu|fo|hf|to|vk]\n";
    exit;
}

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
    }
}

if ($print_xml) {
    print_xml_output();
} else {
    print_output();
}

sub convert_systime {
    my %time_hash = ('realtime', '0', 'usertime', '0', 'systime', '0');

    # Open and read file, storing content in string variable:
    local $/ = undef;
    open FILE, $timeuse or die "Couldn't open file: $!";
    binmode FILE;
    my $timeusestring = <FILE>;
    close FILE;

    # Process the string variable containing the time measures:
    my @timelines = split(/\n/, $timeusestring);
    for my $timeline (@timelines) {
        chomp $timeline;
        if ($timeline =~ /^real/) {
            $time_hash{'realtime'} = convert_systime_to_seconds($timeline);
        } elsif ($timeline =~ /^user/) {
            $time_hash{'usertime'} = convert_systime_to_seconds($timeline);
        } elsif ($timeline =~ /^sys/) {
            $time_hash{'systime'} = convert_systime_to_seconds($timeline);
        }
    }

    return \%time_hash;
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
    while (<FH>) {
        chomp;

        if (/Prompt\:/) {
            confess "Probably reading Polderland format, start again with option --pl\n\n";
        }
        my ($orig, $error, $sugg) = split(/\t/, $_, 3);
        if ($sugg) {
            @suggestions = split /\t/, $sugg;
        }
        $orig =~ s/^\s*(.*?)\s*$/$1/;

        # Some simple adjustments to the input and output lists.
        # First search the output word from the input list.
        my $j = $i;
#        print "$originals[$j]{'orig'}\n";
        while ($originals[$j] && $originals[$j]{'orig'} ne $orig) {
            $j++;
        }

        # If the output word was not found in the input list, ignore it.
        if (! $originals[$j]) {
            print STDERR "$0: Output word $orig was not found in the input list.\n";
            next;
        }
        # If it was found, mark the words in between.
        elsif ($originals[$j] && $originals[$j]{'orig'} eq $orig) {
            for (my $p=$i; $p<$j; $p++){
                $originals[$p]{'error'} = "Error";
            }
            $i=$j;
        }

        if ($originals[$i] && $originals[$i]{'orig'} eq $orig) {
            if ($error) {
                $originals[$i]{'error'} = $error;
            } else {
                $originals[$i]{'error'} = "not_known";
            }
            $originals[$i]{'sugg'} = [ @suggestions ];
            $originals[$i]{'num'} = [ @numbers ];
        }
        $i++;
    }
    close(FH);
}

=pod

=begin html

<p>Every input line to hunspell produces one or more lines of output
containing status and results produced by hunspell ended by an empty line.</p>

<p>Exceptions to this rule are:</p>

<ul>
    <li>input lines starting with - or + produce no output</li>
    <li>mail and web adresses produce only an empty line</li>
</ul>

<p>The speller output file is read into an array, @outlines</p>

<p>To keep input and output in sync, for each input, check the input word</p>

<ul>
    <li>if input starts with -, go the next input, ignore output line</li>
    <li>if input is a mail or webadress, go to the next input and output line</li>
    <li>on other input</li>
    <ul>
        <li>read output lines until an empty line is hit</li>
        <ul>
            <li>if there is one output line, set the data</li>
            <li>if there are more output lines, look for an error flag,
            ignore suggestions, as this will not make sense</li>
        </ul>
    </ul>
</ul>

=end html

=cut

sub read_hunspell {
    print STDERR "Reading Hunspell output from $output\n";
    open(FH, '<', $output);
    my @lines = <FH>;
    my $outlines = scalar(@lines);

    # Start indexing output at the second line, because the first
    # line is only a message from hunspell that it is alive
    my $out_i = 1;

    my $origsize = scalar(@originals);
    # Input is indexed from the first item
    my $orig_i = 0;

    while ($orig_i < $origsize) {
        if ($originals[$orig_i]{'orig'} =~ /^[-+]/) {
            $originals[$orig_i]{'error'} = "SplCor";
        } elsif ($originals[$orig_i]{'orig'} =~ /@|^http:\/\//) {
            $originals[$orig_i]{'error'} = "SplCor";
            # compensate for the empty line produced in the output
            $out_i++;
        } else {
            my @errorlines;
            while ($out_i < $outlines && $lines[$out_i] !~ /^$/) {
                push(@errorlines, $lines[$out_i]);
                $out_i++;
            }

            my $lines_len = scalar(@errorlines);
            if ($lines_len == 1) {
                handle_hunspell_line($errorlines[0], $orig_i);
            } elsif ($lines_len > 1) {
                $originals[$orig_i]{'error'} = handle_hunspell_lines(\@errorlines);
            } else {
                die "orig: $originals[$orig_i]{'orig'} no: $orig_i spoutline: $out_i whoops, out of sync!\n";
            }

            # compensate for the empty line
            $out_i++;
        }
        # ready for the next input
        $orig_i++;
    }
}

sub handle_hunspell_line {
    my ($errorline, $orig_i) = @_;

    chomp $errorline;
    my ($flag, $rest) = split(/ /, $errorline, 2);

    if ($flag eq '*') {
        $originals[$orig_i]{'error'} = 'SplCor';
    } elsif ($flag eq '+') {
        $originals[$orig_i]{'error'} = 'SplCor';
    } elsif ($flag eq '-') {
        $originals[$orig_i]{'error'} = 'SplCor';
    } elsif ($flag eq '#') {
        $originals[$orig_i]{'error'} = 'SplErr';
    } elsif ($flag eq '&') {
        $originals[$orig_i]{'error'} = 'SplErr';
        my @parts = split(/ /, $rest, 4);

        if (! $parts[0] eq $originals[$orig_i]{'orig'}) {
            die "$parts[0], $originals[$orig_i]{'orig'}\n";
        }

        my @sugglist = split(/\, /, $parts[3]);
        $originals[$orig_i]{'sugg'} = [ @sugglist ];
        $originals[$orig_i]{'suggnr'} = scalar(@sugglist);
    }
}

sub handle_hunspell_lines {
    my ($errorlines_ref) = @_;

    my $errors = "#&";
    my $error = 'SplCor';
    for my $errorline (@{$errorlines_ref}) {
        chomp $errorline;
        my @parts = split(/ /, $errorline, 2);
        if (index($errors, $parts[0]) != -1) {
            $error = 'SplErr';
            last;
        }
    }

    return $error;
}

sub read_puki {

    print STDERR "Reading Púki output from $output\n";
    open(FH, $output);

    my $i=0;
    my $error;
    my @numbers = ();
    my @suggestions = ();
    while (<FH>) {
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
        if (length($orig) > 0) {
            $orig =~ s/^\s*(.*?)\s*$/$1/;
        }

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
            } else {
                # Assign a fallback code if there was no error code:
                $originals[$i]{'error'} = "not_known";
            }
            $originals[$i]{'sugg'} = [ @suggestions ]; # Store each suggestion
            if ($suggnr) {
                $originals[$i]{'suggnr'} = $suggnr;
            } # # of suggs
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
    while (<FH>) {
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
        } elsif ($line =~ /Getting suggestions/) {
            $reading=1;
            ($orig = $line) =~ s/.*?Getting suggestions for (.*?)\.\.\.\s*$/$1/;
        } else {
            confess "could not read $output: $line";
        }

        if (!$orig || $orig eq $line) {
            confess "Probably wrong format, start again with --mw\n";
        }

        while ($originals[$i] && $originals[$i]{'orig'} ne $orig) {
            #print STDERR "$0: Input and output mismatch, removing $originals[$i]{'orig'}.\n";
            splice(@originals,$i,1);
        }

        my @suggestions;
        my @numbers;

        while (<FH>) {

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
                } elsif (! $originals[$i]{'error'}) {
                    $originals[$i]{'error'} = "SplCor";
                }

                if ($line =~ /Check returns/) {
                    $reading = 1;
                    ($orig = $line) =~ s/^.*?Check returns .* for \'(.*?)\'\s*$/$1/;
                } elsif (! $reading && $line =~ /Getting suggestions/) {
                    $reading = 1;
                    ($orig = $line) =~ s/^.*?Getting suggestions for (.*?)\.\.\.\s*$/$1/;
                }
                $i++;

                # Some simple adjustments to the input and output lists.
                # First search the output word in the input list.
                my $j = $i;
                while ($originals[$j] && $originals[$j]{'orig'} ne $orig) {
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
        if (length($orig) > 0) {
            #Store the suggestions from the last round.
            if (@suggestions) {
                $originals[$i]{'sugg'} = [ @suggestions ];
                $originals[$i]{'num'} = [ @numbers ];
                $originals[$i]{'error'} = "SplErr";
                @suggestions = ();
                pop @suggestions;
                @numbers = ();
                pop @numbers;
            } elsif (! $originals[$i]{'error'}) {
                $originals[$i]{'error'} = "SplCor";
            }
        }
        $i++;
        while ($originals[$i]) {
            $originals[$i]{'error'} = "SplCor"; $i++;
        }
    }
}

sub read_voikko {
    # Read output from voikkospell -s
    #
    # There are no empty lines in the voikkospell output
    # If voikkospell recognises an input word, the output is:
    # C: <recognised_word>
    # If voikkospell does not recognise the input word, the output is:
    # W: <unrecognised_word>
    # S: <sugg1>
    # S: <sugg2>
    # S: <sugg3>
    # S: <sugg4>
    # S: <sugg5>

    print STDERR "$0: Reading Voikko output from $output\n";
    open(FH, $output) or die "Could not open file $output. $!";

    my $index=-1;
    my $line;
    my $orig;
    my @suggestions;

    while (<FH>) {

        $line = $_;
        chomp($line);

        if ($line =~ s/^S: //) {
            # We hit a suggestions from voikkospell
            push(@suggestions, $line);
        } elsif ($line =~ /^W: / || $line =~ /^C: /) {
            # We hit an input word to voikkospell

            # Store the suggestions belonging to $orig.
            # When the first input word is hit, suggestions will be empty.
            # There will therefore be no attempt to add suggestions to
            # $originals[-1]{'sugg'}
            if (@suggestions) {
                if (! $orig eq $originals[$index]{'orig'}) {
                    die "\nThese suggestions do not seem to belong here\nCurrent orig: $orig:\nIndex: $index\nOriginal word at this index: $originals[$index]{'orig'}\nSuggestions: @suggestions\n\n";
                }
                $originals[$index]{'sugg'} = [ @suggestions ];
                @suggestions = ();
            }

            # Increase the index when hitting an input word to voikkospell
            # after the suggestions have been added to the previous input word
            $index++;
            if ($line =~ s/^W: //) {
                $originals[$index]{'error'}="SplErr";
                $orig = $line;
            } elsif ($line =~ s/^C: //) {
                $originals[$index]{'error'}="SplCor";
                $orig = $line;
            }
        }
    }
    if (@suggestions) {
        if (! $orig eq $originals[$index]{'orig'}) {
            die "\nThese suggestions do not seem to belong here\nCurrent orig: $orig:\nIndex: $index\nOriginal word at this index: $originals[$index]{'orig'}\nSuggestions: @suggestions\n\n";
        }
        $originals[$index]{'sugg'} = [ @suggestions ];
        @suggestions = ();
    }
    close(FH);
}

sub read_hfst {

    my $eol = $/ ; # store default value of record separator
    $/ = "";       # set record separator to blank lines

    print STDERR "Reading HFST output from $output\n";
    open(FH, $output);

    my $i=0;
#    my $hfst-ospell-version = <FH>; # Only if we know we have a real lex version info string!

    while (<FH>) {
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
        if (length($orig) > 0) {
            $orig =~ s/^\s*(.*?)\s*$/$1/;
        }

        # Some simple adjustments to the input and output lists.
        # First search the output word from the input list.
        my $j = $i;

# Debug prints:
#        print "$originals[$j]{'orig'}\n";
#        print "-----------\n";

        while ($originals[$j] && $originals[$j]{'orig'} ne $orig) {
            $j++;
        }

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
            if ($error) {
                $originals[$i]{'error'} = $error;
            } else {
                $originals[$i]{'error'} = "not_known";
            }
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

# This function reads the hfst-ospell-office tool output, which is quite
# different from the data from hfst-ospell.
sub read_hfst_tino {

    print STDERR "Reading hfst-ospell-office data from $output\n";
    open(FH, $output);

    my $i=0;
    my @suggestions;
    my $error;
    #my @numbers;
    my @tokens;
    my $time;
    my $flag;
    my $sugglist;
    while (<FH>) {
        chomp;
        if (! /@@/) {
            if ($suggtiming eq 'yes') {
                ($time, $flag, $sugglist) = split(/\t/, $_, 3);
            } else {
                ($flag, $sugglist) = split(/\t/, $_, 2);
            }

            $originals[$i]{'time'} = $time;

            if ($flag eq '*') {
                $originals[$i]{'error'} = 'SplCor';
            } elsif ($flag eq '#') {
                $originals[$i]{'error'} = 'SplErr';
                if (length($sugglist)) {
                    $originals[$i]{'sugg'} = [ split(/\t/, $sugglist) ];
                }
            } elsif ($flag eq '&') {
                $originals[$i]{'error'} = 'SplErr' ;
                $originals[$i]{'sugg'} = [ split(/\t/, $sugglist) ];
            } elsif ($flag eq '!') {
                print STDERR "empty line fed to speller: «" . $_ . "»\n";
            } else {
                print STDERR __LINE__ . " unknown input\n";
                print STDERR $_;
                print STDERR "\nstopping\n";
                exit(18);
            }

            $i++;
        }
    }
    close(FH);
}

# This function reads the correct data to evaluate the performance of the speller
# The data is structured as in the typos file, hence the name.
sub read_typos {

    print STDERR "Reading typos from $input\n";
    open(FH, "<$input") or die "Could not open $input";

    while (<FH>) {
#        s/[\#\!].*$//; # not applicable anymore - we want to preserve comments
        my ($testpair, $comment) = split(/[\#\!]\s*/);
        my ($orig, $expected) = split(/\t+/,$testpair);
#        print STDERR "Original: $orig\n";
#        print STDERR "Expected: $expected\n" if $expected;
#        print STDERR "Comment:  $comment\n" if $comment;
        if (length($orig) > 0) {
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
    my $dtd = $doc->createInternalSubset( "html", undef, undef );

    my $spelltestresult = $doc->createElement('html');
    my $head = $doc->createElement('head');
    my $title = $doc->createElement('title');
    $title->appendTextNode('Speller test results for SMA XXX');
    $head->appendChild($title);

    my $meta = $doc->createElement('meta');
    $meta->setAttribute('charset' => 'UTF-8');
    $head->appendChild($meta);

    my $script;
    my $link;

    $script = $doc->createElement('script');
    $script->setAttribute('src' => "https://cdnjs.cloudflare.com/ajax/libs/jquery/3.1.1/jquery.min.js");
    $script->setAttribute('integrity' => "sha256-hVVnYaiADRTO2PzUGmuLJr8BLUSjGIZsDYGmIJLv2b8=");
    $script->setAttribute('crossorigin' => "anonymous");
    $script->appendTextNode(' ');
    $head->appendChild($script);

    $script = $doc->createElement('script');
    $script->setAttribute('src' => "https://cdnjs.cloudflare.com/ajax/libs/Dynatable/0.3.1/jquery.dynatable.min.js");
    $script->setAttribute('integrity' => "sha256-/kLSC4kLFkslkJlaTgB7TjurN5TIcmWfMfaXyB6dVh0=");
    $script->setAttribute('crossorigin' => "anonymous");
    $script->appendTextNode(' ');
    $head->appendChild($script);

    $link = $doc->createElement('link');
    $link->setAttribute('rel' => "stylesheet");
    $link->setAttribute('href' => "https://cdnjs.cloudflare.com/ajax/libs/Dynatable/0.3.1/jquery.dynatable.min.css");
    $link->setAttribute('integrity' => "sha256-lxcbK1S14B8LMgrEir2lv2akbdyYwD1FwMhFgh2ihls=");
    $link->setAttribute('crossorigin' => "anonymous");
    $head->appendChild($link);

    $link = $doc->createElement('link');
    $link->setAttribute('rel' => "stylesheet");
    $link->setAttribute('href' => "https://gtsvn.uit.no/langtech/trunk/giella-core/scripts/style/speller_xml.css");
    $head->appendChild($link);

    $spelltestresult->appendChild($head);

#     my $pi = $doc->createProcessingInstruction("xml-stylesheet");
#     $pi->setData(href=>'https://gtsvn.uit.no/langtech/trunk/giella-core/scripts/style/speller_xml.css', type=>'text/css');
#     $doc->appendChild( $pi );

    my $spelltestbody = $doc->createElement('body');
    my $results = make_results(\@originals, $doc);
    $spelltestbody->appendChild($results);

    $spelltestbody->insertBefore(make_header(\@originals, $results, $doc), $results);

    $script = $doc->createElement('script');
    $script->appendTextNode('$(document).ready( function() {$("#results").dynatable({features: {paginate: false}});});');
    $spelltestbody->appendChild($script);

    $spelltestresult->appendChild($spelltestbody);

    $doc->setDocumentElement($spelltestresult);
    $doc->toFile($print_xml, 1);
}

sub make_original {
    # Make the xml element original
    # rec is a hash element representing one checked word
    # word will be the parent element of original
    # doc is a XML::LibXML::Document
    my ($rec, $word, $doc) = @_;

    my $original = $doc->createElement('td');
    if (length($rec->{'orig'})) {
        $original->setAttribute('class' => 'original');
        $original->appendTextNode($rec->{'orig'});

        if ($rec->{'expected'}) {
            $original->setAttribute('status' => "error");
        } else {
            $original->setAttribute('status' => "correct");
        }

        $word->appendChild($original);
    }
}

sub make_time {
    # Make the xml element original
    # rec is a hash element representing one checked word
    # word will be the parent element of original
    # doc is a XML::LibXML::Document
    my ($rec, $word, $doc) = @_;

    my $time = $doc->createElement('td');
    if ($rec->{'time'}) {
        $time->setAttribute('class' => 'time');
        $time->appendTextNode($rec->{'time'});

        $word->appendChild($time);
    }
}

sub make_expected {
    # Make the xml element expected
    # rec is a hash element representing one checked word
    # word will be the parent element of original
    # doc is a XML::LibXML::Document
    my ($rec, $word, $doc) = @_;

    my $expected = $doc->createElement('td');
    if ($rec->{'expected'}) {
        $expected->setAttribute('class' => 'expected');
        $expected->appendTextNode($rec->{'expected'});
        $word->appendChild($expected);

        my $distance=distance($rec->{'orig'},$rec->{'expected'},{-output=>'distance'});
        my $edit_dist = $doc->createElement('td');
        $edit_dist->setAttribute('class' => 'edit_dist');
        $edit_dist->appendTextNode($distance);
        $word->appendChild($edit_dist);
    }
}

sub make_speller {
    # Make the xml element speller
    # rec is a hash element representing one checked word
    # word will be the parent element of original
    # doc is a XML::LibXML::Document
    my ($rec, $word, $doc) = @_;

    my $speller = $doc->createElement('td');
    $speller->setAttribute('class' => 'speller');
    if ($rec->{'error'}) {
        if ($rec->{'error'} eq "SplErr") {
            $speller->setAttribute('status' => "error");
        }
        if ($rec->{'error'} eq "SplCor") {
            $speller->setAttribute('status' => "correct");
        }

        $word->appendChild($speller);
    }
}

sub make_position {
    # Make the xml element position
    # rec is a hash element representing one checked word
    # word will be the parent element of original
    # doc is a XML::LibXML::Document
    my ($rec, $word, $doc) = @_;

    my $position = $doc->createElement('td');
    if ($rec->{'error'} && $rec->{'error'} eq "SplErr") {
        if($rec->{'sugg'}) {
            my @suggestions = @{$rec->{'sugg'}};
    
            if ($rec->{'expected'}) {
                my $i=0;
                while ($suggestions[$i]) {
                    if ($rec->{'expected'} eq $suggestions[$i]) {
                        $position->setAttribute('class' => 'position');
                        $position->appendTextNode($i + 1);
                        $word->appendChild($position);
                        last;
                    }
                    $i++;
                }
                if (! $word->find('./td[@class="position"]') ) {
                    $position->setAttribute('class' => 'position');
                    $position->appendTextNode("0");
                    $word->appendChild($position);
                }
            }
        } else {
            $position->setAttribute('class' => 'position');
            $position->appendTextNode("-1");
            $word->appendChild($position);
        }
    }
}

sub make_suggestions {
    # Make the xml elements position and suggestions
    # rec is a hash element representing one checked word
    # word will be the parent element of original
    # doc is a XML::LibXML::Document
    my ($rec, $word, $doc) = @_;

    my $suggestions_elt = $doc->createElement('td');
    if ($rec->{'error'} && $rec->{'error'} eq "SplErr" && $rec->{'sugg'}) {
        my @suggestions = @{$rec->{'sugg'}};

        $suggestions_elt->setAttribute('class' => 'suggestions');

        my $sugg_count = scalar @{ $rec->{'sugg'}};
        $suggestions_elt->setAttribute('count' => $sugg_count);

        my $near_miss_count = 0;
        if ($rec->{'suggnr'}) {
            $near_miss_count = $rec->{'suggnr'};
        }

        my @numbers;
        if ($rec->{'num'}) {
            @numbers =  @{$rec->{'num'}};
        }

        my $sugg_list = $doc->createElement('ul');
        for my $sugg (@suggestions) {
            if ($sugg) {
                my $suggestion = $doc->createElement('li');
                $suggestion->setAttribute('class' => 'suggestion');
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

                $sugg_list->appendChild($suggestion);
            }
        }
        $suggestions_elt->appendChild($sugg_list);
        $word->appendChild($suggestions_elt);
    }
}

sub make_tokens {
    # Make the xml element tokens
    # rec is a hash element representing one checked word
    # word will be the parent element of original
    # doc is a XML::LibXML::Document
    my ($rec, $word, $doc) = @_;

    my $tokens_elt = $doc->createElement('td');
    if ($rec->{'tokens'}) {
        my @tokens = @{$rec->{'tokens'}};
        my $tokens_num = scalar @tokens;
        $tokens_elt->setAttribute('class' => 'tokens');
        $tokens_elt->setAttribute('count' => $tokens_num);

        my $token_list = $doc->createElement('ul');
        for my $t (@tokens) {
            my $token_elt = $doc->createElement('li');
            $token_elt->setAttribute('class' => 'token');
            $token_elt->appendTextNode($t);
            $token_list->appendChild($token_elt);
        }
        $tokens_elt->appendChild($token_list);
        $word->appendChild($tokens_elt);
    }
}

sub make_bugid {
    # Make the xml element bug
    # rec is a hash element representing one checked word
    # word will be the parent element of original
    # doc is a XML::LibXML::Document
    my ($rec, $word, $doc) = @_;

    my $bugID = $doc->createElement('td');
    if ($rec->{'bugID'}) {
        #handle_comment would be used here
        $bugID->setAttribute('class' => 'bug');
        $bugID->appendTextNode($rec->{'bugID'});
        $word->appendChild($bugID);
    }
}

sub make_comment {
    # word will be the parent element of original
    # rec is a hash element representing one checked word
    # doc is a XML::LibXML::Document
    my ($rec, $word, $doc) = @_;

    if ($rec->{'comment'}) {
        my ($errorinfo, $origfile) = ($rec->{'comment'} =~ m/errorinfo=(.+) file: (.*)/);
        make_errors($errorinfo, $word, $doc);
        make_origfile($origfile, $word, $doc);
    }
}

sub make_errors {
    # Make the xml element errors
    # errorinfo is a string containing error info
    # word will be the parent element of original
    # doc is a XML::LibXML::Document
    my ($errorinfo, $word, $doc) = @_;

    my $errors = $doc->createElement('td');
    if ($errorinfo) {
        $errors->setAttribute('class' => 'errors');

        my $list = $doc->createElement('ul');

        my @e = split(';', $errorinfo);
        foreach my $part (@e) {
            make_error_part($part, $list, $doc);
        }

        $word->appendChild($errors);
    }
}

sub make_error_part {
    my ($part, $errors, $doc) = @_;

    my $error = $doc->createElement('li');
    $error->setAttribute('class' => 'error');

    if ($part =~ /,$/) {
        $part = substr($part, 0, -1);
    }
    my $type = substr($part, 0, index($part, ','));
    my $text = substr($part, index($part, ',') + 1);
    $error->setAttribute('type' => $type);
    if ($text) {
        $error->appendTextNode($text);
    }

    $errors->appendChild($error);
}

sub make_origfile {
    # Make the xml element origfile
    # origfile is a string telling where the spelling error appeared
    # word will be the parent element of original
    # doc is a XML::LibXML::Document
    my ($origfile, $word, $doc) = @_;

    if ($origfile) {
        my $f = $doc->createElement('div');
        $f->setAttribute('id' => 'origfile');
        $f->appendTextNode($origfile);

        $word->appendChild($f);
    }
}

sub set_corrsugg_attribute {
    # corrsugg=1..5: correct suggestion found in this position
    # corrsugg=6: correct suggestion found below the 5th suggestion
    # corrsugg=0: no suggestions
    # corrsugg=-1: no correct suggestions
    # corrsugg=goodaccept: the word is correctly accepted by the speller
    # corrsugg=badaccept:  the word is accepted by the speller, but is misspelled
    # corrsugg=falsealarm: the word is flagged by the speller, but should not
    my ($word) = @_;

    if ($word->find('./td[@class="position"]')) {
        if ($word->find('./td[@class="position"]/text() > 0 and ./td[@class="position"]/text() < 6')) {
            $word->setAttribute('corrsugg' => $word->findvalue('./td[@class="position"]/text()'));
        } else {
            $word->setAttribute('corrsugg' => '6');
        }
    } elsif ($word->find('./td[@class="speller" and @status="error"]') &&
            $word->find('./td[@class="original" and @status="correct"]')) {
        $word->setAttribute('corrsugg' => 'falsealarm');
    } elsif ($word->find('./td[@class="speller" and @status="correct"]') &&
            $word->find('./td[@class="original" and @status="error"]')) {
        $word->setAttribute('corrsugg' => 'badaccept');
    } elsif (! $word->find('./td[@class="suggestions"]') && $word->find('./td[@class="expected"]')) {
        $word->setAttribute('corrsugg' => '0');
    } elsif (! $word->find('./td[@class="position"]') && $word->find('./td[@class="suggestions"]')) {
        $word->setAttribute('corrsugg' => '-1');
    } elsif ($word->find('./td[@class="speller" and @status="correct"]') &&
            $word->find('./td[@class="original" and @status="correct"]')) {
        $word->setAttribute('corrsugg' => 'goodaccept');
    }
}

sub make_word {
    # Make the xml element word
    # rec is a hash element representing one checked word
    # results will be the parent element of all word
    # doc is a XML::LibXML::Document
    my ($rec, $results, $doc) = @_;

    my $word = $doc->createElement('tr');
    $word->setAttribute('class' => 'word');

    make_original($rec, $word, $doc);
    make_speller($rec, $word, $doc);
    make_expected($rec, $word, $doc);
    make_time($rec, $word, $doc);
    make_position($rec, $word, $doc);
    make_suggestions($rec, $word, $doc);
    make_tokens($rec, $word, $doc);
    make_bugid($rec, $word, $doc);
    make_comment($rec, $word, $doc);

    if ($rec->{'forced'}){
        $word->setAttribute('forced' => "yes");
    }

    if ($corrsugg) {
        set_corrsugg_attribute($word);
    }

    $results->appendChild($word);
}

sub make_results {
    # Make the xml element results
    # originalrefs is an array containing all the data
    # spelltestresult will be the parent element of results
    # doc is a XML::LibXML::Document
    my ($originals_ref, $doc) = @_;

    my $results = $doc->createElement('table');
    $results->setAttribute('id' => 'results');

    my $thead = $doc->createElement('thead');
    my $tr = $doc->createElement('tr');
    $thead->appendChild($tr);

    my $th;

    my @tableheaders = ("original", "speller", "expected", "edit dist", "position", "suggestions", "tokens", "bugid", "comment");
    if ($suggtiming eq 'yes') {
        splice @tableheaders, 4, 0, "time";
    }
    foreach my $text (@tableheaders) {
        $th = $doc->createElement('th');
        $th->appendTextNode($text);
        $tr->appendChild($th);
    }

    $results->appendChild($thead);

    for my $rec (@{$originals_ref}) {
        make_word($rec, $results, $doc);
    }

    return $results;
}

sub make_header {
    my ($originals_ref, $results, $doc) = @_;

    my $header = $doc->createElement('div');
    $header->setAttribute('id' => 'header');

    $header->appendChild(make_engine($doc));
    $header->appendChild(make_lexicon($doc));
    $header->appendChild(make_document($doc));
    if (get_lang()) {
        $header->appendChild(make_lang($doc));
    }
    if (get_testtype()) {
        $header->appendChild(make_testtype($doc));
    }
    $header->appendChild(make_timestamp($doc));
    $header->appendChild(make_truefalsesummary($results, $doc));
    $header->appendChild(make_suggestionsummary($results, $doc));

    return $header;
}

sub make_lexicon {
    my ($doc) = @_;

    my $lexicon = $doc->createElement('div');
    $lexicon->setAttribute('id' => 'lexicon');
    $lexicon->setAttribute('version' => $version);
    $lexicon->appendTextNode(' ');

    return $lexicon;
}

sub make_engine {
    my ($doc) = @_;

    # Print some header information
    my $engine = $doc->createElement('div');
    $engine->setAttribute('id' => 'engine');
    $engine->setAttribute('abbreviation' => $input_type);

    my $tool = $doc->createElement('div');
    $tool->setAttribute('id' => 'toolversion');
    $tool->appendTextNode($toolversion);
    $engine->appendChild($tool);

    my $processing = $doc->createElement('div');
    $processing->setAttribute('id' => 'processing');
    $processing->setAttribute('memoryusage' => $memoryuse);

    my $time_hash = convert_systime();
    while (my ($key, $value) = each(%$time_hash)) {
        $processing->setAttribute($key => $value);
    }

    if ($time_hash->{'realtime'} != 0) {
        $processing->setAttribute('words_per_sec' => sprintf("%.2f", scalar(@originals) / $time_hash->{'realtime'}));
    }

    $engine->appendChild($processing);

    return $engine;
}

sub get_flagged_words {
    my ($results) = @_;
    return scalar(@{$results->findnodes('.//td[@class="speller" and @status="error"]')});
}

sub get_accepted_words {
    my ($results) = @_;
    return scalar(@{$results->findnodes('.//td[@class="speller" and @status="correct"]')});
}

sub get_original_correct {
    my ($results) = @_;
    return scalar(@{$results->findnodes('.//tr[@class="word"][td[@class="original"] and not(td[@class="expected"])]')});
}

sub get_original_error {
    my ($results) = @_;
    return scalar(@{$results->findnodes('.//tr[@class="word"][td[@class="original"] and td[@class="expected"]]')});
}

sub get_speller_correct {
    # same as accepted words
    my ($results) = @_;
    return scalar(@{$results->findnodes('.//td[@class="speller" and @status="correct"]')});
}

sub get_speller_error {
    # same as flagged words
    my ($results) = @_;
    return scalar(@{$results->findnodes('.//td[@class="speller" and @status="error"]')});
}

sub get_true_positive {
    my ($results) = @_;
    return scalar(@{$results->findnodes('.//tr[@class="word"][td[@class="original"] and td[@class="expected"] and td[@class="speller" and @status="error"]]')});
}

sub get_false_positive {
    my ($results) = @_;
    return scalar(@{$results->findnodes('.//tr[@class="word"][td[@class="original"] and not(td[@class="expected"]) and td[@class="speller" and @status="error"]]')});
}

sub get_true_negative {
    my ($results) = @_;
    return scalar(@{$results->findnodes('.//tr[@class="word"][td[@class="original"] and not(td[@class="expected"]) and td[@class="speller" and @status="correct"]]')});
}

sub get_false_negative {
    my ($results) = @_;
    return scalar(@{$results->findnodes('.//tr[@class="word"][td[@class="original"] and td[@class="expected"] and td[@class="speller" and @status="correct"]]')});
}

sub make_truefalsesummary {
    my ($results, $doc) = @_;

    my $truefalsesummary = $doc->createElement('div');
    $truefalsesummary->setAttribute('id' => 'truefalsesummary');

    my $total_words = get_flagged_words($results) + get_accepted_words($results);
    $truefalsesummary->setAttribute('wordcount' => $total_words);

    my $original = $doc->createElement('div');
    $original->setAttribute('id' => 'originals');
    $original->setAttribute('correct' => get_original_correct($results));
    $original->setAttribute('error' => get_original_error($results));
    $original->appendTextNode(' ');
    $truefalsesummary->appendChild($original);

    my $speller = $doc->createElement('div');
    $speller->setAttribute('id' => 'spellers');
    $speller->setAttribute('correct' => get_speller_correct($results));
    $speller->setAttribute('error' => get_speller_error($results));
    $speller->appendTextNode(' ');
    $truefalsesummary->appendChild($speller);

    my $positive = $doc->createElement('div');
    $positive->setAttribute('id' => 'positives');
    $positive->setAttribute('true' => get_true_positive($results));
    $positive->setAttribute('false' => get_false_positive($results));
    $positive->appendTextNode(' ');
    $truefalsesummary->appendChild($positive);

    my $negative = $doc->createElement('div');
    $negative->setAttribute('id' => 'negatives');
    $negative->setAttribute('true' => get_true_negative($results));
    $negative->setAttribute('false' => get_false_negative($results));
    $negative->appendTextNode(' ');
    $truefalsesummary->appendChild($negative);

    my $precision = $doc->createElement('div');
    $precision->setAttribute('id' => 'precisions');
    my $recall = $doc->createElement('div');
    $recall->setAttribute('id' => 'recall');

    $precision->appendTextNode(sprintf("%.2f", get_true_positive($results) / (get_true_positive($results) + get_false_positive($results))));
    $truefalsesummary->appendChild($precision);
    $recall->appendTextNode(sprintf("%.2f", get_true_positive($results) / (get_true_positive($results) + get_false_negative($results))));
    $truefalsesummary->appendChild($recall);


    my $accuracy = $doc->createElement('div');
    $accuracy->setAttribute('id' => 'accuracy');
    $accuracy->appendTextNode(sprintf("%.2f", (get_true_positive($results) + get_true_negative($results))/($total_words)));
    $truefalsesummary->appendChild($accuracy);

    return $truefalsesummary;
}

sub make_averageposition {
    my ($results, $doc) = @_;

    my @positions = $results->findnodes('.//td[@class="position"]');
    my $total = 0;
    for my $position (@positions) {
        $total += int($position->textContent);
    }

    my $averageposition = $doc->createElement('div');
    $averageposition->setAttribute('id' => 'averageposition');
    if (scalar(@positions) > 0) {
        $averageposition->appendTextNode(sprintf("%.2f", $total / scalar(@positions)));
    }

    return $averageposition;
}

sub make_suggx {
    my ($suggname, $queryx, $results, $doc) = @_;

    my $y;
    my @editdistx;

    my $sugg = $doc->createElement('div');
    $sugg->setAttribute('id' => $suggname);
    for ($y = 1; $y < 3; $y++) {
        my $haff = './/tr[@class="word"][' . $queryx . ' and td[@class="edit_dist"]/text() = ' . $y . ']';
        @editdistx = $results->findnodes($haff);
        $sugg->setAttribute("editdist$y" => scalar(@editdistx));
    }
    my $haff = './/tr[@class="word"][' . $queryx . ' and td[@class="edit_dist"]/text() = ' . $y . ']';
    @editdistx = $results->findnodes($haff);
    $sugg->setAttribute("editdist$y" . "plus" => scalar(@editdistx));
    $sugg->appendTextNode(' ');

    return $sugg;
}

sub make_top1pos_percent {
    my ($results, $doc) = @_;

    my $top1pos_percent = $doc->createElement('div');
    $top1pos_percent->setAttribute('id' => 'top1pos_percent');

    my $spellererror = $results->findnodes('.//tr[@class="word"][td[@class="speller" and @status = "error"]
                                               and td[@class="original" and @status = "error"]]
                                           ')->size;
    my $positions = $results->findnodes('.//td[@class="position"][text() = 1]')->size;

    if ($spellererror > 0) {
        $top1pos_percent->appendTextNode(sprintf("%.2f", $positions / $spellererror * 100));
    }

    return $top1pos_percent;
}

sub make_top5pos_percent {
    my ($results, $doc) = @_;

    my $top5pos_percent = $doc->createElement('div');
    $top5pos_percent->setAttribute('id' => 'top5pos_percent');

    my $spellererror = $results->findnodes('.//tr[@class="word"][td[@class="speller" and @status = "error"]
                                               and td[@class="original" and @status = "error"]]
                                           ')->size;
    my $positions = $results->findnodes('.//td[@class="position"][text() < 6]')->size;

    if ($spellererror > 0) {
        $top5pos_percent->appendTextNode(sprintf("%.2f", $positions / $spellererror * 100));
    }

    return $top5pos_percent;
}

sub make_allpos_percent {
    my ($results, $doc) = @_;

    my $allpos_percent = $doc->createElement('div');
    $allpos_percent->setAttribute('id' => 'allpos_percent');

    my $spellererror = $results->findnodes('.//tr[@class="word"][td[@class="speller" and @status = "error"]
                                               and td[@class="original" and @status = "error"]]
                                           ')->size;
    my $positions = $results->findnodes('.//td[@class="position"]')->size;

    if ($spellererror) {
        $allpos_percent->appendTextNode(sprintf("%.2f", $positions / $spellererror * 100));
    }

    return $allpos_percent;
}

sub make_badsugg_percent {
    my ($results, $doc) = @_;

    my $badsugg_percent = $doc->createElement('div');
    $badsugg_percent->setAttribute('id' => 'badsugg_percent');

    my $spellererror = $results->findnodes('.//tr[@class="word"][td[@class="speller" and @status = "error"]
                                               and td[@class="original" and @status = "error"]]
                                           ')->size;
    my $badsuggs = $results->findnodes('./tr[@class="word"][@corrsugg = "-1"]')->size;

    if ($spellererror > 0) {
        $badsugg_percent->appendTextNode(sprintf("%.2f", $badsuggs / $spellererror * 100));
    }

    return $badsugg_percent;
}

sub make_nosugg_percent {
    my ($results, $doc) = @_;

    my $nosugg_percent = $doc->createElement('div');
    $nosugg_percent->setAttribute('id' => 'nosugg_percent');

    my $spellererror = $results->findnodes('.//tr[@class="word"][td[@class="speller" and @status = "error"]
                                               and td[@class="original" and @status = "error"]]
                                           ')->size;
    my $nosuggs = $results->findnodes('./tr[@class="word"][@corrsugg = "0"]')->size;

    if ($spellererror > 0) {
        $nosugg_percent->appendTextNode(sprintf("%.2f", $nosuggs / $spellererror * 100));
    }

    return $nosugg_percent;
}

sub make_averagesuggs_with_correct {
    my ($results, $doc) = @_;

    my $top5pos_percent = $doc->createElement('div');
    $top5pos_percent->setAttribute('id' => 'averagesuggs_with_correct');

    my $nodes = $results->findnodes('.//tr[@class="word"][td[@class="position"] and td[@class="suggestions"]]');

    my $total = 0;
    for my $node ($nodes->get_nodelist) {
        for ($node->findnodes('.//li[@class="suggestion"]')->size) {
            $total += $_;
        }
    }

    if (scalar($nodes->get_nodelist) > 0) {
        $top5pos_percent->appendTextNode(sprintf("%.2f", $total / scalar($nodes->get_nodelist)));
    }

    return $top5pos_percent;
}

sub make_suggestionsummary {
    my ($results, $doc) = @_;

    my $suggestionsummary = $doc->createElement('div');
    $suggestionsummary->setAttribute('id' => 'suggestionsummary');

    my $x;
    for ($x = 1; $x < 6; $x++) {
        $suggestionsummary->appendChild(make_suggx("sugg$x", 'td[@class="position"]/text() = ' . $x, $results, $doc));
    }
    $suggestionsummary->appendChild(make_suggx("suggbelow5", 'td[@class="position"]/text() >= ' .$x, $results, $doc));
    $suggestionsummary->appendChild(make_suggx("nosugg", 'not(td[@class="position"]) and not(td[@class="suggestions"])', $results, $doc));
    $suggestionsummary->appendChild(make_suggx("badsuggs", 'not(td[@class="position"]) and td[@class="suggestions"]', $results, $doc));

    $suggestionsummary->appendChild(make_averageposition($results, $doc));
    $suggestionsummary->appendChild(make_averagesuggs_with_correct($results, $doc));

    $suggestionsummary->appendChild(make_top1pos_percent($results, $doc));
    $suggestionsummary->appendChild(make_top5pos_percent($results, $doc));
    $suggestionsummary->appendChild(make_allpos_percent( $results, $doc));
    $suggestionsummary->appendChild(make_nosugg_percent( $results, $doc));
    $suggestionsummary->appendChild(make_badsugg_percent($results, $doc));

    return $suggestionsummary;
}

sub get_document {
    if (!$document) {
        $document = basename($input);
    }

    return $document;
}

sub get_lang {
    my @doccu2 = split(/\./, get_document());
    my @doccu1 = split(/-/, $doccu2[0]);

    return $doccu1[2];
}

sub get_testtype {
    my @doccu2 = split(/\./, get_document());
    my @doccu1 = split(/-/, $doccu2[0]);

    return $doccu1[1];
}

sub make_lang {
    my ($doc) = @_;

    my $lang = $doc->createElement('div');
    $lang->setAttribute('id' => 'lang');
    $lang->appendTextNode(get_lang());

    return $lang;
}

sub make_testtype {
    my ($doc) = @_;

    my $testtype = $doc->createElement('div');
    $testtype->setAttribute('id' => 'testtype');
    $testtype->appendTextNode(get_testtype());

    return $testtype;
}

sub make_document {
    my ($doc) = @_;

    # what was the checked document
    my $docu = $doc->createElement('div');
    $docu->setAttribute('id' => 'document');
    $docu->appendTextNode(get_document());

    return $docu;
}

sub make_timestamp {
    my ($doc) = @_;

    # The date is the timestamp of speller output file if not given.
    my $timestamp = $doc->createElement('div');
    $timestamp->setAttribute('id' => 'timestamp');
    if (!$date) {
        $date = ctime(stat($output)->mtime);
        #print "file $input updated at $date\n";
    }
    $timestamp->appendTextNode($date);

    return $timestamp;
}

sub print_output {

    for my $rec (@originals) {
        my @suggestions;
        if (length($rec->{'orig'})) {
            print "Orig: $rec->{'orig'} | ";
        }
        if ($rec->{'expected'}) {
            print "Expected: $rec->{'expected'} | ";
        }
        if ($rec->{'error'}) {
            print "Error: $rec->{'error'} | ";
        }
        print "Forced: $forced | ";
        if ($rec->{'sugg'}) {
            print "Suggs: @{$rec->{'sugg'}} | ";
            my @suggestions = @{$rec->{'sugg'}};
            my $i=0;
            if ($rec->{'expected'}) {
                while ($suggestions[$i] && $rec->{'expected'} ne $suggestions[$i]) {
                    $i++;
                }
                if ($suggestions[$i]) {
                    print $i+1;
                }
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

--engine=[pl|pk|mw|hu|fo|hf|to|vk]
                  The speller engine used is one of:
                  * pl - Polderland
                  * pk - Icelandic Púki
                  * mw - AppleScript+MSWord
                  * hu - Hunspell
                  * fo - foma-trie (output format = Hunspell)
                  * hf - Hfst-ospell
                  * to - Hfst-ospell-office, by Tino Didriksen
                  * vk - Voikko

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

--suggtiming      Whether to measure for every input word the time spent
--st              generating suggestions. Possible values: 'yes' and 'no'.
                  Default is 'no'.
END

}
