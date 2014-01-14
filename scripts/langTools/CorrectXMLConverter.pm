package langTools::CorrectXMLConverter;
@ISA = ("langTools::Preconverter");
use langTools::Preconverter;

use langTools::Decode;
use langTools::Corpus;
use File::Copy;

sub convert2intermediate {
    my ($self) = @_;

    my $error = 0;

    if ( -f $self->getOrig() ) {
        File::Copy::copy( $self->getOrig(), $self->gettmp1() );
    }
    else {
        $error = 1;
    }

    return $error;
}

1;
