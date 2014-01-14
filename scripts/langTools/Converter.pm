package langTools::Converter;
use langTools::AvvirXMLConverter;
use langTools::BibleXMLConverter;
use langTools::HTMLConverter;
use langTools::ParatextConverter;
use langTools::RTFConverter;
use langTools::DOCConverter;
use langTools::PlaintextConverter;
use langTools::PDFConverter;
use langTools::SVGConverter;
use langTools::CorrectXMLConverter;
use langTools::CantHandle;
use langTools::Decode;

use strict;
use utf8;
use warnings;
use Carp qw(cluck carp);
use XML::Twig;

sub new {
    my ( $class, $filename, $test ) = @_;

    my $self = {};
    $self->{_test}          = $test;
    $self->{_bindir}        = "$ENV{'GTHOME'}/gt/script";
    $self->{_corpus_script} = $self->{_bindir} . "/corpus";
    $self->{_common_xsl}    = $self->{_corpus_script} . "/common.xsl";
    $self->{_preproc_xsl}   = $self->{_corpus_script} . "/preprocxsl.xsl";
    $self->{_xsltemplate}   = $self->{_corpus_script} . "/XSL-template.xsl";

    bless $self, $class;

    unless ( $self->makePreconverter( $filename, $test ) ) {
        $self->getPreconverter();
        $self->{_tmpfile_base}     = $self->getPreconverter()->getTmpFilebase();
        $self->{_orig_file}        = $self->getPreconverter()->getOrig();
        $self->{_tmpdir}           = $self->getPreconverter()->getTmpDir();
        $self->{_intermediate_xml} = $self->getPreconverter()->gettmp1();
    }

    return $self;
}

sub makePreconverter {
    my ( $self, $filename, $test ) = @_;

    my $error    = 0;
    my $abs_path = Cwd::abs_path($filename);
    $self->{_preconverter} = undef;

    if ( $abs_path =~ /Avvir/ && $abs_path =~ /\.xml$/ ) {
        $self->{_preconverter} =
          langTools::AvvirXMLConverter->new( $filename, $test );
    }
    elsif ( $abs_path =~ /\.bible\.xml$/ ) {
        $self->{_preconverter} =
          langTools::BibleXMLConverter->new( $filename, $test );
    }
    elsif ( $abs_path =~
        /(\.html_id=\d*|\.html$|\.htm$|\.php\?id=\d*|\.php$|\.aspx$)/ )
    {
        $self->{_preconverter} =
          langTools::HTMLConverter->new( $filename, $test );
    }
    elsif ( $abs_path =~ /\.ptx$/ ) {
        $self->{_preconverter} =
          langTools::ParatextConverter->new( $filename, $test );
    }
    elsif ( $abs_path =~ /\.rtf$/ ) {
        $self->{_preconverter} =
          langTools::RTFConverter->new( $filename, $test );
    }
    elsif ( $abs_path =~ /\.doc$/i ) {
        $self->{_preconverter} =
          langTools::DOCConverter->new( $filename, $test );
    }
    elsif ( $abs_path =~ /\.txt$/ ) {
        $self->{_preconverter} =
          langTools::PlaintextConverter->new( $filename, $test );
    }
    elsif ( $abs_path =~ /(\.pdf$|\.ai$)/ ) {
        $self->{_preconverter} =
          langTools::PDFConverter->new( $filename, $test );
    }
    elsif ( $abs_path =~ /\.svg$/ ) {
        $self->{_preconverter} =
          langTools::SVGConverter->new( $filename, $test );
    }
    elsif ( $abs_path =~ /\.correct.xml$/ ) {
        $self->{_preconverter} =
          langTools::CorrectXMLConverter->new( $filename, $test );
    }
    else {
        $self->{_preconverter} = langTools::CantHandle->new( $filename, $test );
    }
    return $error;
}

sub getOrig {
    my ($self) = @_;
    return $self->{_orig_file};
}

sub getInt {
    my ($self) = @_;

    #
    my $int = $self->getTmpDir() . "/" . $self->getTmpFilebase();
    return $int . ".xml";
}

sub getTmpFilebase {
    my ($self) = @_;
    return $self->{_tmpfile_base};
}

sub getCommonXsl {
    my ($self) = @_;
    return $self->{_common_xsl};
}

sub getPreprocXsl {
    my ($self) = @_;
    return $self->{_preproc_xsl};
}

sub getTmpDir {
    my ($self) = @_;
    return $self->{_tmpdir};
}

