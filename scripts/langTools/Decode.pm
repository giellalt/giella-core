package langTools::Decode;

use Getopt::Long;
use File::Basename;
use strict;
use warnings;
use Carp qw(cluck carp);

use utf8;

use Exporter;
our ( $VERSION, @ISA, @EXPORT, @EXPORT_OK );

@ISA = qw(Exporter);

@EXPORT = qw(&guess_body_encoding &guess_person_encoding &decode_para);

our %Error_Types = (

    # mac-sami converted as iconv -f mac -t utf8
    "type01" => {
        "ª"  => "š",
        "¥"  => "Š",
        "º"  => "ŧ",
        "µ"  => "Ŧ",
        "∫" => "ŋ",
        "±"  => "Ŋ",
        "¸"  => "Ŋ",
        "π"  => "đ",
        "∞" => "Đ",
        "Ω" => "ž",
        "∑" => "Ž",
        "∏" => "č",
        "¢"  => "Č",
    },

    # iso-ir-197 converted as iconv -f mac -t utf8
    "type02" => {
        "·"  => "á",
        "¡"  => "Á",
        "≥" => "š",
        "≤" => "Š",
        "∏" => "ŧ",
        "µ"  => "Ŧ",
        "±"  => "ŋ",
        "Ø"  => "Ŋ",
        "§"  => "đ",
        "£"  => "Đ",
        "∫" => "ž",
        "π"  => "Ž",
        "¢"  => "č",
        "°"  => "Č",
        "Ê"  => "æ",
        "Δ"  => "Æ",
        "¯"  => "ø",
        "ÿ"  => "Ø",
        "Â"  => "å",
        "≈" => "Å",
        "‰" => "ä",
        "ƒ"  => "Ä",
        "ˆ"  => "ö",
        "÷"  => "Ö",
    },

    "type03" => {
        "ƒ"  => "š",    #
        "√" => "ŋ",    #
        "∂" => "đ",    #
        "π"  => "ž",    #
        "ª"  => "č",    #
        "º"  => "Č",    #
    },

    # winsami2 converted as iconv -f latin1 -t utf8
    "type04" => {
        "\xc2\x9a" => "š",
        "\xc2\x8a" => "Š",
        "¼"       => "ŧ",
        "º"       => "Ŧ",
        "¹"       => "ŋ",
        "¸"       => "Ŋ",
        ""       => "đ",
        ""       => "Đ",
        "¿"       => "ž",
        "¾"       => "Ž",
        "\xc3\xb6" => "č",
        "\xc3\x96" => "Č",
    },

    # iso-ir-197 converted as iconv -f latin1 -t utf8
    "type05" => {
        "³" => "š",
        "²" => "Š",
        "¸" => "ŧ",
        "µ" => "Ŧ",
        "±" => "ŋ",
        "¯" => "Ŋ",
        "¤" => "đ",
        "£" => "Đ",
        "º" => "ž",
        "¹" => "Ž",
        "¢" => "č",
        "¡" => "Č",
    },

    # mac-sami to latin1
    "type06" => {
        ""  => "á",
        "‡" => "á",
        "ç"  => "Á",
        "»"  => "š",
        "´"  => "Š",
        "¼"  => "ŧ",
        "µ"  => "Ŧ",
        "º"  => "ŋ",
        "±"  => "Ŋ",
        "¹"  => "đ",
        "°"  => "Đ",
        "½"  => "ž",
        "·"  => "Ž",
        "¸"  => "č",
        "¢"  => "Č",
        "¾"  => "æ",
        "®"  => "Æ",
        "¿"  => "ø",
        "¯"  => "Ø",
        ""  => "å",
        "" => "é",
        "Œ" => "å",
        "" => "Å",
        "" => "ä",
        "" => "Ä",
        "" => "ö",
        "" => "Ö",
        "Ê" => " ",
        "¤" => "§",
        "Ò" => "“",
        "Ó" => "”",
        "ª " => "™ ",
        "ªÓ" => "™”",
        "Ã" => "√",
        "Ð" => "–",
        
    },

 # found in boundcorpus/goldstandard/orig/sme/facta/GIEHTAGIRJI.correct.doc
 # and boundcorpus/goldstandard/orig/sme/facta/learerhefte_-_vaatmarksfugler.doc
    "type07" => {
        "ð" => "đ",
        "Ç" => "Č",
        "ç" => "č",
        "ó" => "š",
        "ý" => "ŧ",
        "þ" => "ž",
    },

    # found in freecorpus/orig/sme/admin/sd/other_files/dc_00_1.doc
    # and freecorpus/orig/sme/admin/guovda/KS_02.12.99.doc
    # found in boundcorpus/orig/sme/bible/other_files/vitkan.pdf
    "type10" => {
        "ð"  => "đ",
        "È"  => "Č",
        "è"  => "č",
        "¹"  => "š",
        "¿"  => "ŋ",
        "¾"  => "ž",
        "¼"  => "ŧ",
        "‚" => "Č",
        "„" => "č",
        "¹"  => "ŋ",
        "˜"  => "đ",
        "¿"  => "ž",
    },

    # found in titles in Min Áigi docs
    # double utf'ed letters
    "type11" => {
        "Ã¯"     => "ï",
        "Ã¡"     => "á",
        "Ã\\?"    => "Á",
        "Å¡"     => "š",
        "Â¹"     => "š",
        "Å¾"     => "ž",
        "Å½"    => "Ž",
        "Â«"     => "«",
        "â‰¤"  => "«",
        "Â»"     => "»",
        "â‰¥"  => "»",
        "Ã…"    => "Å",
        "Ã¥"     => "å",
        "Ã…"    => "Å",
        "Ä\\?"    => "č",
        "Ã¨"     => "č",
        "ÄŒ"     => "Č",
        "Ä‘"    => "đ",
        "Ã°"     => "đ",
        "Ä\\?"    => "Đ",
        "Ã¸"     => "ø",
        "Ã˜"     => "Ø",
        "Ã¤"     => "ö",
        "Ã¤"     => "ä",
        "Ã„"    => "Ä",
        "Å§"     => "ŧ",
        "Ã©"     => "é",
        "â€\\?" => "”",
        "Ã¦"     => "æ",
        "Å‹"    => "ŋ",
        "â€¢"  => "•",
    },

    "type12" => {
        "t1" => "ŧ",
        "T1" => "Ŧ",
        "s1" => "š",
        "S1" => "Š",
        "n1" => "ŋ",
        "N1" => "Ŋ",
        "d1" => "đ",
        "D1" => "Đ",
        "z1" => "ž",
        "Z1" => "Ž",
        "c1" => "č",
        "C1" => "Č",
        "ï¾«" => "«",
        "ï¾»" => "»",
    },
);

