package langTools::PDFConverter;

use langTools::Corpus;
use langTools::Preconverter;
@ISA = ("langTools::Preconverter");

sub convert2intermediate {
    my ($self) = @_;

    my $error = 0;
    my $command =
        "pdftotext -enc UTF-8 -nopgbrk -eol unix \""
      . $self->getOrig()
      . "\" - > \""
      . $self->gettmp2() . "\"";

    if ( $self->exec_com($command) ) {
        print STDERR "Couldn't convert pdf to plaintext\n";
        $error = 1;
    }
    else {
        $self->clean_doc();
        langTools::Corpus::txtclean( $self->gettmp2(), $self->gettmp1(), "" );
    }

    return $error;
}

sub clean_doc {
    my ($self) = @_;

    my %replacements = (
        "\xc2\xad\x0a", "",
        "\\[dstrok\\]", "đ",
        "\\[Dstrok\\]", "Đ",
        "\\[tstrok\\]", "ŧ",
        "\\[Tstrok\\]", "Ŧ",
        "\\[scaron\\]", "š",
        "\\[Scaron\\]", "Š",
        "\\[zcaron\\]", "ž",
        "\\[Zcaron\\]", "Ž",
        "\\[ccaron\\]", "č",
        "\\[Ccaron\\]", "Č",
        "\\[eng",       "ŋ",
        " \\]",         "",
        "^\\]",         "",
        "Ď"   => "đ",
        "ď"   => "đ",
        "\x3"  => "",
        "\x4"  => "",
        "\x7"  => "",
        "\x8"  => "",
        "\xF"  => "",
        "\x10" => "",
        "\x11" => "",
        "\x13" => "",
        "\x14" => "",
        "\x15" => "",
        "\x17" => "",
        "\x18" => "",
        "\x1A" => "",
        "\x1B" => "",
        "\x1C" => "",
        "\x1D" => "",
        "\x1E" => "",
        "ﬁ"  => "fi",
        "ﬂ"  => "fl",
        "ﬀ"  => "ff",
        "ﬃ"  => "ffi",
        "ﬄ"  => "ffl",
        "ﬅ"  => "ft",
    );

    open( FH, "<:encoding(utf8)", $self->gettmp2() )
      or die "Cannot open " . $self->gettmp1() . "$!";
    my @file = <FH>;
    close(FH);

    open( FH, ">:encoding(utf8)", $self->gettmp2() )
      or die "Cannot open " . $self->gettmp1() . "$!";
    foreach my $string (@file) {
        foreach my $a ( sort( keys %replacements ) ) {
            my $ii = Encode::decode_utf8($a);
            my $i  = Encode::decode_utf8( $replacements{$a} );
            $string =~ s/$ii/$i/g;
        }
        print FH $string;
    }
    close(FH);
}

1;
