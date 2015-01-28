# Util.pm
# Utility functions for the using the different langtech tools.

package langTools::Util;

use utf8;

use Encode;
use warnings;
use strict;
use Carp qw(cluck);

use Exporter;
our ( $VERSION, @ISA, @EXPORT, @EXPORT_OK );

# $VERSION = sprintf "%d.%03d", q$Revision$ =~ /(\d+)/g;
@ISA = qw(Exporter);

@EXPORT =
  qw(&init_lookup &call_lookup &read_tags &generate_taglist &win_digr &digr_utf8 &format_compound);
@EXPORT_OK = qw();

# Initialize expect object for analysis
# Returns a pointer to the object.
sub init_lookup {
    my ($command) = @_;

    if ( !$command ) { cluck "No command specified"; }
    my $exp = Expect->spawn($command)
      or cluck "Cannot spawn $command";
    $exp->log_stdout(0);

    return $exp;
}

# Call expect object with a string.
# Returns the analysis.
sub call_lookup {
    my ( $exp_ref, $string, $decode ) = @_;

    if ( !$$exp_ref ) { cluck "The expect object missing"; }

    if ($decode) { $string = Encode::encode_utf8($string); }

    $$exp_ref->send("$string\n");
    $$exp_ref->expect( undef, '-re', '\r?\n\r?\n' );

    my $read_anl = $$exp_ref->before();

    if ($decode) { $read_anl = Encode::decode_utf8($read_anl); }

    # Take away the original input.
    $read_anl =~ s/^.*?\n//;

    # Replace extra newlines.
    $read_anl =~ s/\r\n/\n/g;
    $read_anl =~ s/\r//g;

    return "$read_anl\n";

}

# Read the grammar for  paradigm tag list.
# Call the recursive function that generates the tag list.
sub generate_taglist {
    my ( $gramfile, $tagfile, $taglist_aref ) = @_;

    my @grammar;
    my %tags;

    if ($gramfile) {
        print "util 72\n";
        # Read from tag file and store to an array.
        open GRAM, "< $gramfile" or die "Cant open the file $gramfile: $!\n";
        my @tags;
        my $tag_class;
      GRAM_FILE:
        while (<GRAM>) {
            chomp;
            next if /^\s*$/;
            next if /^%/;
            next if /^$/;
            next if /^#/;

            s/\s*$//;
            push( @grammar, $_ );
            print "util 87 $_\n";
        }
    }
    read_tags( $tagfile, \%tags );

    my @taglists;

    # Read each grammar rule and generate the taglist.
    for my $gram (@grammar) {
        my @classes = split( /\+/, $gram );
        my $pos     = shift @classes;
        my $tag     = $pos;
        my @taglist;

        generate_tag( $tag, \%tags, \@classes, \@taglist );
        push( @{ $$taglist_aref{$pos} }, @taglist );
    }

    #	for my $pos ( keys %$taglist_aref ) {
    #		print "\nJEE $pos OK @{$$taglist_aref{'Pron'}} ";
    #	}
}

# Ttravel recursively the taglists and generate
# the tagsets for pardigm generation.
# The taglist is stored to the array reference $taglist_aref.
sub generate_tag {
    my ( $tag, $tags_href, $classes_aref, $taglist_aref ) = @_;

    print "util 116 $tag\n";
    if ( !@$classes_aref ) { push( @$taglist_aref, $tag ); return; }
    print "util 118 $tag\n";
    my $class = shift @$classes_aref;
    if ( $class =~ s/\?// ) {
        my $new_tag   = $tag;
        my @new_class = @$classes_aref;
        generate_tag( $new_tag, $tags_href, \@new_class, $taglist_aref );
    }

    if ( !$$tags_href{$class} ) {
        my $new_tag   = $tag . "+" . $class;
        my @new_class = @$classes_aref;
        generate_tag( $new_tag, $tags_href, \@new_class, $taglist_aref );
        return;
    }

    for my $t ( @{ $$tags_href{$class} } ) {
        my $new_tag   = $tag . "+" . $t;
        my @new_class = @$classes_aref;
        generate_tag( $new_tag, $tags_href, \@new_class, $taglist_aref );
    }
}