our $NO_ENCODING = 0;
our $ERROR       = -1;

# Printing some test data, chars and their amounts
our $Test = 0;

# Guess text encoding of $para_ref.
sub guess_body_encoding () {
    my ( $text ) = @_;

    my $max_hits = 0;

    my @text_array;
    my $error    = 0;
    my $encoding = $NO_ENCODING;

    if ( !@text_array ) {
        @text_array = split( "\n", $text );
    }

    for my $type ( sort( keys %Error_Types ) ) {
        my %freq;

        for my $line (@text_array) {
            foreach ( keys %{ $Error_Types{$type} } ) {
                my $key = $_;
                my $tmpline = $line;
                
                # ž is never found in the beginning or end of words
                if ( $key eq '½' and $type eq "type06" ) {
                    $tmpline =~ s/(\s½|½\s)//g;
                }
                while ( $tmpline =~ /$key/g ) {
                    $freq{$key}++;
                }
            }
        }

        my $num = ( keys %freq );

        if (
            %freq
            and (  ( $type eq "type11" )
                or ( $type eq "type06" and $num > 1 )
                or ( $type eq "type07" and $num > 1 )
                or ( $type eq "type10" and $num > 1 )
                or ( $type eq "type01" and $num > 1 )
                or ( $type eq "type03" and $num > 3 )
                or ( $type ne "type03" and $num > 3 ) )
          )
        {
            my $hits = 0;
            for my $key ( keys %freq ) {
                $hits += $freq{$key};
            }
            if ( $hits >= $max_hits ) {
                $max_hits = $hits;
                $encoding = $type;
            }
            
            # type11 always wins over type06 as long as there are any hits for type11
            if ( $encoding eq "type06" and $type eq "type11" and $num > 0 ) {
                $encoding = $type;
            }
                
            if ($Test) {
                print
"body_encoding type is $type, encoding is $encoding, freq is ",
                  %freq, " num is ", $num, " hits is ", $hits, "\n";
            }
        }
    }
    return $encoding;
}

# Guess text encoding of $para_ref.
sub guess_person_encoding () {
    my ( $lastname ) = @_;

    my $max_hits = 0;
    my $encoding = $NO_ENCODING;
    for my $type ( sort( keys %Error_Types ) ) {
        my %freq;

        foreach ( keys %{ $Error_Types{$type} } ) {
            my $key = $_;

            while ( $lastname =~ /$key/g ) {
                $freq{$key}++;
            }
        }

        my $num = ( keys %freq );

        if (
            %freq
            and (  ( $type eq "type11" )
                or ( $type eq "type06" )
                or ( $type eq "type07" )
                or ( $type eq "type10" )
                or ( $type eq "type01" )
                or ( $type eq "type03" )
                or ( $type ne "type03" ) )
          )
        {
            my $hits = 0;
            for my $key ( keys %freq ) {
                $hits += $freq{$key};
            }
            if ( $hits >= $max_hits ) {
                $max_hits = $hits;
                $encoding = $type;
            }
            
            # type11 always wins over type06 as long as there are any hits for type11
            if ( $encoding eq "type06" and $type eq "type11" and $num > 1) {
                $encoding = $type;
            }
                
            if ($Test) {
                print
"type is $type, encoding is $encoding, freq is ",
                  %freq, " num is ", $num, " hits is ", $hits, "\n";
            }
        }
    }
    return $encoding;
}

