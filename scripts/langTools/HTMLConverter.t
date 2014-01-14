use strict;

use Test::More 'no_plan';
use Test::Exception;
use Test::File;
use Cwd;

#
# Load the modules we are testing
#
BEGIN {
    use_ok( 'langTools::HTMLConverter', "usage of package ok" );
}
require_ok('langTools::HTMLConverter');

#
# Set a file name, try to make an instance of our object
#
my @doc_names = (
    "$ENV{'GTFREE'}/orig/sma/facta/skuvlahistorja1/albert_s.html",
"$ENV{'GTFREE'}/orig/sma/admin/depts/regjeringen.no/arromelastoeviertieh-prosjektasse--laavlomefaamoe-berlevagesne.html?id=609232"
);

foreach my $doc_name (@doc_names) {
    my $converter = langTools::HTMLConverter->new( $doc_name, 0 );
    isa_ok( $converter, 'langTools::HTMLConverter', 'converter' );

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

    isnt( $converter->tidyHTML(), '512', "Check if html is tidied" );

    is( $converter->convert2intermediate(),
        '0', "Check if conversion to internal xml goes well" );
}