sub getMetadataXsl {
    my ($self) = @_;
    return $self->{_metadata_xsl};
}

sub getIntermediateXml {
    my ($self) = @_;
    return $self->{_intermediate_xml};
}

sub getXslTemplate {
    my ($self) = @_;
    return $self->{_xsltemplate};
}

sub getPreconverter {
    my ($self) = @_;
    return $self->{_preconverter};
}

sub getFinalName {
    my ($self) = @_;
    ( my $int = $self->getOrig() ) =~ s/\/orig\//\/converted\//;
    return $int . ".xml";
}

sub get_debug {
    my ($self) = @_;
    return $self->{_test};
}

sub get_logfile {
    my ($self) = @_;
    return $self->{_logfile};
}

sub makeXslFile {
    my ($self) = @_;
    $self->{_metadata_xsl} =
      $self->getTmpDir() . "/" . $self->getTmpFilebase() . ".xsl";

    my $command = undef;

    if ( !-f $self->getOrig() . ".xsl" ) {
        File::Copy::copy( $self->getXslTemplate(), $self->getOrig() . ".xsl" );
    }

    my $protected = $self->getOrig();
    $protected =~ s/\(/\\(/g;
    $protected =~ s/\)/\\)/g;
    $protected =~ s/\&/\\&/g;

    $command =
        "xsltproc --novalid --stringparam commonxsl "
      . $self->getCommonXsl() . " "
      . $self->getPreprocXsl() . " "
      . $protected . ".xsl" . " > "
      . $self->getMetadataXsl();

    return $self->exec_com($command);
}

sub makeFinalDir {
    my ($self) = @_;
    if ( !-e File::Basename::dirname( $self->getFinalName() ) ) {
        File::Path::mkpath( File::Basename::dirname( $self->getFinalName() ) );
    }

    return;
}

sub exec_com {
    my ( $self, $com ) = @_;

    if ( $self->get_debug() ) {
        print STDERR $self->getOrig() . " exec_com: $com\n";
    }

    my $result = system($com);
    if ( $result != 0 ) {
        print STDERR "Errnr: $result. Errmsg: $com: $!\n";
    }

    return $result;
}

sub convert2intermediatexml {
    my ($self) = @_;

    return $self->getPreconverter()->convert2intermediate();
}

sub convert2xml {
    my ($self) = @_;

    my $command =
        "xsltproc --novalid \""
      . $self->getMetadataXsl() . "\" \""
      . $self->getIntermediateXml()
      . "\" > \""
      . $self->getInt() . "\"";

    return $self->exec_com($command);
}

sub checkxml {
    my ($self) = @_;

    my $command =
"xmllint --noout --dtdvalid file:///$ENV{'GTHOME'}/gt/dtd/corpus.dtd --postvalid --encode UTF-8 "
      . $self->getInt();
    return $self->exec_com($command);
}

sub checklang {
    my ($self) = @_;

    # Check the main language,  add whether it is missing.
    my $tmp      = $self->getInt();
    my $document = XML::Twig->new;
    if ( !$document->safe_parsefile("$tmp") ) {
        carp "ERROR parsing the XML-file «$tmp» failed ";
        return "1";
    }
    my $root     = $document->root;
    my $mainlang = $root->{'att'}->{'xml:lang'};
    my $id       = $root->{'att'}->{'id'};

    if ( !$mainlang || $mainlang eq "unknown" ) {
        # Setting language by using the directory path is a better 'guess' for 
        # documents lacking this piece of information
        $root->set_att( 'xml:lang', $self->getPreconverter()->getDoclang() );
    }
    my $fh;
    open( $fh, ">:encoding(utf8)", $tmp ) or die "Cannot open $tmp $!";
    $document->set_pretty_print('indented');
    $document->print($fh);
    close $fh;

    return 0;
}

sub getOCRFromXsl {
    my ($self) = @_;

    my $retval   = "ERROR";
    my $document = XML::Twig->new;
    if ( $document->safe_parsefile( $self->getMetadataXsl() ) ) {
        my $root    = $document->root;
        my $ocr_elt = $root->first_child('xsl:variable[@name="ocr"]');
        if ($ocr_elt) {
            $retval = $ocr_elt->{'att'}{'select'};
        }
        else {
            $retval = "''";
        }
    }

    return $retval;
}

