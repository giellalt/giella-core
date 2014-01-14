use Test::More 'no_plan';
use Test::Exception;
use Test::File;
use strict;
use Cwd;
use Encode;
use utf8;
use Getopt::Long;
use warnings;

#
# Load the modules we are testing
#
BEGIN {
    use_ok('langTools::Converter');
}
require_ok('langTools::Converter');

my $debug = 0;
GetOptions( "debug" => \$debug );
$langTools::Decode::Test = $debug;

my $numArgs = $#ARGV + 1;
if ( $#ARGV > -1 ) {
    foreach my $argnum ( 0 .. $#ARGV ) {
        each_file_checks( $ARGV[$argnum] );
    }
}
else {
    my @south_sami_with_edsj_or_esj_docs = (
"$ENV{'GTBOUND'}/orig/sma/facta/other_files/MAAHKE~1_Kap_9.1_FERDIG.DOC",
        "$ENV{'GTBOUND'}/orig/sma/facta/other_files/800602_sydsamOK.pdf",
        "$ENV{'GTBOUND'}/orig/sma/facta/other_files/Peehpere_8.3_ferdig.doc",
"$ENV{'GTBOUND'}/orig/sma/facta/other_files/SaS___Arktiska_Sverige_sammanfattning_1.doc",
"$ENV{'GTBOUND'}/orig/sma/bible/other_files/bibeltekster_medio_mars_2009.doc",
"$ENV{'GTBOUND'}/orig/sma/admin/sd/Översättning_Sametinget_jan08.doc",
        "$ENV{'GTBOUND'}/orig/sma/admin/depts/Från_Sveriges_Riksdag.doc",
"$ENV{'GTBOUND'}/orig/sma/ficti/annajakobsen_don_jih_daan_bijre_1_kap_1-45.orig.rtf",
"$ENV{'GTBOUND'}/orig/sma/ficti/annajakobsen_don_jih_daan_bijre_3_kap_1-38.orig.doc",
        "$ENV{'GTBOUND'}/orig/sma/ficti/Sydsamiska_Sanna_redY_1_.doc",
        "$ENV{'GTFREE'}/orig/sma/facta/other_files/moerh.pdf",
"$ENV{'GTFREE'}/orig/sma/facta/other_files/Orre_politihke_våarome_rööpses_kruana_reeremassen.sma.doc",
"$ENV{'GTFREE'}/orig/sma/admin/depts/regjeringen.no/vaarjelimmiesuerkie-tjarke-byjreskeoffensivine.html_id=611114",
    );

    my @txt_names = (
        "$ENV{'GTBOUND'}/orig/sme/news/Assu/1998/Assunr.47/03-47-NB2.txt",
"$ENV{'GTBOUND'}/orig/sme/news/Assu/1998/Assunr.85/07-85-sak-neseplaster.txt",
        "$ENV{'GTBOUND'}/orig/sme/news/Assu/1998/Assunr.94/10-94-kronihkka.txt",
        "$ENV{'GTBOUND'}/orig/sme/news/MinAigi/2003/other_files/IU-narko.txt",
        "$ENV{'GTBOUND'}/orig/sme/news/MinAigi/2003/other_files/PONDUS.txt",
        "$ENV{'GTBOUND'}/orig/sme/news/MinAigi/2004/007_04/_VM_Kroa_MLA.txt",
"$ENV{'GTBOUND'}/orig/sme/news/MinAigi/2005/011-05/_Govvamuitu_nr_6.txt",
        "$ENV{'GTBOUND'}/orig/sme/news/avvir.no/avvir-article-1258.txt",
        "$ENV{'GTFREE'}/orig/sme/laws/other_files/jus.txt",
        "$ENV{'GTFREE'}/orig/sme/laws/other_files/nac1-1994-24.txt",
    );

    my @pdf_names = (
        "$ENV{'GTBOUND'}/orig/mixed/news/AG/2008/AG02_2008.pdf",
        "$ENV{'GTBOUND'}/orig/nob/facta/other_files/Nordområdestrategi06.pdf",
        "$ENV{'GTBOUND'}/orig/sma/facta/other_files/Vi_vill___MP.pdf",
        "$ENV{'GTBOUND'}/orig/sme/bible/other_files/vitkan.pdf",
"$ENV{'GTFREE'}/orig/sma/admin/depts/other_files/Handlingsplan_2009_samisk_sprak_sorsamisk.pdf",
        "$ENV{'GTFREE'}/orig/sma/facta/other_files/moerh.pdf",
        "$ENV{'GTFREE'}/orig/mixed/admin/depts/other_files/132469-sa-sve.pdf",
"$ENV{'GTFREE'}/orig/sme/admin/depts/other_files/Hoeringsnotat_forskrift_rammeplan_samiske_grunnskolelaererutdanninger_samiskversjon.pdf",
"$ENV{'GTFREE'}/orig/sme/admin/sd/other_files/Strategalaš_plána_sámi_mánáidgárddiide_2001–2005.pdf",
        "$ENV{'GTFREE'}/orig/sme/laws/other_files/Lovom037.pdf",
        "$ENV{'GTFREE'}/orig/sme/facta/other_files/callinravvagat.pdf",
    );

    my @doc_names = (
        "$ENV{'GTBOUND'}/orig/sma/facta/other_files/AKTEPJ~1.DOC",
"$ENV{'GTBOUND'}/orig/sme/news/MinAigi/2003/other_files/_Lohkki_Mathisen.doc",
"$ENV{'GTBOUND'}/orig/sme/news/MinAigi/2004/101-04_Scooter/_Midts._fra_Fred_2610,_sami.doc",
"$ENV{'GTBOUND'}/orig/sme/news/MinAigi/2005/029-05/_ÅP-Májjá_gávppaša.doc",
"$ENV{'GTBOUND'}/orig/sme/news/MinAigi/2005/036-05/_AJ-katrine_boine.doc",
"$ENV{'GTBOUND'}/orig/sme/news/MinAigi/2005/039-05/_AJG-NYjoatkaskuvla.doc",
"$ENV{'GTBOUND'}/orig/sme/news/MinAigi/2005/046-05/_AH-kummalohkki,_NY.doc",
"$ENV{'GTBOUND'}/orig/sme/news/MinAigi/2005/057-05/_s_12-Rabababb.no.doc",
"$ENV{'GTBOUND'}/orig/sme/news/MinAigi/2005/085-05/_UHCA-NYHET-giellaguovddáš.doc",
        "$ENV{'GTBOUND'}/orig/sme/news/MinAigi/2005/101-05/_AJ-porsanger.doc",
        "$ENV{'GTBOUND'}/orig/sme/news/MinAigi/2006/002-06/_JK-Kron-sami.doc",
"$ENV{'GTBOUND'}/orig/sme/news/MinAigi/2006/017-06/_AJ-Josef_vedhuggnes.doc",
        "$ENV{'GTBOUND'}/orig/sme/news/MinAigi/2006/026-06/_JK-arbe.doc",
        "$ENV{'GTBOUND'}/orig/sme/news/MinAigi/2006/046-06/_1side-46.doc",
        "$ENV{'GTBOUND'}/orig/sme/news/MinAigi/2006/051-06/_UHCA_SAMIGP-CD.doc",
        "$ENV{'GTBOUND'}/orig/sme/news/MinAigi/2006/062-06/_HS-WISLØFF.doc",
        "$ENV{'GTBOUND'}/orig/sme/news/MinAigi/2006/070-06/_alm_ØFAS.doc",
        "$ENV{'GTBOUND'}/orig/sme/news/MinAigi/2006/095-06/_AJ-BB.doc",
"$ENV{'GTBOUND'}/orig/sme/news/MinAigi/2007/004-07/_Alm-GP_driftstekniker.doc",
        "$ENV{'GTBOUND'}/orig/sme/news/MinAigi/2007/016-07/_AJ-juoigan.doc",
"$ENV{'GTBOUND'}/orig/sme/news/MinAigi/2007/023-07/_Alm-Bilfører_65+.doc",
"$ENV{'GTBOUND'}/orig/sme/news/MinAigi/2007/034-07/_AJ-Ohcejoga_proseakta.doc",
"$ENV{'GTBOUND'}/orig/sme/news/MinAigi/2007/038-07/_Alm-Finnmark_fylke-felles_16.05.07.doc",
"$ENV{'GTBOUND'}/orig/sme/news/MinAigi/2007/056-2007/_JK-kronihkka-guolli.doc",
"$ENV{'GTBOUND'}/orig/sme/news/MinAigi/2007/075-2007/_AH-Manglende_samepolitikk_i_Sverige_.doc",
"$ENV{'GTBOUND'}/orig/smj/facta/other_files/Aktisasj_goahte_-_biejvvegirjásj_-_Samefolket_6.4.2006.doc",
"$ENV{'GTBOUND'}/orig/smj/facta/other_files/Samisk_som_andresprak_lulesamisk.doc",
        "$ENV{'GTFREE'}/orig/nob/admin/others/aktivitetsplan_2002_no.doc",
"$ENV{'GTFREE'}/orig/sma/admin/depts/other_files/Åarjelsaemien_gïelen_divvun.doc",
"$ENV{'GTFREE'}/orig/sma/facta/other_files/Utlysningsteks_sørsamisk_2_.doc",
"$ENV{'GTFREE'}/orig/sme/admin/guovda/Čoahkkinprotokolla_27.06.02.doc",
"$ENV{'GTFREE'}/orig/sme/admin/guovda/Dá_lea_gihppagaš_mas_leat_dieđut_skuvlla_birra.doc",
"$ENV{'GTFREE'}/orig/sme/admin/others/Tillegg_til_forskrift_vann-_og_avløpsgebyrer_2004.doc",
        "$ENV{'GTFREE'}/orig/sme/admin/sd/other_files/dc_3_99.doc",
"$ENV{'GTFREE'}/orig/sme/facta/other_files/psykiatriijavideo_nr_1_-_abc-company.doc",
    );

    my @html_names = (
        "$ENV{'GTBOUND'}/goldstandard/orig/sme/facta/index.php",
        "$ENV{'GTBOUND'}/goldstandard/orig/sme/facta/printfriendly.aspx",
        "$ENV{'GTFREE'}/orig/dan/facta/skuvlahistorja4/stockfleth-n.htm",
"$ENV{'GTFREE'}/orig/fin/facta/klemetti.blogspot.com/2009/01/saamelaisen-parlamentaarisen-neuvoston.html",
"$ENV{'GTFREE'}/orig/nob/admin/depts/other_files/stdie-nr-10-2003-2004.html",
        "$ENV{'GTFREE'}/orig/nob/admin/depts/regjeringen.no/sok.html_id=86008",
"$ENV{'GTFREE'}/orig/nob/admin/sd/samediggi.no/samediggi-article-84.html",
        "$ENV{'GTFREE'}/orig/nob/facta/nav.no/Foreldrepenger+ved+adopsjon.html",
"$ENV{'GTFREE'}/orig/sma/admin/depts/regjeringen.no/arromelastoeviertieh-prosjektasse--laavlomefaamoe-berlevagesne.html_id=609232",
        "$ENV{'GTFREE'}/orig/sma/facta/skuvlahistorja1/albert_s.html",
        "$ENV{'GTFREE'}/orig/sme/admin/depts/regjeringen.no/1.html_id=458646",
        "$ENV{'GTFREE'}/orig/sme/admin/depts/regjeringen.no/2.html_id=170397",
"$ENV{'GTFREE'}/orig/sme/admin/depts/regjeringen.no/gulaskuddamat-.html_id=1763",
"$ENV{'GTFREE'}/orig/sme/admin/depts/regjeringen.no/gulaskuddan-samelaga-oasteapmi-ovtta-sad.html_id=419602",
"$ENV{'GTFREE'}/orig/sme/admin/depts/regjeringen.no/oktavuohtadiehtojuohkin.html_id=306",
"$ENV{'GTFREE'}/orig/sme/admin/depts/regjeringen.no/organisauvdna.html_id=774",
"$ENV{'GTFREE'}/orig/sme/admin/depts/regjeringen.no/samisk.html_id=454913",
"$ENV{'GTFREE'}/orig/sme/admin/depts/regjeringen.no/stahtaalli-ola-t-heggem-.html_id=1689",
"$ENV{'GTFREE'}/orig/sme/admin/depts/regjeringen.no/stdie-nr-28-2007-2008-.html_id=514290",
"$ENV{'GTFREE'}/orig/sme/admin/depts/regjeringen.no/suodjaluspolitihka-ja-guhkesaiggiplanema-ossodat.html_id=1352",
"$ENV{'GTFREE'}/orig/sme/admin/sd/samediggi.no/samediggi-article-3101.html",
"$ENV{'GTFREE'}/orig/sme/admin/sd/samediggi.no/samediggi-article-3299.html",
        "$ENV{'GTFREE'}/orig/sme/laws/other_files/hl_19700619_069.html",
"$ENV{'GTFREE'}/orig/sme/admin/depts/regjeringen.no/norgga-ruoa-ovttasbargu-nannejuvvo-vel-eambbo.html_id=601912",
        "$ENV{'GTFREE'}/orig/nno/facta/skuvlahistorja4/hansvogt-n.htm",
        "$ENV{'GTFREE'}/orig/nno/facta/skuvlahistorja3/klemetvik-n.htm",
        "$ENV{'GTFREE'}/orig/sme/facta/skuvlahistorja2/malin-s.htm",
"$ENV{'GTFREE'}/orig/sme/admin/sd/samediggi.no/samediggi-article-1267.html",
        "$ENV{'GTFREE'}/orig/nno/admin/depts/regjeringen.no/lover.html_id=293",
        "$ENV{'GTFREE'}/orig/nob/admin/depts/regjeringen.no/oed.html_id=750",
"$ENV{'GTFREE'}/orig/nno/admin/depts/regjeringen.no/ledige-stillingar.html_id=468675",
"$ENV{'GTFREE'}/orig/nno/admin/depts/regjeringen.no/forskings--og-hogare-utdanningsminister-.html_id=486368",
        "$ENV{'GTFREE'}/orig/nob/facta/skuvlahistorja1/sigrunn_n.html",
        "$ENV{'GTBOUND'}/orig/nob/admin/depts/hov008-bn.html",
        "$ENV{'GTFREE'}/orig/sme/facta/skuvlahistorja1/gullich_s.html",
"$ENV{'GTFREE'}/orig/nob/admin/sd/samediggi.no/samediggi-article-3210.html",
        "$ENV{'GTFREE'}/orig/sme/admin/depts/regjeringen.no/2.html_id=610032",
"$ENV{'GTFREE'}/orig/nob/admin/sd/samediggi.no/samediggi-article-3021.html",
"$ENV{'GTFREE'}/orig/nob/admin/depts/other_files/stdie-nr-10-2003-2004_5.html",
    );

    my @correct_names = (
"$ENV{'GTBOUND'}/goldstandard/orig/sma/ficti/Saajve-Læjsa.ocrorig.correct.doc",
"$ENV{'GTBOUND'}/goldstandard/orig/sma/ficti/Tjaebpemes_låvnadahke.ocrorig.correct.doc",
"$ENV{'GTBOUND'}/goldstandard/orig/sme/facta/Barnehageplan_Samisk_3.pdf.correct.xml",
        "$ENV{'GTBOUND'}/goldstandard/orig/sme/learner/uno1.3.correct.txt",
    );

    my @avvir_names = (
"$ENV{'GTBOUND'}/orig/sme/news/Avvir_xml-filer/Avvir_2008_xml-filer/SL_Enare_&_Østsamisk.article.xml",
"$ENV{'GTBOUND'}/orig/sme/news/Avvir_xml-filer/Avvir_2008_xml-filer/s3_lohkki_NSR.article_2.xml",
"$ENV{'GTBOUND'}/orig/sme/news/Avvir_xml-filer/Avvir_2010_xml-filer/SL_Einar_Wiggo_Isaksen(a).article.xml",
    );

    my @biblexml_names =
      ( "$ENV{'GTBOUND'}/orig/sme/bible/ot/Salmmat__garvasat.bible.xml", );

    my @ptx_names = ( "$ENV{'GTBOUND'}/orig/nno/bible/ot/01GENNNST.u8.ptx", );

    my @rtf_names = (
"$ENV{'GTFREE'}/orig/sma/admin/depts/other_files/Samisk_som_andresprak_sorsamisk.rtf",
"$ENV{'GTBOUND'}/goldstandard/orig/sma/ficti/annajakobsen_don_jih_daan_bijre_1.ocrorig.correct.rtf",
    );

    my @svg_names = (
"$ENV{'GTBOUND'}/orig/sme/facta/RidduRiđđu-aviissat/Riddu_Riddu_avis_TXT_200612.svg",
    );

    one_time_checks( $doc_names[0] );

    foreach
      my $south_sami_with_edsj_or_esj_doc (@south_sami_with_edsj_or_esj_docs)
    {
        each_file_checks($south_sami_with_edsj_or_esj_doc);
        look_for_edsj_or_esj($south_sami_with_edsj_or_esj_doc);
    }

    foreach my $txt_name (@txt_names) {
        each_file_checks($txt_name);
    }

    foreach my $pdf_name (@pdf_names) {
        each_file_checks($pdf_name);
    }

    foreach my $doc_name (@doc_names) {
        each_file_checks($doc_name);
    }

    foreach my $html_name (@html_names) {
        each_file_checks($html_name);
    }

    foreach my $correct_name (@correct_names) {
        each_file_checks($correct_name);
    }

    foreach my $avvir_name (@avvir_names) {
        each_file_checks($avvir_name);
    }

    foreach my $biblexml_name (@biblexml_names) {
        each_file_checks($biblexml_name);
    }

    foreach my $ptx_name (@ptx_names) {
        each_file_checks($ptx_name);
    }

    foreach my $rtf_name (@rtf_names) {
        each_file_checks($rtf_name);
    }

    # 	foreach my $svg_name (@svg_names) {
    # 		each_file_checks($svg_name);
    # 	}
    encoding_checks();
}

