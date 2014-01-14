package langTools::ParatextConverter;

use langTools::Preconverter;
@ISA = ("langTools::Preconverter");

sub convert2intermediate {
    my ($self) = @_;

    my $error = 0;
    my $command =
        $self->{_corpus_script}
      . "/paratext2xml.pl --out \""
      . $self->gettmp2() . "\" \""
      . $self->getOrig()
      . "\" > /dev/null";

    if ( $self->exec_com($command) ) {
        print STDERR "Wasn't able to convert "
          . $self->getOrig()
          . " to bible.xml format\n";
        $error = 1;
    }
    else {
        $command =
            "bible2xml.pl --out \""
          . $self->gettmp1() . "\" \""
          . $self->gettmp2() . "\"";
        if ( $self->exec_com($command) ) {
            "Wasn't able to convert "
              . $self->gettmp2()
              . " to intermediate xml format\n";
            $error = 1;
        }
    }

    return $error;
}

1;