sub getEncodingFromXsl {
    my ($self) = @_;

    my $document = XML::Twig->new;
    if ( $document->safe_parsefile( $self->getMetadataXsl() ) ) {
        my $root = $document->root;
        my $coding_elt =
          $root->first_child('xsl:variable[@name="text_encoding"]');
        if ($coding_elt) {
            return $coding_elt->{'att'}{'select'};
        }
        else {
            return "";
        }
    }
    else {
        return "ERROR";
    }
}

sub get_doc_text {
    my ($self) = @_;

    my $int = $self->getInt();

    my $twig = XML::Twig->new();
    if ( $twig->safe_parsefile($int) ) {
        my $root = $twig->root;
        my $body = $root->first_child('body');
        my $text = $body->text();
        return $text;
    }
    else {
        return 0;
    }
}

sub get_person_lastname {
    my ($self) = @_;

    my $int = $self->getInt();

    my $twig = XML::Twig->new();
    if ( $twig->safe_parsefile($int) ) {
        my $root = $twig->root;
        my $person = $root->first_child('header')->first_child('author')->first_child('person');
        my $text = $person->{'att'}{'lastname'};
        return $text;
    }
    else {
        return 0;
    }
}

sub get_title_text {
    my ($self) = @_;

    my $int = $self->getInt();

    my $twig = XML::Twig->new();
    if ( $twig->safe_parsefile($int) ) {
        my $root = $twig->root;
        my $title = $root->first_child('header')->first_child('title');
        my $text = $title->text;
        return $text;
    }
    else {
        return 0;
    }
}

sub character_encoding {
    my ($self) = @_;

    #my ($file, $int, $no_decode_this_time) = @_;

    my $file     = $self->getOrig();
    my $int      = $self->getInt();
    my $test     = $self->getPreconverter()->getTest();
    my $language = $self->getPreconverter()->getDoclang();
    my $error    = 0;

    # Check if the file contains characters that are wrongly
    # utf-8 encoded and decode them.

    my $text     = $self->get_doc_text();
    my $encoding = $self->getEncodingFromXsl();
    $encoding =~ s/'//g;
    my $fh;
    if ( $encoding eq "ERROR" ) {
        $error = 1;
    }
    else {
        if ( !$encoding ) {
            $encoding = &guess_body_encoding( $text );
        }
        if ($test) {
            print "(character_encoding) Encoding is: $encoding\n";
        }

        my $d;
        if ( $encoding ne $langTools::Decode::NO_ENCODING ) {
            $d = XML::Twig->new(
                twig_handlers => {
                    'p' => sub { call_decode_para( $self, @_, $encoding ); },
                    'title'  => sub { call_decode_title( $self,   @_ ); },
                    'person' => sub { call_decode_person( $self, @_ ); },
                    'header' => sub { set_word_count($self, @_); },
                }
            );
        }
        else {
            $d = XML::Twig->new(
                twig_handlers => {
                    'title'  => sub { call_decode_title( $self,   @_ ); },
                    'person' => sub { call_decode_person( $self, @_ ); },
                    'header' => sub { set_word_count($self, @_); },
                }
            );
        }

        if ( !$d->safe_parsefile("$int") ) {
            carp "ERROR parsing the XML-file failed.\n";
            $error = 1;
        }
        elsif ( !open( $fh, ">:encoding(utf8)", $int ) ) {
            carp "ERROR cannot open file";
            $error = 2;
        }
        else {
            $d->set_pretty_print('indented');
            $d->print($fh);
            close($fh);
        }
    }
    return $error;

}

# Decode false utf8-encoding for text paragraph.
sub call_decode_para {
    my ( $self, $twig, $para, $coding ) = @_;

    # 	print "(call_decode_para) encoding $coding\n";
    my $language = $self->getPreconverter()->getDoclang();
    my $error    = 0;

    $para = recursively_decode_text( $para, $language, $coding );

    return $error;
}

sub recursively_decode_text {
    my ( $element, $language, $coding ) = @_;

    my @new_content;

    for my $child ( $element->children ) {
        if ( $child->tag eq "#PCDATA" ) {
            my $text = $child->text;
            &decode_para( \$text, $coding );
            push( @new_content, $text );
        }
        else {
            push( @new_content,
                recursively_decode_text( $child, $language, $coding ) );
        }
    }

    $element->set_content(@new_content);

    return $element;
}

sub call_decode_person {
    my ( $self, $twig, $person, $coding ) = @_;

    my $text = $person->{'att'}{'lastname'};
    $coding = &guess_person_encoding($text);
    &decode_para( \$text, $coding );
    $person->atts->{'lastname'} = $text;

}

