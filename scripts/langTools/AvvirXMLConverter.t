use strict;

use Test::More 'no_plan';
use Test::Exception;
use Test::File;
use Cwd;

#
# Load the modules we are testing
#
BEGIN {
    use_ok( 'langTools::AvvirXMLConverter', "usage of package ok" );
}
require_ok('langTools::AvvirXMLConverter');

#
# Set a file name, try to make an instance of our object
#
my $doc_name =
"$ENV{'GTBOUND'}/orig/sme/news/Avvir_xml-filer/Avvir_2008_xml-filer/s3_lohkki_NSR.article_2.xml";
my $converter = langTools::AvvirXMLConverter->new( $doc_name, 0 );
isa_ok( $converter, 'langTools::AvvirXMLConverter', 'converter' );

isa_ok( $converter, 'langTools::Preconverter', 'converter' );

is(
    $converter->getOrig(),
    Cwd::abs_path($doc_name),
    "Check if path to the orig doc is  correct"
);

file_exists_ok( $converter->getTmpDir(), "Check if tmpdir exists" );

is(
    $converter->getXsl(),
    "$ENV{'GTHOME'}/gt/script/corpus/avvir2corpus.xsl",
    "Check if avvir2corpus.xsl is set"
);

is( $converter->convert2intermediate(),
    '0', "Check if conversion to internal xml goes well" );
