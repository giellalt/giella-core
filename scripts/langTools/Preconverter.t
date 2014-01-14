use Test::More 'no_plan';
use Test::Exception;
use strict;
use Cwd;
use Encode;

#
# Load the modules we are testing
#
BEGIN {
    use_ok('langTools::Preconverter');
}
require_ok('langTools::Preconverter');

my $doc_name =
"$ENV{'GTBOUND'}/orig/sme/facta/RidduRiđđu-aviissat/Riddu_Riddu_avis_TXT.200910.svg";
ok( my $converter = langTools::Preconverter->new( $doc_name, 0 ) );

is( $converter->check_dependencies(),
    "0", "Check if all the dependencies are there" );
isnt( $converter->getDoclang(), "", "Check if doclang is empty" );
is(
    $converter->getOrig(),
    Encode::decode_utf8( Cwd::abs_path($doc_name) ),
    "Test if the original is the given file name"
);
is( length( $converter->getTmpFilebase() ),
    '8',
    "Check if the random file name is made and is of the expected length" );

