use strict;

use Test::More 'no_plan';
use Test::Exception;
use Test::File;
use Cwd;

#
# Load the modules we are testing
#
BEGIN {
    use_ok( 'langTools::RTFConverter', "usage of package ok" );
}
require_ok('langTools::RTFConverter');

#
# Set a file name, try to make an instance of our object
#
my $doc_name =
  "$ENV{'GTBOUND'}/orig/sma/admin/depts/Samisk_som_andresprak_sorsamisk.rtf";
my $converter = langTools::RTFConverter->new( $doc_name, 0 );
isa_ok( $converter, 'langTools::RTFConverter', 'converter' );

isa_ok( $converter, 'langTools::Preconverter', 'converter' );

is(
    $converter->getOrig(),
    Cwd::abs_path($doc_name),
    "Check if path to the orig doc is  correct"
);

file_exists_ok( $converter->getTmpDir(), "Check if tmpdir exists" );

is(
    $converter->getXsl(),
    "$ENV{'GTHOME'}/gt/script/corpus/xhtml2corpus.xsl",
    "Check if xhtml2corpus.xsl is set"
);

is( $converter->convert2intermediate(),
    '0', "Check if conversion to internal xml goes well" );