sub call_decode_title {
    my ( $self, $twig, $title, $coding ) = @_;

    my $text = $title->text;
    $coding = &guess_person_encoding($text);
    &decode_para( \$text, $coding );
    my @new_content;
    push( @new_content, $text );
    $title->set_content( @new_content );
}

sub set_word_count {
    my ($self, $twig, $header) = @_;
    
    my $words = $self->get_total_wordcount();
    
    my $wordcount = $header->first_child('wordcount');
    
    if (!$wordcount) {
        $wordcount = XML::Twig::Elt->new('wordcount');
        $wordcount->set_text($words);

        my @tags = ('collection', 'publChannel', 'place', 'year', 'translated_from', 'translator', 'author');
        foreach my $tag (@tags) {
            my $found = $header->first_child($tag);
            
            if ($found) {
                $wordcount->paste('after', $found);
                last;
            }
        }
    }
    else {
        $wordcount->set_text($words);
    }
}

sub error_markup {
    my ($self) = @_;

    my $error    = 0;
    my $int      = $self->getInt();
    my $document = XML::Twig->new(
        twig_handlers => {
            'p' => sub { langTools::Corpus::add_error_markup(@_); }
        }
    );
    if ( !$document->safe_parsefile("$int") ) {
        carp "ERROR parsing the XML-file failed. STOP\n";
        return 1;
    }

    my $fh;
    if ( !open( $fh, ">:encoding(utf8)", $int ) ) {
        carp "ERROR cannot open file STOP";
        return 1;
    }
    $document->set_pretty_print('indented');
    $document->print($fh);
    close($fh);

    return $error;
}

sub move_int_to_converted {
    my ($self) = @_;

    $self->makeFinalDir();
    if ( -f $self->getInt() ) {
        File::Copy::copy( $self->getInt(), $self->getFinalName() );
        return $self->getFinalName();
    }
    else {
        return;
    }
}

sub search_for_faulty_characters {
    my ( $self, $filename ) = @_;

    my $error  = 0;
    my $lineno = 0;

    # The theory is that only the sami languages can be erroneously encoded ...
    if ( $self->getPreconverter->getDoclang() =~ /(sma|sme|smj)/ ) {
        my $fh;
        if ( !open( $fh, "<:encoding(utf8)", $filename ) ) {
            print "(Search for faulty) Cannot open: " . $filename . "\n";
            $error = 1;
        }
        else {
            while (<$fh>) {
                $lineno++;
                if ( $_ =~
/(¤|Ä\?|Ď|ª|Ω|π|∏|Ã|Œ|α|ρ|λ|ν|χ|υ|τ|Δ|Λ|þ|±|¢|¿|˜)/
                  )
                {
                    print STDERR "In file "
                      . $filename
                      . " (base is "
                      . $self->getOrig() . " )\n";
                    print STDERR
                      "Faulty character at line: $lineno with line\n$_\n";
                    $error = 1;
                }
            }
        }
        close $fh;
    }
    return $error;
}

sub remove_temp_files {
    my ($self) = @_;

    unlink( $self->getInt() );
    unlink( $self->getIntermediateXml() );
    unlink( $self->getPreconverter()->gettmp2() );
    unlink( $self->getMetadataXsl() );

    return;
}

# Redirect STDERR to log files.
sub redirect_stderr_to_log {
    my ($self) = @_;
    if ( !$self->get_debug() ) {
        $self->{_log_file} =
          $self->getPreconverter()->getTmpDir() . "/"
          . File::Basename::basename( $self->getOrig() ) . ".log";
        open STDERR, '>', $self->{_log_file} or die "Can't redirect STDERR: $!";
    }

    return;
}

sub text_categorization {
    my ($self) = @_;

    my $command =
"$ENV{'GTHOME'}/tools/lang-guesser/text_cat.pl -q -x -d $ENV{'GTHOME'}/tools/lang-guesser/LM \""
      . $self->getInt() . "\"";
    return $self->exec_com($command);
}

sub analyze_content {
    my ($self) = @_;

    if ( $self->getPreconverter()->getDoclang() =~ m/sm[aej]/ ) {
        my $wordcount         = $self->get_mainlang_wordcount();
        my $unknown_wordcount = $self->find_unknown_words();

        # Avoid division by zero ...
        if ( $wordcount > 0 ) {

            # if wordcount is less than 100 words, improve the ratio ...
            if ( $wordcount < 100 ) {
                $wordcount *= 2;
            }
            my $ratio = $unknown_wordcount / $wordcount * 100;
            return $unknown_wordcount / $wordcount * 100;
        }
        else {
            return 0;
        }
    }
    else {
        return 0;
    }
}

