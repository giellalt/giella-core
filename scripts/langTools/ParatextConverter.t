use strict;

use Test::More 'no_plan';
use Test::Exception;
use Test::File;
use Cwd;

#
# Load the modules we are testing
#
BEGIN {
    use_ok( 'langTools::ParatextConverter', "usage of package ok" );
}
require_ok('langTools::ParatextConverter');

#
# Set a file name, try to make an instance of our object
#
my $doc_name = "$ENV{'GTBOUND'}/orig/nno/bible/ot/01GENNNST.u8.ptx";
my $converter = langTools::ParatextConverter->new( $doc_name, 0 );
isa_ok( $converter, 'langTools::ParatextConverter', 'converter' );

isa_ok( $converter, 'langTools::Preconverter', 'converter' );

is(
    $converter->getOrig(),
    Cwd::abs_path($doc_name),
    "Check if path to the orig doc is  correct"
);

file_exists_ok( $converter->getTmpDir(), "Check if tmpdir exists" );

is( $converter->convert2intermediate(),
    '0', "Check if conversion to internal xml goes well" );
