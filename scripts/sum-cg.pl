#!/usr/bin/perl

use strict;
use utf8;

# sum-cg.pl
#
# Perl script for summarizing ambiguous analyzes.
# 1. For finding the expressions that are ambiguous and common.
# 2. For finding out, which grammatical analyzes are most ambiguous.
# Usage: 
# sum-cg [OPTIONS] ANALYZED_FILE
# sum-cg [OPTIONS] --dir=<dir>
# sum-cg --help
# 
# $Id$

# permit named arguments
use Getopt::Long;
use File::Find;
use File::Basename;
use Carp qw(cluck);
use Encode;

my $help;
my $grammar;
my $print_words;
my $string="";
my $minimal;
my $dir;
my %num_total;
my $num;

# The rule numbers that are matched when the option --minimal is used.
my $numbers = "11858|1186n|12488|1249n|125nn|126nn|127nn|128nn|129nn|131nn|132nn|133nn|134nn|2351n|1352n|1353n|1354n|13563|15207|15211";


GetOptions ("help" => \$help,
			"grammar" => \$grammar,
			"words" => \$print_words,
			"string=s" => \$string,
			"minimal" => \$minimal,
			"num=s" => \$num,
			"dir=s" => \$dir,
			) ;

if ($help) {
	&print_usage;
	exit;
}

if ($num) {
	$minimal=1;
	$numbers=$num;
}
$numbers =~ s/n/\\d/g;

my $anal_count = 0;
my %cohorts;
my %count;

# whole group of analyses for a word.

# Read while not eol
my $word;
my $whole;
my $base;

# Search the files in the directory $dir and process each one of them.
if ($dir) {
	if (-d $dir) { find (\&process_file, $dir) }
	else { cluck "Directory did not exist."; }
}

# Process the file given in command line.
process_file (Encode::decode_utf8($ARGV[$#ARGV])) if -f $ARGV[$#ARGV];

if ($grammar) {
	my %tags;
	my $amb ="";
	my $count_an=0;
	for my $cohort (keys %cohorts) {
		for my $base (keys % {$cohorts{$cohort}}) {
			for my $anal (keys %{ $cohorts{$cohort}{$base} }){
				$amb .= "\n$anal";
				$count_an += 1;
			}
            # The statistics are count for different cohorts.
			if ($count_an > 1) {
				$tags{$amb}{'number'} += $count{$cohort};
				my $word = $cohort;
				$word =~ s/^\"<(.*?)>\".*$/$1/s;
				$tags{$amb}{$word} += $count{$cohort};
			}
			$count_an = 0;
			$amb = "";
		}
	}
	for my $gram (sort { $tags{$b}{'number'} <=> $tags{$a}{'number'} } keys %tags) {
		print "$tags{$gram}{'number'}: ";
		if( $print_words) {
			for my $word (keys % { $tags{$gram} } ) {
				if($word ne 'number') {
					print "$word $tags{$gram}{$word} ";
				}
			}
		}
		print "$gram\n\n";
	}
}
elsif ($string) {
	for my $cohort (sort { $count{$b} <=> $count{$a} } keys %count) {
		next if ($cohort !~ /$string/m);
		print "$count{$cohort}\n";
		my $word = $cohort;
		$word =~ s/^(\"<.*?>\").*$/$1/s;
		print "$word\n";
		for my $base (keys % {$cohorts{$cohort}}) {
			for my $anal (keys %{ $cohorts{$cohort}{$base} }){
				print "\t$base";
				print "$anal\n";
			}
		}
	}
}
else {
	for my $num (sort { $num_total{$b} <=> $num_total{$a} } keys %num_total) {
		print "$num: $num_total{$num}\n";
	}
	for my $cohort (sort { $count{$b} <=> $count{$a} } keys %count) {
		if ($minimal && $cohort !~ /($numbers)[,\s]/) {next;}
		my $word = $cohort;
		$word =~ s/^(\"<.*?>\")(.*?)(\n)?/$1/s;
		$word =~ s/\n//g;
		print "$count{$cohort}\n";
		print "$word\n";
		for my $base (keys % {$cohorts{$cohort}}) {
			for my $anal (keys %{ $cohorts{$cohort}{$base} }){
				print "\t$base";
				print "$anal\n";
			}
		}
	}
}


sub process_file {

    my $file = $_;
    $file = shift (@_) if (!$file);

	my $no_decode_this_time = 0;

	return if (! -f $file);
	return if (-z $file);

	print STDERR "Processing file: $file\n";

	open(FH, $file);
	
	my $line;
	while(<FH>) {

		return if eof(FH);
		$line = $_;

		return if (! $line);

		next if ($line =~ /^\s*$/);

		# hash of hashes base -> analyses
		my %analyses;

		LINE :
		    while ($line && $line !~ /^\"</) {
		      return if eof(FH);
		      #print STDERR "gogo_w $.\n";
		      if($line =~ /(\".*?\")(\s+.*)$/) {
			$base = $1;
			my $analysis = $2;
			$anal_count += 1;
			$analyses{$base}{$analysis} = 1;
		      }
		      else { 
			print STDERR "Line $. not recognized: $word, $_\n"; 
		      }
		      
		      while(<FH>) {
			#print STDERR "gogo_w $.\n";
			$line = $_;
			next if ($line =~ /^\s*$/);
			last LINE if eof(FH);
			next LINE;
		      }
		    } #end of LINE
		
		my %analyses_2;
		for my $ba (keys %analyses) {
			foreach my $key (sort keys %{$analyses{$ba}}) {
				$analyses_2{$ba}{$key} = 1;
				$whole .= $key;
			}
		}

		next if (!$whole);
		$count{$whole} += 1;
		$cohorts{$whole} = { %analyses_2 };
		
		# If there is only one analysis, then delete the cohort.
		# If the matching rules are searched for, then leave all.
		if (! $minimal && $whole && $anal_count == 1) {
			delete($cohorts{$whole});
			delete($count{$whole});
		}

		if ($line =~ /^\"<.*?>\"(.*)$/) {
			# Start with the new word
			if ($1 =~ /($numbers)/) { $num_total{$1} +=1; }
			$whole = $line . "\n";
			$anal_count = 0;
		} else { cluck "Error, $line in wrong place."; }

	} # LINE

	close FH;
}


sub print_usage {
	print <<END ;
Usage: sum-cg.pl [OPTIONS] FILE
Summarize cg-output. Only ambiguous analyzes are counted.
Options
	--dir=<dir>     Search files from directory <dir>.
	--grammar       Compare only grammatical analyzes.
	--words         Print words associated with analyzes.
	--string=regex  Searches for a string or regex from the analyses. E.g. to find
                    Com/Loc ambiguity: --string="(Com .*Loc|Loc.*Com)"
	--minimal       Assume rule numbers in the input, consider all analyzes
	                pick the analyzes that match the numbers in variable "numbers".
    --num=string    Searches for specific rule numbers from the analysis. E.g.
                    --num="18565|125nn", implies --minimal and overrides the variable.
                    The letter n is replaced by "any digit" in the search.
	--help          Print the help text and exit
END
}

