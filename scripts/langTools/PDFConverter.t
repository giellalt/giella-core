use strict;

use Test::More 'no_plan';
use Test::Exception;
use Test::File;
use Cwd;

#
# Load the modules we are testing
#
BEGIN {
    use_ok( 'langTools::PDFConverter', "usage of package ok" );
}
require_ok('langTools::PDFConverter');

#
# Set a file name, try to make an instance of our object
#
my @doc_names = (
    "$ENV{'GTFREE'}/orig/sme/laws/other_files/Lovom037.pdf",
    "$ENV{'GTFREE'}/orig/sme/facta/other_files/callinravvagat.pdf",
"$ENV{'GTFREE'}/orig/sme/admin/depts/other_files/STM200320040010000SE_PDFA.pdf",
);

foreach my $doc_name (@doc_names) {
    my $converter = langTools::PDFConverter->new( $doc_name, 0 );
    isa_ok( $converter, 'langTools::PDFConverter', 'converter' );

    isa_ok( $converter, 'langTools::Preconverter', 'converter' );

    is(
        $converter->getOrig(),
        Cwd::abs_path($doc_name),
        "Check if path to the orig doc is  correct"
    );

    file_exists_ok( $converter->getTmpDir(), "Check if tmpdir exists" );

    is( $converter->convert2intermediate(),
        '0', "Check if conversion to internal xml goes well" );

    # Two backstrokes for perl, two for grep
    is( system( "grep -i \\\\[dstrok " . $converter->gettmp2() . " | wc -l" ),
        0, "Check for strange sami chars" );
}