sub encoding_checks {
    ok(
        my $converter = langTools::Converter->new(
"$ENV{'GTBOUND'}/orig/sme/news/Avvir_xml-filer/Avvir_2009_xml-filer/s5_sak3_norsk.article.xml",
            $debug
        )
    );
    $converter->makeXslFile();
    is( $converter->getEncodingFromXsl(),
        '\'UTF-8\'', "Check if we get the correct encoding from the xsl file" );
}

sub one_time_checks {
    my ($doc_name) = @_;

    ok( my $converter = langTools::Converter->new( $doc_name, $debug ) );
    is(
        $converter->getCommonXsl(),
        "$ENV{'GTHOME'}/gt/script/corpus/common.xsl",
        "Check if common.xsl is set"
    );
    is(
        $converter->getPreprocXsl(),
        "$ENV{'GTHOME'}/gt/script/corpus/preprocxsl.xsl",
        "Check if preprocxsl.xsl is set"
    );
    is( check_decode_para($converter), '0', "Check if decode para works" );
    $converter->makeXslFile();
    is( $converter->getEncodingFromXsl(),
        '\'\'', "Check if we get the correct encoding from the xsl file" );
}

sub each_file_checks {
    my ($doc_name) = @_;

    print "\nTrying to convert $doc_name\n";
    ok( my $converter = langTools::Converter->new( $doc_name, $debug ) );
    is( $converter->getOrig(),
        Encode::decode_utf8( Cwd::abs_path($doc_name) ) );
    is(
        $converter->getInt(),
        $converter->getTmpDir() . "/" . $converter->getTmpFilebase() . ".xml",
        "Check if path to the converted doc is computed correctly"
    );
    is( length( $converter->getTmpFilebase() ), '8' );
    is( $converter->makeXslFile(),
        '0', "Check if we are able to make the tmp-metadata file" );
    is( $converter->convert2intermediatexml(),
        '0', "Check if we are able to make an intermediate xml file" );
    is( $converter->convert2xml(),
        '0', "Check if combination of internal xml and metadata goes well" );
    is( $converter->checklang(), '0', "Check lang. If not set, set it" );
    is( $converter->checkxml(),  '0', "Check if the final xml is valid" );

    if ( $doc_name =~ /\.correct\./ ) {
        is( $converter->error_markup(), '0', "Add error markup" );
    }
    is( $converter->character_encoding(), '0', "Fix character encoding" );
    is( $converter->checkxml(), '0', "Check if the final xml is valid" );
    is( $converter->search_for_faulty_characters( $converter->getInt() ),
        '0', "Content of " . $converter->getInt() . " is correctly encoded" );
    is( $converter->text_categorization(),
        '0', "Check if text categorization goes well" );
    is( $converter->checkxml(), '0', "Check if the final xml is valid" );
    file_exists_ok( $converter->move_int_to_converted(),
        "Check if xml has been moved to final destination" );
    $converter->remove_temp_files();
    file_not_exists_ok( $converter->getInt() );
    file_not_exists_ok( $converter->getIntermediateXml() );
    file_not_exists_ok( $converter->getPreconverter->gettmp2() );
    file_not_exists_ok( $converter->getMetadataXsl() );
}

sub check_decode_para {
    my ($converter) = @_;

    my $error    = 0;
    my $tmp      = "Converter-data/Lovom037.pdf.xml";
    my $document = XML::Twig->new;
    if ( $document->safe_parsefile("$tmp") ) {
        my $root = $document->root;
        my $sub  = $root->{'last_child'}->{'first_child'};
        $error = $converter->call_decode_para( $document, $sub, "type06" );
    }
    else {
        die "ERROR parsing the XML-file «$tmp» failed ";
    }

    return $error;
}

sub look_for_edsj_or_esj {
    my ($doc_name) = @_;

    my $converted_name = $doc_name;
    $converted_name =~ s/orig/converted/;
    $converted_name = $converted_name . ".xml";

    my $result = system("grep -i '[šž]' $converted_name");
    isnt( $result, '0', "look for šŠžŽ" );
}
