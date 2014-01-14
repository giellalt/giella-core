use strict;

use Test::More 'no_plan';
use Test::Exception;
use Test::File;
use Cwd;

#
# Load the modules we are testing
#
BEGIN {
    use_ok( 'langTools::SVGConverter', "usage of package ok" );
}
require_ok('langTools::SVGConverter');

#
# Set a file name, try to make an instance of our object
#
my $doc_name =
"$ENV{'GTBOUND'}/orig/sme/facta/RidduRiđđu-aviissat/Riddu_Riddu_avis_TXT.200910.svg";
my $converter = langTools::SVGConverter->new( $doc_name, 1 );
isa_ok( $converter, 'langTools::SVGConverter', 'converter' );

isa_ok( $converter, 'langTools::Preconverter', 'converter' );

is(
    $converter->getOrig(),
    Encode::decode_utf8( Cwd::abs_path($doc_name) ),
    "Check if path to the orig doc is  correct"
);

file_exists_ok( $converter->getTmpDir(), "Check if tmpdir exists" );

is(
    $converter->getXsl(),
    "$ENV{'GTHOME'}/gt/script/corpus/svg2corpus.xsl",
    "Check if svg2corpus.xsl is set"
);

is( $converter->convert2intermediate(),
    '0', "Check if conversion to internal xml goes well" );
