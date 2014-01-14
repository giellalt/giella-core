#!/usr/bin/env perl

use Test::More 'no_plan';
use Test::Exception;
use Test::File;
use utf8;
use strict;
use warnings;

#
# Get options
#
use Getopt::Long;

# options
my $debug = 0;
GetOptions( "debug" => \$debug, );

$langTools::Decode::Test = $debug;

#
# Load the modules we are testing
#
BEGIN {
    use_ok('langTools::Decode');
}
require_ok('langTools::Decode');

# test encoding of the following files
use langTools::Converter;

# filename with expected result
my %body_test_cases = (
    "$ENV{'GTFREE'}/orig/sme/admin/depts/other_files/273777-raportti_saami.pdf" => "0",
    "$ENV{'GTFREE'}/orig/sme/admin/sd/other_files/1999_1s.doc" => "type10",
    "$ENV{'GTBOUND'}/orig/sme/news/MinAigi/1999/other_files/AIB-elg.txt" => "type06",
    "$ENV{'GTBOUND'}/orig/sme/news/MinAigi/2001/1-100/_Listu2mega51.doc" => "type01",
    "$ENV{'GTBOUND'}/orig/sme/news/MinAigi/2003/other_files/_NOTIS_3_-_Onsdag.doc" => "type01",
    "$ENV{'GTBOUND'}/orig/sme/news/MinAigi/2003/other_files/NOTIS_2-FREDAG.doc" => "type01",
    "$ENV{'GTBOUND'}/orig/nob/news/Assu/1997/A34-97/13-ann.beauty_.txt" => "type06",
    "$ENV{'GTBOUND'}/orig/sme/news/Assu/1998/Assunr.85/07-85-sak-neseplaster.txt"  => "type06",
    "$ENV{'GTBOUND'}/orig/sma/facta/other_files/Peehpere_8.3_ferdig.doc" => "0",
    "$ENV{'GTFREE'}/orig/sme/laws/other_files/jus.txt"  => "type12",
);

foreach ( keys %body_test_cases ) {
    test_body_decode( $_, $body_test_cases{$_} );
}

my %person_test_cases = (
    "$ENV{'GTFREE'}/goldstandard/orig/sma/ficti/Kruanebe_Sveerje_politihke.correct.doc" => "type06",
);

foreach ( keys %person_test_cases ) {
    test_person_decode( $_, $person_test_cases{$_} );
}

my %title_test_cases = (
    "$ENV{'GTFREE'}/orig/sma/facta/other_files/Orre_politihke_våarome_rööpses_kruana_reeremassen.sma.doc" => "type06",
);

foreach ( keys %title_test_cases ) {
    test_title_decode( $_, $title_test_cases{$_} );
}

#
# Subroutines
#

# Test the encoding of the body of one file
sub test_body_decode {
    my ( $filename, $expected_result ) = @_;

    print "\nTesting $filename\n";
    my $converter = langTools::Converter->new( $filename, $debug );
    $converter->getPreconverter();
    is( $converter->makeXslFile(),
        '0', "Check if we are able to make the tmp-metadata file" );
    is( $converter->convert2intermediatexml(), '0', "pdf to int xml" );
    is( $converter->convert2xml(),
        '0', "Check if combination of internal xml and metadata goes well" );
    my $text = $converter->get_doc_text();
    isnt( $text, '0', "extract text from xml" );
    my $language = $converter->getPreconverter()->getDoclang();
    is( &guess_body_encoding( $text ),
        $expected_result, "the encoding" );
}

# Test the encoding of lastname attribute of the person tag of one file
sub test_person_decode {
    my ( $filename, $expected_result ) = @_;

    print "\nTesting $filename\n";
    my $converter = langTools::Converter->new( $filename, $debug );
    $converter->getPreconverter();
    is( $converter->makeXslFile(),
        '0', "Check if we are able to make the tmp-metadata file" );
    is( $converter->convert2intermediatexml(), '0', "pdf to int xml" );
    is( $converter->convert2xml(),
        '0', "Check if combination of internal xml and metadata goes well" );
    my $text = $converter->get_person_lastname();
    isnt( $text, '0', "extract text from xml" );
    my $language = $converter->getPreconverter()->getDoclang();
    is( &guess_person_encoding( $text ),
        $expected_result, "the encoding" );
}

# Test the encoding of the title of one file
sub test_title_decode {
    my ( $filename, $expected_result ) = @_;

    print "\nTesting $filename\n";
    my $converter = langTools::Converter->new( $filename, $debug );
    $converter->getPreconverter();
    is( $converter->makeXslFile(),
        '0', "Check if we are able to make the tmp-metadata file" );
    is( $converter->convert2intermediatexml(), '0', "pdf to int xml" );
    is( $converter->convert2xml(),
        '0', "Check if combination of internal xml and metadata goes well" );
    my $text = $converter->get_title_text();
    isnt( $text, '0', "extract text from xml" );
    my $language = $converter->getPreconverter()->getDoclang();
    is( &guess_person_encoding( $text ),
        $expected_result, "the encoding" );
}
