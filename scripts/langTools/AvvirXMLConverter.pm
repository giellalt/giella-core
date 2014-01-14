package langTools::AvvirXMLConverter;

use langTools::Preconverter;
@ISA = ("langTools::Preconverter");

sub new {
    my ( $class, $filename, $test ) = @_;

    my $self = $class->SUPER::new( $filename, $test );
    $self->{_converter_xsl} = $self->{_corpus_script} . "/avvir2corpus.xsl";

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
        "xsltproc \""
      . $self->getXsl() . "\" \""
      . $self->getOrig()
      . "\" > \""
      . $self->gettmp1() . "\"";
    if ( $self->exec_com($command) ) {
        $error = 1;
    }

    return $error;
}

1;
