use Test::XML tests => 4;
use Test::More;
use strict;
use warnings;
use utf8;
use Getopt::Long;

use langTools::Corpus;

#
# Load the modules we are testing
#
BEGIN {
    use_ok('langTools::Corpus');
}
require_ok('langTools::Corpus');

my $debug = 0;
GetOptions( "debug" => \$debug );
$langTools::Corpus::test = $debug;

# Unset $/, the Input Record Separator, to make <> give the whole file at once,
# aka slurp mode.
local $/=undef;

txtclean('Corpus-data/plain-text.txt', 'Corpus-data/got-plain-text.xml', 'sme');

open(GOT, "<Corpus-data/got-plain-text.xml") or die "File1\n";
open(EXPECT, "<Corpus-data/expect-plain-text.xml") or die "File2\n";

is_xml(<GOT>, <EXPECT>, "Plain text to xml");
close(GOT);
close(EXPECT);

txtclean('Corpus-data/text-with-news-tags.txt', 'Corpus-data/got-text-with-news-tags.xml', 'sme');

open(GOT, "<Corpus-data/got-text-with-news-tags.xml") or die "File3\n";
open(EXPECT, "<Corpus-data/expect-text-with-news-tags.xml") or die "File4\n";

is_xml(<GOT>, <EXPECT>, "Text containing news tags to xml");
close(GOT);
close(EXPECT);
