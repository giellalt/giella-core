package langTools::DOCConverter;

use langTools::Preconverter;
@ISA = ("langTools::Preconverter");

sub new {
    my ( $class, $filename, $test ) = @_;

    my $self = $class->SUPER::new( $filename, $test );
    $self->{_converter_xsl} = $self->{_corpus_script} . "/docbook2corpus2.xsl";

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
        "antiword -x db \""
      . $self->getOrig()
      . "\" > \""
      . $self->gettmp2() . "\"";

    if ( $self->exec_com($command) ) {
        $error = 1;
    }
    else {
        $command =
            "xsltproc \""
          . $self->getXsl() . "\" \""
          . $self->gettmp2()
          . "\" > \""
          . $self->gettmp1() . "\"";
        if ( $self->exec_com($command) ) {
            $error = 1;
        }
        else {
            $self->clean_doc();
        }
    }

    return $error;
}

sub clean_doc {
    my ($self) = @_;

    my %replacements = (
        "Ã¶" => "ö",    # this has to be here because ¶ otherwise is converted to <\/p><p>
        "ð"   => "đ",
        "¶"   => "<\/p><p>",
        "ﬁ"  => "fi",
        "ﬂ"  => "fl",
        "ﬀ"  => "ff",
        "ﬃ"  => "ffi",
        "ﬄ"  => "ffl",
        "ﬅ"  => "ft",
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