# Read the morphological tags from a file (korpustags.txt)
sub read_tags {
    my ( $tagfile, $tags_href ) = @_;

    # Read from tag file and store to an array.
    open TAGS, "< $tagfile" or die "Cant open the file $tagfile: $!\n";
    my @tags;
    my $tag_class;
  TAG_FILE:
    while (<TAGS>) {
        chomp;
        next if /^\s*$/;
        next if /^%/;
        next if /^$/;
        next if /=/;

        if (s/^#//) {

            $tag_class = $_;
            print "159 $tag_class\n";
            push( @{ $$tags_href{$tag_class} }, @tags );
            undef @tags;
            pop @tags;
            next TAG_FILE;
        }
        my @tag_a = split( /\s+/, $_ );
        print "util 163 $tag_a[0]\n";
        push @tags, $tag_a[0];
    }

    close TAGS;
}

# Form baseforms of analyzed compounds.
sub format_compound {
    my ( $refbase, $refline, $refword ) = @_;

    my $boundary_count = ( $$refbase =~ tr/\#// );

    # Take only the analysis of the last part of the compound
    $$refbase =~ /^.*\#(.*?)$/;
    my $last_word = $1;
    if ( !$last_word ) { return; }

    my $second_last_word;
    my $third_last_word;
    if ( $boundary_count > 1 ) {
        if ( $$refbase =~ /^.*\#(.*?)\#.*$/ ) {
            $second_last_word = $1;
        }
        if ( $$refbase =~ /^.*\#(.*?)\#.*\#.*$/ ) {
            $third_last_word = $1;
        }
    }
    my $i = 4;
    my $substring = substr( $last_word, 0, $i );

    while ( ( $$refword !~ m/\Q$substring\E/ ) && $i > 1 ) {
        $i--;
        $substring = substr( $last_word, 0, $i );
    }

    if ( $$refword =~ m/\Q$substring\E/ ) {

       # If the compound boundary is found,
       # replace the last word by its base form, and insert a # mark in front of
       # it, in order to mark the result as a compound.
        my $orig = $$refbase;
        $$refbase = $$refword;
        $$refbase =~ s/(^.*)\Q$substring\E.*$/$1\#$last_word/;
        if ( $orig =~ m/^\p{isLower}/ ) {
            $$refbase = lcfirst($$refbase);
        }
    }

    if ($second_last_word) {
        my $i = 4;
        my $substring = substr( $second_last_word, 0, $i );
        while ( $$refbase !~ /.*\Q$substring\E.*\#/ && $i > 1 ) {
            $i--;
            $substring = substr( $second_last_word, 0, $i );
        }

        # If the compound boundary is found, mark it with #
        if ( $$refbase =~ /\Q$substring\E/ ) {
            $$refbase =~ s/(\Q$substring\E.*\#)/\#$1/;
        }
    }

    if ($third_last_word) {
        my $i = 4;
        my $substring = substr( $third_last_word, 0, $i );
        while ( $$refbase !~ /.*\Q$substring\E.*\#.*\#/ && $i > 1 ) {
            $i--;
            $substring = substr( $third_last_word, 0, $i );
        }

        # If the compound boundary is found, mark it with #
        if ( $$refbase =~ /\Q$substring\E/ ) {
            $$refbase =~ s/(\Q$substring\E.*\#.*\#)/\#$1/;
        }
    }
}

# Some character set conversion routines, rarely used nowadays.
# Convert windows charachters to Sami digraphs
sub win_digr {
    my $ctext = shift(@_);

    $ctext =~ s/\212/S1/g;
    $ctext =~ s/\232/s1/g;
    $ctext =~ s/\216/Z1/g;
    $ctext =~ s/\236/z1/g;

    return $ctext;
}

sub digr_utf8 {
    my $ctext = shift(@_);

    $ctext =~ s/A1/Á/g;
    $ctext =~ s/a1/á/g;
    $ctext =~ s/C1/Č/g;
    $ctext =~ s/c1/č/g;
    $ctext =~ s/D1/Đ/g;
    $ctext =~ s/d1/đ/g;
    $ctext =~ s/N1/Ŋ/g;
    $ctext =~ s/n1/ŋ/g;
    $ctext =~ s/S1/Š/g;
    $ctext =~ s/s1/š/g;
    $ctext =~ s/T1/Ŧ/g;
    $ctext =~ s/t1/ŧ/g;
    $ctext =~ s/Z1/Ž/g;
    $ctext =~ s/z1/ž/g;

    return $ctext;
}

1;

__END__
