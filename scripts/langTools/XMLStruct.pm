
package langTools::XMLStruct;

use utf8;
use warnings;
use strict;

use XML::Twig;
use Carp qw(cluck);

use Exporter;
our ( $VERSION, @ISA, @EXPORT, @EXPORT_OK );

# $VERSION = sprintf "%d.%03d", q$Revision$ =~ /(\d+)/g;
@ISA = qw(Exporter);

@EXPORT =
  qw(&dis2html &hyph2html &gen2html &preprocess2xml &dis2xml &analyzer2xml &hyph2xml &paradigm2xml &gen2xml &xml2preprocess &xml2words &xml2dis $fst %dis_tools %action %prep_tools $language $xml_in $xml_out $args &process_paras &get_action &dis2corpus_xml);
@EXPORT_OK = qw(&process_paras);

our (
    $fst,      %dis_tools, %action, %prep_tools, $prep,
    $language, $args,      $xml_in, $xml_out
);

# Store the vislcg or lookup2cg output
# to xml-structure.
sub dis2xml {
    my ($text) = @_;

    my $w;
    my $output = XML::Twig::Elt->new('disamb');

    if ( !$text ) {
        my $string = $output->sprint;
        $output->delete;
        return $string;
    }

    my @input = split( /\n/, $text );
    for my $out (@input) {

        # ignore empty lines
        next if $out =~ /^\s*$/;
        chomp $out;

        # Test the start of the cohort.
        if ( $out =~ /^\"</ ) {

            # Save the cohort from last round.
            if ($w) {
                $w->paste( 'last_child', $output );
                $w->DESTROY;
                undef $w;
            }

            # Read the word and go to next line.
            $out =~ s/^\"<(.*)?>\".*$/$1/;
            $out =~ s/\"/\'/g;
            $w = XML::Twig::Elt->new('w');
            $w->set_att( 'form', $out );
            next;
        }

        $out =~ s/\s+$//;
        $out =~ s/^\s+//;
        $out =~ s/<//g;
        $out =~ /^(\".*?\")\s+(.*)$/;
        my $lemma    = $1;
        my $analysis = $2;
        next if ( !$lemma );
        next if ( !$analysis );

        # If not at the start of the cohort,
        # read the analysis line
        # Create a new XML element for each reading.
        my $reading = XML::Twig::Elt->new('reading');

        $lemma =~ s/\"//g;

        # Remove ^ and # from lemma for now.
        $lemma =~ s/[\^\#]//g;

        $reading->set_att( 'lemma', $lemma );
        if ($analysis) {
            $analysis =~ tr/ /+/;
            $reading->set_att( 'analysis', $analysis );
        }
        $reading->paste( 'last_child', $w );
    }
    if ($w) { $w->paste( 'last_child', $output ); }

    my $string = $output->sprint;
    $output->delete;

    return $string;
}

# Store the vislcg or lookup2cg output
# to xml-structure.
sub dis2html {
    my ( $text, $structure ) = @_;

    my $output = XML::Twig::Elt->new('pre');

    if ( !$text ) {
        if ($structure) { return $output; }
        my $string = $output->sprint;
        $output->delete;
        return $string;
    }
    $output->set_content($text);

    if ($structure) { return $output; }
    else {
        my $string = $output->sprint;
        $output->delete;
        return $string;
    }
}

# Convert the xml-output of analyzator or lookup2cg to
# vislcg input.
sub xml2dis {
    my ($xml) = @_;

    my $string;
    my $twig = XML::Twig->new( keep_encoding => 1 );
    if ( !$twig->safe_parse($xml) ) {
        cluck("Couldn't parse xml");
        return Carp::longmess("Could not parse xml");
    }
    my $root  = $twig->root;
    my @words = $root->children;

    for my $word (@words) {
        $string .= "\"<" . $word->{'att'}->{'form'} . ">\"";
        $string .= "\n";
        my @readings = $word->children;
        for my $r (@readings) {
            my $analysis = $r->{'att'}->{'analysis'};
            $analysis =~ s/\+/ /g;
            $string .= "\t" . "\"" . $r->{'att'}->{'lemma'} . "\"";
            $string .= " " . $analysis;
            $string .= "\n";
        }
    }
    $twig->delete;
    return $string;
}

# Store analyzer output to xml-structure.
sub analyzer2xml {
    my ($text) = shift @_;

    my $word;
    my $w;
    my $output = XML::Twig::Elt->new('analysis');
    $output->set_pretty_print('record');

    if ( !$text ) {
        my $string = $output->sprint;
        $output->delete;
        return $string;
    }

    my @input = split( /\n/, $text );
    for my $out (@input) {

        next if ( !$out );

        if ( $out =~ /^\s*$/ ) {
            if ($w) {
                $w->set_att( 'form', $word );
                $w->paste( 'last_child', $output );
                $w->DESTROY;
                undef $w;
                next;
            }
        }
        chomp $out;
        if ( !$w ) { $w = XML::Twig::Elt->new('w'); }

        my $line;
        ( $word, $line ) = split( /\t/, $out, 2 );

        next if ( !$line );
        my ( $lemma, $analysis ) = split( /\+/, $line, 2 );
        $lemma =~ s/\s+$//;
        my $reading = XML::Twig::Elt->new('reading');
        $reading->set_att( 'lemma', $lemma );
        if ($analysis) { $reading->set_att( 'analysis', $analysis ); }

        $reading->paste( 'last_child', $w );
    }
    if ($w) {
        $w->set_att( 'form', $word );
        $w->paste( 'last_child', $output );
    }

    my $string = $output->sprint;
    return $string;

}

# Convert xml-input of word list
# to analyzer or hyphenator, or possibly generator.
sub xml2words {
    my ($xml) = @_;

    my $string;
    my $twig = XML::Twig->new( keep_encoding => 1 );
    if ( !$twig->safe_parse($xml) ) {
        cluck("Couldn't parse xml");
        return Carp::longmess("Could not parse xml");
    }
    my $root  = $twig->root;
    my @words = $root->children;

    for my $word (@words) {
        if ( $word->{'att'}->{'form'} ) {
            $string .= $word->{'att'}->{'form'};
            $string .= "\n";
        }
    }

    $twig->dispose;
    return $string;
}

# Move hyphenator output to xml-structure.
sub hyph2xml {
    my ($text) = @_;

    my $w;
    my $word;
    my $output = XML::Twig::Elt->new('hyphenation');
    $output->set_pretty_print('record');

    if ( !$text ) {
        my $string = $output->sprint;
        $output->delete;
        return $string;
    }

    my @input = split( /\n/, $text );
    for my $out (@input) {
        if ( $out =~ /^\s*$/ ) {
            if ($w) {
                $w->set_att( 'form', $word );
                $w->paste( 'last_child', $output );
                $w->DESTROY;
                undef $w;
                next;
            }
        }
        chomp $out;

        my $hyph;
        ( $word, $hyph ) = split( /\t/, $out );

        if ( !$w ) { $w = XML::Twig::Elt->new('w'); }
        if ($hyph) {
            my $reading = XML::Twig::Elt->new('reading');
            $reading->set_att( 'hyph', $hyph );
            $reading->paste( 'last_child', $w );
        }
    }
    if ($w) {
        $w->set_att( 'form', $word );
        $w->paste( 'last_child', $output );
    }
    my $string = $output->sprint;
    $output->delete;

    return $string;
}

# Move hyphenator output to xml-structure.
sub hyph2html {
    my ( $text, $structure ) = @_;

    my @content;
    my $output = XML::Twig::Elt->new('p');
    $output->set_pretty_print('record');

    if ( !$text ) {
        if ($structure) { return $output; }

        my $string = $output->sprint;
        $output->delete;
        return $string;
    }
    my @input = split( /\n/, $text );
    for my $out (@input) {
        my ( $word, $hyph ) = split( /\t/, $out );
	if ($hyph && ($hyph !~ /100/) && ($hyph !~ />+/)) { push(@content,$hyph); push (@content," "); next; }
    }

    $output->set_content(@content);
    if ($structure) { return $output; }
    else {
        my $string = $output->sprint;
        $output->delete;
        return $string;
    }
}

sub paradigm2xml {
    my ( $result, $answer, $candidates, $mode ) = @_;

    my $lemma;
    my $analysis;
    my $w = XML::Twig::Elt->new('w');
    $w->set_pretty_print('record');

    for ( my $j = 0 ; $j < $result ; $j++ ) {
        if ( $$answer{$j}{form} ) {
            $w->set_att( 'input', $$answer{$j}{form} );
        }

        my $paradigm = XML::Twig::Elt->new('paradigm');
        if ( $$answer{$j}{anl} ) {
            my ( $l, $anl ) = split( /\+/, $$answer{$j}{anl}, 2 );
            $paradigm->set_att( 'analysis', $anl );
            $paradigm->set_att( 'lemma',    $l );
        }
        my @input = split( /\n/, $$answer{$j}{para} );
        for my $out (@input) {
            if ( $out =~ /^\s*$/ ) { next; }
            chomp $out;
            my ( $line, $form ) = split( /\t/, $out, 2 );
            next if ( !$form );
            $form =~ s/^\s+//;

            ( $lemma, $analysis ) = split( /§/, $line, 2 );
            if ( !$analysis ) {
                ( $lemma, $analysis ) = split( /\+/, $line, 2 );
            }

            my $surface = XML::Twig::Elt->new('surface');
            $surface->set_att( 'form',     $form );
            $surface->set_att( 'analysis', $analysis );
            $surface->set_att( 'form',     $form );
            $surface->paste( 'last_child', $paradigm );
            $surface->DESTROY;
        }
        $paradigm->paste( 'last_child', $w );
        $paradigm->DESTROY;

        # If minimal mode, show only first paradigm
        last if ( !$mode || $mode eq "minimal" );
    }
    if ( keys %$candidates ) {
        my $cands = XML::Twig::Elt->new('other');
        for my $c ( keys %$candidates ) {
            my $cand = XML::Twig::Elt->new( 'anl', $c );
            $cand->paste( 'last_child', $cands );
        }
        $cands->paste( 'last_child', $w );
    }

    my $string = $w->sprint;
    $w->delete;
    return $string;

}    # End of paradigm output

# Move generator output to xml-structure.
sub gen2xml {
    my ( $text, $paradigm ) = @_;

    my $w;
    my $lemma;
    my $analysis;
    my $output;
    if   ($paradigm) { $output = XML::Twig::Elt->new('paradigm'); }
    else             { $output = XML::Twig::Elt->new('generation'); }
    $output->set_pretty_print('record');

    if ( !$text ) {
        my $string = $output->sprint;
        $output->delete;
        return $string;
    }

    my @input = split( /\n/, $text );
    for my $out (@input) {
        if ( $out =~ /^\s*$/ ) {
            if ($w) {
                $w->set_att( 'lemma', $lemma );
                if ( !$paradigm ) { $w->set_att( 'analysis', $analysis ); }
                $w->paste( 'last_child', $output );
                $w->DESTROY;
                undef $w;
                next;
            }
        }
        chomp $out;

        my ( $line, $form ) = split( /\t/, $out, 2 );
        next if ( !$form );
        $form =~ s/^\s+//;

        ( $lemma, $analysis ) = split( /§/, $line, 2 );
        if ( !$analysis ) { ( $lemma, $analysis ) = split( /\+/, $line, 2 ); }

        if ( !$w ) { $w = XML::Twig::Elt->new('w'); }
        my $surface = XML::Twig::Elt->new('surface');
        $surface->set_att( 'form', $form );
        if ($paradigm) { $surface->set_att( 'analysis', $analysis ); }
        $surface->set_att( 'form', $form );
        $surface->paste( 'last_child', $w );
    }
    if ($w) {
        $w->set_att( 'lemma', $lemma );

        #$w->set_att('analysis', $analysis);
        $w->paste( 'last_child', $output );
    }

    my $string = $output->sprint;
    $output->delete;

    return $string;

}

# Move generator output to html-table.
sub gen2html {
    my ( $text, $paradigm, $structure, $fulllemma ) = @_;

    my $tr;
    my $td;
    my $font;
    my $lemma;
    my $analysis;
    my $output;
    $output = XML::Twig::Elt->new('table');
    $output->set_pretty_print('record');

    if ( !$text ) {
        if ($structure) { return $output; }
        my $string = $output->sprint;
        $output->delete;
        return $string;
    }
    my $first_part;
    if ($fulllemma) { ( $first_part = $fulllemma ) =~ s/\#[^\#]+$//; }

    my @input = split( /\n/, $text );

    my $prev_analysis    = "";
    my $colored_analysis = "";
    for my $out (@input) {
        chomp $out;

        my ( $line, $form ) = split( /\t/, $out, 2 );
        next if ( !$form );
        $form =~ s/^\s+//;
        if ($fulllemma) { $form = $first_part . $form; }
        $form =~ s/\#//g;

        ( $lemma, $analysis ) = split( /\+/, $line, 2 );
        if ($fulllemma) { $lemma = $fulllemma; $lemma =~ s/\#//g; }

        # There may be more than one form for an analysis
        # to separate different paradigms,
        # try to group them.
        if ( $analysis && $prev_analysis eq $analysis ) {
            $td   = XML::Twig::Elt->new('td');
            $font = XML::Twig::Elt->new('font');
            $font->set_att( 'color', 'red' );
            $font->set_text($form);
            $font->paste( 'last_child', $td );
            if ($tr) { $td->paste( 'last_child', $tr ); }
            next;
        }
        if ($tr) {
            $tr->paste( 'last_child', $output );
            undef $tr;
        }

        $tr = XML::Twig::Elt->new('tr');

        $td   = XML::Twig::Elt->new('td');
        $font = XML::Twig::Elt->new('font');
        $font->set_att( 'color', 'maroon' );
        $font->set_text($lemma);
        $font->paste( 'last_child', $td );
        $td->paste( 'last_child', $tr );

        if ($analysis) {
            $td = XML::Twig::Elt->new('td');
            ( $colored_analysis = $analysis ) =~
              s/(\+)/<font color=\"grey\">$1<\/font>/g;
            $td->set_text($colored_analysis);
            $td->paste( 'last_child', $tr );
        }

        $td   = XML::Twig::Elt->new('td');
        $font = XML::Twig::Elt->new('font');
        $font->set_att( 'color', 'red' );
        $font->set_text($form);
        $font->paste( 'last_child', $td );
        $td->paste( 'last_child', $tr );

        $prev_analysis = $analysis;
    }
    if ($tr) { $tr->paste( 'last_child', $output ); }

    if ($structure) { return $output; }
    else {
        my $string = $output->sprint;
        $output->delete;
        return $string;
    }
}

# Move preprocessor output  to xml-structure
sub preprocess2xml {
    my ($text) = @_;

    my $output = XML::Twig::Elt->new('preprocess');
    $output->set_pretty_print('record');

    if ( !$text ) {
        my $string = $output->sprint;
        $output->delete;
        return $string;
    }

    my @input = split( /\n/, $text );

    for my $out (@input) {
        chomp $out;
        my $w = XML::Twig::Elt->new('w');
        $w->set_att( 'form', $out );
        $w->paste( 'last_child', $output );
    }
    my $string = $output->sprint;
    $output->delete;

    return $string;
}

# preprocessor input read from xml-structure.
sub xml2preprocess {
    my $xml = shift @_;

    my $twig = XML::Twig->new( keep_encoding => 1 );
    if ( !$twig->safe_parse($xml) ) {
        cluck("Couldn't parse xml.");
        return Carp::longmess("Could not parse xml");
    }
    my $root = $twig->root;
    my $text = $root->text;

    $root->delete;
    $twig->dispose;
    return $text;
}

sub dis2corpus_xml {
    my ( $text, $tags_href, $w_num_ref, $id ) = @_;

    my $xml = dis2xml($text);

    #print $xml;

    my $string;
    my $twig = XML::Twig->new();

    #my $twig = XML::Twig->new(keep_encoding => 1);
    if ( !$twig->safe_parse($xml) ) {
        cluck("Couldn't parse xml");
        return Carp::longmess("Could not parse xml");
    }
    $twig->set_pretty_print('record');
    my $root  = $twig->root;
    my @words = $root->children;

    for my $word (@words) {

        my $id = $id . "_w" . $$w_num_ref++;
        $word->set_att( 'id', $id );
        for my $reading ( $word->children ) {

            my $reading_text = $reading->{'att'}->{'analysis'};

            # Create a new XML element for each reading.
            my (@tag_list) = split( /\+/, $reading_text );

            # Process each tag and store them to XML attributes
            # for the reading.
            for my $tag (@tag_list) {
                for my $class ( keys %$tags_href ) {
                    if ( exists $$tags_href{$class}{$tag} ) {

                        # Store the tag to XML attribute of the reading
                        $reading->set_att( $class, $tag );
                    }
                }
            }
            $reading->del_att('analysis');
        }    # end while readings

    }
    return $root;
}

sub get_action {
    my $line = shift @_;

    print "$line\n";
    my $document = XML::Twig->new;
    if ( !$document->safe_parse("$line") ) {
        cluck("Could not parse parameters.");
        return Carp::longmess("ERROR Could not parse $line");
    }
    my $root   = $document->root;
    my $action = $root->{'att'}->{'tool'};

    return $action;
}

# Processing instructions are parsed
# from XML-structure.
sub process_paras {
    my $parameters = shift @_;

    my $document = XML::Twig->new( keep_encoding => 1 );
    if ( !$document->safe_parse("$parameters") ) {
        cluck("Could not parse parameters.");
        return Carp::longmess("Could not parse parameters: $parameters");
    }
    my $root = $document->root;
    my $lang = $root->first_child('lang');
    if ( !$lang || !$lang->text ) {
        cluck("No language specified.");
        return Carp::longmess("No language specified: $parameters");
    }
    else { $language = $lang->text; }

    my %default_args = (
        "dis"  => "--quiet",
        "anl"  => "-flags -mbTT -utf8",
        "gen"  => "-flags -mbTT -utf8 -d",
        "para" => "-flags -mbTT -utf8 -d",
        "hyph" => "-flags -mbTT -utf8",
        "prep" => "",
    );

    my %default_tools = (
        "anl_fst"      => "/opt/smi/$language/bin/$language.fst",
        "hyph_fst"     => "/opt/smi/$language/bin/hyph-$language.fst",
        "hyph_filter"  => "/opt/smi/common/bin/hyph-filter.pl",
        "gen_fst"      => "/opt/smi/$language/bin/i$language-norm.fst",
        "para_fst"     => "/opt/smi/$language/bin/i$language.fst",
        "para_grammar" => "/opt/smi/$language/bin/paradigm.$language.txt",
        "para_tags"    => "/opt/smi/$language/bin/korpustags.$language.txt",
        "prep_fst"     => "/opt/smi/$language/bin/$language.fst",
        "prep_abbr"    => "/opt/smi/$language/bin/$language.fst",
        "prep_corr"    => "/opt/smi/$language/bin/$language.fst",
    );

    if ( !-f $default_tools{'para_tags'} ) {
        $default_tools{'para_tags'} = "/opt/smi/common/bin/korpustags.txt";
    }
    if ( !-f $default_tools{'para_grammar'} ) {
        $default_tools{'para_grammar'} = "/opt/smi/common/bin/paradigm.txt";
    }
    $xml_in  = $root->first_child('xml_in');
    $xml_out = $root->first_child('xml_out');
    my @actions = $root->children('action');
    my %tools;
    for my $act (@actions) {
        my $tool          = $act->{'att'}->{'tool'};
        my $tmp_fst       = $act->{'att'}->{'fst'};
        my $tmp_args      = $act->{'att'}->{'args'};
        my $rle           = $act->{'att'}->{'rle'};
        my $abbr          = $act->{'att'}->{'abbr'};
        my $corr          = $act->{'att'}->{'corr'};
        my $filter        = $act->{'att'}->{'filter'};
        my $filter_script = $act->{'att'}->{'filter_script'};
        my $mode          = $act->{'att'}->{'mode'};
        my $grammar       = $act->{'att'}->{'grammar'};
        my $tags          = $act->{'att'}->{'tags'};

        if (   $tool eq 'anl'
            || $tool eq 'hyph'
            || $tool eq 'gen'
            || $tool eq 'para' )
        {
            if ($tmp_fst) { $action{$tool}{'fst'} = $tmp_fst; }
            else { $action{$tool}{'fst'} = $default_tools{ $tool . "_fst" }; }
            if   ($tmp_args) { $action{$tool}{'args'} = $tmp_args; }
            else             { $action{$tool}{'args'} = $default_args{$tool}; }
            if ($filter) {
                if ($filter_script) {
                    $action{$tool}{'filter'} = $filter_script;
                }
                else {
                    $action{$tool}{'filter'} = $default_tools{'hyph_filter'};
                }
            }
            if ( $tool eq "para" ) {
                if ($grammar) { $action{$tool}{'grammar'} = $grammar; }
                else {
                    $action{$tool}{'grammar'} = $default_tools{'para_grammar'};
                }
                if ($tags) { $action{$tool}{'tags'} = $tags; }
                else { $action{$tool}{'tags'} = $default_tools{'para_tags'}; }
                if ($mode) { $action{$tool}{'mode'} = $mode; }
            }
            next;
        }
        if ( $tool eq 'dis' ) {
            $action{'dis'} = 1;
            if ($rle) { $dis_tools{'rle'} = $rle; }
            else {
                $dis_tools{'rle'} = "/opt/smi/$language/bin/$language-dis.fst";
            }

      #			if ($bin) { $dis_tools{'bin'}=$bin; }
      #			else { $dis_tools{'bin'}="/opt/smi/$language/bin/$language-dis.fst"; }
            if   ($tmp_args) { $dis_tools{'args'} = $tmp_args; }
            else             { $dis_tools{'args'} = $default_args{'dis'}; }
            next;
        }
        if ( $tool eq 'prep' ) {
            $action{'prep'} = 1;
            if   ($tmp_fst) { $prep_tools{'fst'} = $tmp_fst; }
            else            { $prep_tools{'fst'} = $default_tools{'prep_fst'}; }
            if   ($abbr) { $prep_tools{'abbr'} = $abbr; }
            else         { $prep_tools{'abbr'} = $default_tools{'prep_abbr'}; }
            if   ($corr) { $prep_tools{'corr'} = $corr; }
            else         { $prep_tools{'corr'} = $default_tools{'prep_corr'}; }
            if   ($tmp_args) { $prep_tools{'args'} = $tmp_args; }
            else             { $prep_tools{'args'} = $default_args{'prep'}; }
            next;
        }
    }
    if ( !%action ) {
        cluck("No action specified.");
        return Carp::longmess("No action specified $parameters");
    }
    return 0;
}

1;

__END__
