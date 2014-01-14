use strict;

use Test::More 'no_plan';
use Test::Exception;
use Test::File;
use Cwd;

#
# Load the modules we are testing
#
BEGIN {
    use_ok( 'langTools::DOCConverter', "usage of package ok" );
}
require_ok('langTools::DOCConverter');

#
# Set a file name, try to make an instance of our object
#
my $doc_name =
  "$ENV{GTFREE}/orig/sme/facta/psykiatriijavideo_nr_1_-_abc-company.doc";
my $converter = langTools::DOCConverter->new( $doc_name, 0 );
isa_ok( $converter, 'langTools::DOCConverter', 'converter' );

isa_ok( $converter, 'langTools::Preconverter', 'converter' );

is(
    $converter->getOrig(),
    Cwd::abs_path($doc_name),
    "Check if path to the orig doc is  correct"
);

file_exists_ok( $converter->getTmpDir(), "Check if tmpdir exists" );

is(
    $converter->getXsl(),
    "$ENV{'GTHOME'}/gt/script/corpus/docbook2corpus2.xsl",
    "Check if docbook2corpus.xsl is set"
);

is( $converter->convert2intermediate(),
    "0", "Check if conversion to internal xml goes well" );

is( search_for_faulty_characters( $converter->gettmp1() ),
    0, "Check if ¶ has been removed" );

sub search_for_faulty_characters {
    my ($filename) = @_;

    my $error  = 0;
    my $lineno = 0;
    if ( !open( FH, "<:encoding(UTF-8)", $filename ) ) {
        print "Cannot open $filename\n";
        $error = 1;
    }
    else {
        while (<FH>) {
            $lineno++;

        # Looking for ¶, but since we are running perl with
        # PERL_UNICODE=, we have to write the utf8 versions of them literally.
        # If not, then lots of «Malformed UTF-8 character» will be spewed out.
            if ( $_ =~ m/\xC2\xB6/ ) {
                print "Failed at line: $lineno with line\n$_\n";
                $error = 1;
                last;
            }
        }
    }
    return $error;
}
