package langTools::BibleXMLConverter;

use langTools::Preconverter;
@ISA = ("langTools::Preconverter");

sub convert2intermediate {
    my ($self) = @_;

    my $command =
        "bible2xml.pl --out \""
      . $self->gettmp1() . "\" \""
      . $self->getOrig() . "\"";
    my $error = $self->exec_com($command);

    return $error;
}

1;
