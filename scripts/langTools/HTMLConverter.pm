package langTools::HTMLConverter;

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

# Clean out unwanted tags using sed, then run it through tidy
sub tidyHTML {
    my ($self) = @_;

    $command = "tidy.py " . $self->getOrig() . " " . $self->gettmp1();
    $self->exec_com($command);
    $command =
        "tidy -config "
      . $self->{_bindir}
      . "/tidy-config.txt -utf8 -asxml -quiet "
      . $self->gettmp1() . " > "
      . $self->gettmp2();

    return $self->exec_com($command);
}

# Clean the html
# Convert the html to xml using xhtml2corpus.xsl
# Clean the result a little, as well
sub convert2intermediate {
    my ($self) = @_;

    my $error = 0;
    if ( $self->tidyHTML() == 512 ) {
        $error = 1;
    }
    else {
        my $command =
            "xsltproc --novalid \""
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
        "„" => "«",
        "“" => "»"
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