sub decode_para () {
    my ( $para_ref, $encoding ) = @_;

    if ( !$encoding eq $NO_ENCODING ) { return; }

    # 	if ($Test) {
    # 		print "\n\npara_ref before $$para_ref\n\n";
    # 	}
    foreach ( sort( keys %{ $Error_Types{$encoding} } ) ) {
        $$para_ref =~ s/$_/${$Error_Types{$encoding}}{$_}/g;
    }

    # 	if ($Test) {
    # 		print "\n\npara_ref after $encoding\n $$para_ref\n\n";
    # 	}

    return 0;
}

sub read_file {
    my ( $file, $text_aref, $allow_nonutf ) = @_;

    if ( !open( FH, "<utf8", "$file" ) ) {
        carp "Cannot open file $file";
        return $ERROR;
    }
    else {
        while (<FH>) {
            if ( !utf8::is_utf8($_) ) { return "ERROR"; }
            push( @$text_aref, $_ );
        }
        close(FH);
        return 0;
    }
}

1;

__END__

=head1 NAME

samiChar::Decode.pm -- convert characters byte-wise to other characters.

=head1 SYNOPSIS

    use samiChar::Decode;

    my $file = "file.txt";
    my $outfile = "file.txt";
    my $encoding;
    my $lang = "sme";

    $encoding = &guess_encoding($file, $lang, $para_ref);
    &decode_file($file, $encoding, $outfile);

    $encoding = &guess_text_encoding($file, $outfile, $lang);
    &decode_text_file($file, $encoding, $outfile);


=head1 DESCRIPTION

samiChar::Decode.pm decodes characters to utf-8 byte-wise, using
code tables. It is planned for decoding the Sámi characters
in a situation, where the document is converted to utf-8 without
knowing the original encoding. The decoding is implemented by
using code table files, so the module can be used to other
conversions as well. The output is however always utf-8.

The module contains also a function for guessing the original
encoding. It takes into account only the most common Sámi
characters and their frequency in the text.

=head2 Code tables

Code tables are text files with the following format:

Three space-separated columns:

=over 4

=item    Column #1 is the input char (in hex as 0xXX or 0xXXXX))

=item    Column #2 is the Unicode char (in hex as 0xXXXX)

=item    Column #3 the Unicode name 

=back

Most of the code tables are available at the Unicode Consortium:
L<ftp://ftp.unicode.org/Public/MAPPINGS/>

Some of the code tables like samimac_roman and levi_winsam are composed from two code tables, the one that is used as input encoding and another that is used as the file was converted to utf-8.

=over 4

=item  samimac_roman: codetables samimac.txt and ROMAN.txt

=item  levi_winsam: codetables levi.txt and CP1258.txt

=back

levi.txt and samimac.txt are available under Trond's home page at: L<http://www.hum.uit.no/a/trond/smi-kodetabell.html>. The codetables are composed using the function C<&combine_two_codings($coding1, $coding2, $outfile)> which is
available in this package.

These encodings are available:

=over 4

=item    latin6 => iso8859-10-1.txt

=item    plainroman => ROMAN.txt

=item    CP1258 => CP1258.txt

=item    iso_ir_197 => iso_ir_197.txt

=item    samimac_roman => samimac_roman.txt

=item    levi_winsam => levi_CP1258.txt

=item    winsam => winsam.txt

=item    8859-4 => 8859-4.txt

=back

=head2 Guessing the input encoding

The original input encoding is guessed by examining the text and
searching the most common characters. The unicode 
characters in hex are listed in hash C<%Sami_Chars> for Northern Sámi
for example. The uncommented characters are the ones that take
part into guessing the encoding.

The encodings are listed in the hash C<%Charfiles>, they are tested one
at the time. The occurences of the selected characters
in that encoding are counted and the one with most occurences
is returned. There is a place for more statistical analysis, but
this simple test worked for me.

If there is no certain amount of characters found, the test
returns -1, which means that the characters should be already
correctly utf-8 encoded. 

=head1 BUGS 

There may be mappings that are missing from the list of code tables.

=head1 AUTHOR

Saara Huhmarniemi <saara.huhmarniemi@helsinki.fi>
