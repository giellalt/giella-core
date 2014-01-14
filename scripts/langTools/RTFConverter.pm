package langTools::RTFConverter;

use langTools::Preconverter;
@ISA = ("langTools::Preconverter");

sub new {
    my ( $class, $filename, $test ) = @_;

    my $self = $class->SUPER::new( $filename, $test );
    $self->{_converter_xsl} = $self->{_corpus_script} . "/xhtml2corpus.xsl";

    bless $self, $class;
    return $self;
}

sub getXsl {
    my ($self) = @_;
    return $self->{_converter_xsl};
}

sub convert2intermediate {
    my ($self) = @_;

    my $error = 0;
    my $command =
      "unrtf --nopict --html " . $self->getOrig() . " > " . $self->gettmp1();
    if ( $self->exec_com($command) ) {
        print STDERR "Couldn't convert rtf doc to html\n";
        $error = 1;
    }
    else {
        $self->clean_doc();
        $command =
            "tidy -config "
          . $self->{_bindir}
          . "/tidy-config.txt -utf8 -asxml -quiet "
          . $self->gettmp1() . " > "
          . $self->gettmp2();
        if ( $self->exec_com($command) == 512 ) {
            print STDERR "Couldn't tidy rtfhtml\n";
            $error = 1;
        }
        else {
            $command =
                "xsltproc --novalid \""
              . $self->getXsl() . "\" \""
              . $self->gettmp2()
              . "\" > \""
              . $self->gettmp1() . "\"";
            if ( $self->exec_com($command) ) {
                print STDERR "Wasn't able to convert "
                  . $self->getOrig()
                  . " to intermediate xml format\n";
                $error = 1;
            }
        }
    }

    return $error;
}

sub clean_doc {
    my ($self) = @_;

    my %replacements = (
        "<!--- char 0x87 --->\n" => "á",
        "<!--- char 0xbb --->\n" => "š",
        "<!--- char 0xbf --->\n" => "ø",
        "<!--- char 0xe3 --->\n" => "č",
        "<!--- char 0xe2 --->\n" => "Č",
        "<!--- char 0x8c --->\n" => "å",
        "<!--- char 0xf7 --->\n" => "đ",
        '<font face=".*">' => "",
        "</font>" => "",
        "<br>" => "</p>\n<p>",
        "<!--- char 0xb8 --->\n" => "č",
        "<!--- char 0xb9 --->\n" => "đ",
        "<!--- char 0xbe --->\n" => "æ",
        "<!--- char 0xbc --->\n" => "ŧ",
        "<!--- char 0xba --->\n" => "ŋ",
        "<!--- char 0xbd --->\n" => "ž",
    );

    open( FH, "<:encoding(utf8)", $self->gettmp1() )
      or die "Cannot open " . $self->gettmp1() . "$!";
    my @file = <FH>;
    close(FH);

    open( FH, ">:encoding(utf8)", $self->gettmp1() )
      or die "Cannot open " . $self->gettmp1() . "$!";
    foreach my $string (@file) {
        foreach my $a ( keys %replacements ) {
            my $ii = Encode::decode_utf8($a);
            my $i  = Encode::decode_utf8( $replacements{$a} );
            $string =~ s/$ii/$i/g;
        }
        print FH $string;
    }
    close(FH);
}

1;