sub get_mainlang_ratio {
    my ($self) = @_;

    my $total_wordcount    = $self->get_total_wordcount();
    my $mainlang_wordcount = $self->get_mainlang_wordcount();

    if ( $total_wordcount > 0 ) {
        my $ratio = $mainlang_wordcount / $total_wordcount * 100;
        return $ratio;
    }
    else {
        return 0;
    }
}

sub find_unknown_words {
    my ($self) = @_;

    my $mainlang = $self->getPreconverter()->getDoclang();
    my $preprocess;
    my $gthome = $ENV{'GTHOME'};
    my $int    = $self->getInt();
    
    # Macs need ssed for the -r flag below
    my $sed;
    if ( `uname` eq "Darwin\n" ) {
        $sed = "ssed";
    } else {
        $sed = "sed";
    }

    if ( $mainlang eq "sme" || $mainlang eq "smj" ) {
        $preprocess =
"preprocess --corr=$gthome/gt/$mainlang/bin/corr.txt --abbr=$gthome/gt/$mainlang/bin/abbr.txt";
    }
    else {
        $preprocess = "preprocess --corr=$gthome/gt/$mainlang/bin/corr.txt";
    }

    my $ukw =
`ccat -l $mainlang -a $int | $preprocess | $sed -r -e 's_http:.*__' -e 's_\\w+\\.\\w+__' | sort -u | lookup -flags mbTT $gthome/gt/$mainlang/bin/$mainlang.fst | fgrep '+?' | wc -l`;

    if ( $self->{_test} ) {
        print "this is unknown words: " . $ukw . "\n";
        print
`ccat -l $mainlang -a $int | $preprocess | $sed -r -e 's_http:.*__' -e 's_\\w+\\.\\w+__' | sort -u | lookup -flags mbTT $gthome/gt/$mainlang/bin/$mainlang.fst | fgrep '+?'`;
    }

    return $ukw;
}

sub get_mainlang_wordcount {
    my ($self) = @_;

    my $mainlang = $self->getPreconverter()->getDoclang();
    my $int      = $self->getInt();
    my $wc       = `ccat -l $mainlang -a -S $int | wc -l`;

    if ( $self->{_test} ) {
        print "this is mainlang word count: " . $wc . "\n";
    }

    return $wc;
}

sub get_total_wordcount {
    my ($self) = @_;

    my $int = $self->getInt();
    my $wc  = trim(`ccat -a -S $int | wc -l`);

    if ( $self->{_test} ) {
        print "this is total word count: " . $wc . "\n";
    }

    return $wc;
}

sub do_parallels_exist {
    my ($self) = @_;

    my $document = XML::Twig->new;
    if ( $document->safe_parsefile( $self->getMetadataXsl() ) ) {
        my $root = $document->root;
        my $parallel_texts_elt =
          $root->first_child('xsl:variable[@name="parallel_texts"]');
        if (   $parallel_texts_elt
            && $parallel_texts_elt->{'att'}{'select'} eq "'1'" )
        {
            return $self->which_parallels_do_exist($root);
        }
    }
    return 0;
}

sub which_parallels_do_exist {
    my ( $self, $root ) = @_;

    my @langs = (
        "dan", "eng", "fin", "fkv", "ger", "isl", "kal", "nno",
        "nob", "sma", "sme", "smj", "swe"
    );

    for my $lang (@langs) {
        my $key      = 'xsl:variable[@name="para_' . $lang . '"]';
        my $para_elt = $root->first_child($key);
        my $para_doc = $para_elt->{'att'}{'select'};
        $para_doc =~ s/'//g;
        if ( $para_doc ne "" ) {
            my $para     = $self->getOrig();
            my $mainlang = $self->getPreconverter()->getDoclang();
            $para =~ s/\/$mainlang\//\/$lang\//;
            my $x = rindex( $para, "/" );
            my $para_file =
              substr( $para, 0, rindex( $para, "/" ) + 1 ) . $para_doc;
            unless ( -e $para_file ) {
                print STDERR "Parallel file $para_file doesn't exist\n";
                return 1;
            }
        }
    }
    return 0;
}

# remove whitespace from the start and end of the string
sub trim($)
{
        my $string = shift;
        $string =~ s/^\s+//;
        $string =~ s/\s+$//;
        return $string;
}


1;
