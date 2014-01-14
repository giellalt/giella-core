package langTools::Corpus;

use utf8;
use open 'utf8';

use warnings;
use strict;

use XML::Twig;
use Carp qw(cluck carp);

use Exporter;
our ( @ISA, @EXPORT, @EXPORT_OK );

@ISA = qw(Exporter);

@EXPORT = qw(&add_error_markup &pdfclean &txtclean);

#@EXPORT_OK   = qw(&process_paras);

#our ($fst);

our %types = (
    "\$"  => "errorort",
    "¢"  => "errorortreal",
    "€" => "errorlex",
    "£"  => "errormorphsyn",
    "¥"  => "errorsyn",
    "§"  => "error"
);

our $sep = quotemeta("€§£\$¥¢");

our $test = 0;

# Change the manual error markup §,$,€,¥,£ to xml-structure.
sub add_error_markup {
    my ( $twig, $para ) = @_;

    $para = recursive_search_for_error_expression($para);
}

sub recursive_search_for_error_expression {
    my ($element) = @_;

    my @new_content;

    for my $child ( $element->children ) {
        if ( $child->tag eq "#PCDATA" ) {
            my $text = $child->text;
            push( @new_content, error_parser($text) );
        }
        else {
            push( @new_content, recursive_search_for_error_expression($child) );
        }
    }

    $element->set_content(@new_content);

    return $element;
}

sub error_parser {
    my ($text) = @_;

    my $error = undef;
    my $separator;
    my $correct;
    my $rest;
    my $error_elt;
    my @new_content;

    my $counter = 0;
    while ( $text =~ m/[$sep]\S/ and $counter < 200 ) {
        $counter++;
        if ($test) {
            print "\n\nerror_parser 61 $text\n";
        }

        if ( $text =~ s/([$sep])(\([^\)]*\)|\S+)(.*)//s ) {
            $text .= $1;
            $separator = $1;
            $correct   = $2;
            $rest      = $3;

            if ($test) {
                print
"error_parser __LINE__ text «$text» separator «$separator» correct «$correct» rest «$rest»\n";
            }

            $text =~
s/(\([^\(]*\)|\w+|\w+[-\':\]]\w+|\w+[-\'\]\.]|\d+’\w+|\d+%:\w+)([$sep])//s;
            $error = $1;
            $correct =~ s/\)//;
            $correct =~ s/\(//;

            if ($test) {
                print
"error_parser __LINE__ text «$text» error «$error» separator «$separator» correct «$correct» rest «$rest»\n";
            }

            if ( $error =~ /[$sep]/ ) {

                # we are in a nested markup
                my $parenthesis;
                if ( $text =~ s/\)[$sep]// ) {
                    $parenthesis = 1;
                }
                elsif ( $text =~ s/^[$sep]// ) {
                    $parenthesis = 0;
                }
                my @part1;
                if ( !$text eq "" ) {
                    unshift( @part1, $text );
                }
                my $found_start = 1;
                my $next_bit;
                while ( $found_start && ( $next_bit = pop(@new_content) ) ) {
                    $counter++;
                    if ( ref($next_bit) eq 'XML::Twig::Elt' ) {
                        unshift( @part1, $next_bit );
                    }
                    else {
                        if ($test) {
                            print "error_parser __LINE__ $next_bit\n";
                        }
                        if ($parenthesis) {
                            my $position = rindex( $next_bit, '(' );
                            if ( $position > -1 ) {
                                $found_start = 0;
                                if ( length($next_bit) > 1 ) {
                                    if ($test) {
                                        print "to part1: "
                                          . substr( $next_bit, $position + 1,
                                            length($next_bit) )
                                          . "\n";
                                        print "back to new_content: "
                                          . substr( $next_bit, 0, $position )
                                          . "\n";
                                    }
                                    if ( $position == 0 ) {
                                        unshift(
                                            @part1,
                                            substr(
                                                $next_bit,
                                                $position + 1,
                                                length($next_bit)
                                            )
                                        );
                                    }
                                    elsif ( $position + 1 == length($next_bit) )
                                    {
                                        push( @new_content,
                                            substr( $next_bit, 0, $position ) );
                                    }
                                    else {
                                        unshift(
                                            @part1,
                                            substr(
                                                $next_bit,
                                                $position + 1,
                                                length($next_bit)
                                            )
                                        );
                                        push( @new_content,
                                            substr( $next_bit, 0, $position ) );
                                    }
                                }
                            }
                            else {
                                unshift( @part1, $next_bit );
                            }
                        }
                        else {
                            push( @new_content, $next_bit );
                            $found_start = 0;
                        }
                    }
                }
                $error_elt = XML::Twig::Elt->new('dummy');
                $error_elt->set_content(@part1);
                $error_elt = get_error( $error_elt, $separator, $correct );
            }
            else {

                # a simple error
                $error =~ s/\)//;
                $error =~ s/\(//;
                $error_elt = get_error( $error, $separator, $correct );
                push( @new_content, $text );
            }
            push( @new_content, $error_elt );
            $text = $rest;
            if ($test) {
                print "error_parser __LINE__ «@new_content», text «$text»\n\n";
            }
        }
    }
    push( @new_content, $text );
    return @new_content;
}

sub look_for_extended_attributes {
    my ($correct) = @_;
    
    my $extatt  = 0;
    my $attlist = "";
    if ( $correct =~ /\|/ ) {
        $extatt = 1;
        ( $attlist, $correct ) = split( /\|/, $correct );
        $attlist =~ s/\s//g;
        if ($test) { 
            print STDERR "Attribute list is: $attlist.\n"; 
        }
    }
    
    return ($correct, $extatt, $attlist);
}

sub get_error_element_name {
    my ($separator) = @_;
    
    if ( $types{$separator} ) { 
        return $types{$separator}; 
    }
    else {
        return "error";
    }
}

sub make_error_element {
    my ($error, $fixed_correct, $error_elt_name) = @_;
    my $error_elt;
    
    if ( ref($error) eq 'XML::Twig::Elt' ) {
        $error_elt = $error;
        $error_elt->set_tag($error_elt_name);
        $error_elt->set_att( correct => $fixed_correct );
    }
    else {
        $error_elt = XML::Twig::Elt->new(
            $error_elt_name => { correct => $fixed_correct },
            $error
        );
    }


    return $error_elt;
}

sub set_common_attributes {
    my ($error_elt, $pos, $errtype, $teacher) = @_;
    
    if ($pos)     { $error_elt->set_att( 'pos',     $pos ); }
    if ($errtype) { $error_elt->set_att( 'errtype', $errtype ); }
    if ($teacher) { $error_elt->set_att( 'teacher', $teacher ); }
    
    return $error_elt;
}

sub add_orthographical_error_attributes {
    my ($error_elt, $attlist) = @_;
    
    #           print "errorort: $attlist\n";
    my ( $pos, $errtype, $teacher ) = split( /,/, $attlist );
    if ( $errtype eq 'yes' || $errtype eq 'no' ) {
        $teacher = $errtype;
        $errtype = "";
    }
    elsif ( $pos eq 'yes' || $pos eq 'no' ) {
        $teacher = $pos;
        $pos     = "";
        $errtype = "";
    }

    $error_elt = set_common_attributes($error_elt, $pos, $errtype, $teacher);
    
    return $error_elt;
}

sub add_lexical_error_attributes {
    my ($error_elt, $attlist) = @_;
    
    #           print "errorlex: $attlist\n";
    my ( $pos, $origpos, $errtype, $teacher ) =
        split( /,/, $attlist, 4 );
    if ( $errtype eq 'yes' || $errtype eq 'no' ) {
        $teacher = $errtype;
        $errtype = "";
    }
    elsif ( $origpos eq 'yes' || $origpos eq 'no' ) {
        $teacher = $origpos;
        $origpos = "";
        $errtype = "";
    }
    elsif ( $pos eq 'yes' || $pos eq 'no' ) {
        $teacher = $pos;
        $pos     = "";
        $origpos = "";
        $errtype = "";
    }
    
    $error_elt = set_common_attributes($error_elt, $pos, $errtype, $teacher);
    
    if ($origpos) {
        $error_elt->set_att( 'origpos', $origpos );
    }

    return $error_elt;
}

sub add_morphosyntactic_error_attributes {
    my ($error_elt, $attlist) = @_;
    
    #           print "errormorphsyn: $attlist\n";
    my ( $pos, $const, $cat, $orig, $errtype, $teacher ) =
        split( /,/, $attlist, 6 );
    if ( $errtype eq 'yes' || $errtype eq 'no' ) {
        $teacher = $errtype;
        $errtype = "";
    }
    elsif ( $orig eq 'yes' || $orig eq 'no' ) {
        $teacher = $orig;
        $orig    = "";
        $errtype = "";
    }
    elsif ( $cat eq 'yes' || $cat eq 'no' ) {
        $teacher = $cat;
        $cat     = "";
        $orig    = "";
        $errtype = "";
    }
    elsif ( $const eq 'yes' || $const eq 'no' ) {
        $teacher = $const;
        $const   = "";
        $cat     = "";
        $orig    = "";
        $errtype = "";
    }
    elsif ( $pos eq 'yes' || $pos eq 'no' ) {
        $teacher = $pos;
        $pos     = "";
        $const   = "";
        $cat     = "";
        $orig    = "";
        $errtype = "";
    }

    $error_elt = set_common_attributes($error_elt, $pos, $errtype, $teacher);
    
    if ($const)   { $error_elt->set_att( 'const',   $const ); }
    if ($cat)     { $error_elt->set_att( 'cat',     $cat ); }
    if ($orig)    { $error_elt->set_att( 'orig',    $orig ); }

    return $error_elt;
}

sub add_syntactic_error_attributes {
    my ($error_elt, $attlist) = @_;

    #           print "errorsyn: $attlist\n";
    my ( $pos, $errtype, $teacher ) = split( /,/, $attlist );
    if ( $errtype eq 'yes' || $errtype eq 'no' ) {
        $teacher = $errtype;
        $errtype = "";
    }
    elsif ( $pos eq 'yes' || $pos eq 'no' ) {
        $teacher = $pos;
        $pos     = "";
        $errtype = "";
    }
    $error_elt = set_common_attributes($error_elt, $pos, $errtype, $teacher);
    
    return $error_elt;
}

sub add_extra_attributes {
    my ($separator, $error_elt, $attlist) = @_;
    # Add attributes for orthographical errors:
    if (   $types{$separator} eq 'errorort'
        || $types{$separator} eq 'errorortreal' )
    {
        $error_elt = add_orthographical_error_attributes($error_elt, $attlist);
    }

    # Add attributes for lexical errors:
    if ( $types{$separator} eq 'errorlex' ) {
        $error_elt = add_lexical_error_attributes($error_elt, $attlist);
    }

    # Add attributes for morphosyntactic errors:
    if ( $types{$separator} eq 'errormorphsyn' ) {
        $error_elt = add_morphosyntactic_error_attributes($error_elt, $attlist);
    }

    # Add attributes for syntactic errors:
    if ( $types{$separator} eq 'errorsyn' ) {
        $error_elt = add_syntactic_error_attributes($error_elt, $attlist);
    }
    
    return $error_elt;
}

sub get_error {
    my ( $error, $separator, $correct ) = @_;

    my ($fixed_correct, $extatt, $attlist) = look_for_extended_attributes($correct);
    
    my $error_elt_name = get_error_element_name($separator);
    
    my $error_elt = make_error_element($error, $fixed_correct, $error_elt_name);
    
    # Add extra attributes if found:
    if ($extatt) {
        $error_elt = add_extra_attributes($separator, $error_elt, $attlist);
    }
    if ($test) {
        print "error_parser __LINE__ ";
        $error_elt->print;
        print "\n";
    }

    return $error_elt;
}

# Clean the output of an extracted pdf-file
sub pdfclean {

    my $file = shift @_;

    if ( !open( INFH, "$file" ) ) {
        print STDERR "$file: ERROR open failed: $!. ";
        return;
    }

    my $number = 0;
    my $string;
    my @text_array;
    while ( $string = <INFH> ) {

        # Clean the <pre> tags
        next if ( $string =~ /pre>/ );

        # Leave  the line as is if it starts with html tag.
        if ( $string =~ m/^\</ ) {
            push( @text_array, $string );
            next;
        }

        $string =~ s/[\n\r]/ /;

      # This if-construction is for finding the line numbers
      # (which generally are in their own line and even separated by empty lines
      # The text before and after the line number is connected.

        if ( $string =~ /^\s*$/ ) {
            if ( $number == 1 ) {
                next;
            }
            else {
                $string = "<\/p>\n<p>";
            }
        }
        if ( $string =~ /^\d+\s*$/ ) {
            $number = 1;
            next;
        }

       # Headers are guessed and marked
       # This should be done after the decoding to get the characters correctly.
        $string =~ s/^([\d\.]+[\w\s]*)$/\n<\/p>\n<h2>$1<\/h2>\n<p>\n/;
        $number = 0;

        push( @text_array, $string );
    }
    close(INFH);

    open( OUTFH, ">$file" ) or die "Cannot open file $file: $!";
    print( OUTFH @text_array );
    close(OUTFH);
}

# routine for printing out header in the middle of processing
# used in subroutine txtclean.
sub printheader {
    my ( $header, $fh ) = @_;

    $header->print($fh);
    $header->DESTROY;
    print $fh qq|<body>|;

}

sub print_header {
    my ( $outfile ) = @_;
    
    print $outfile qq|<?xml version='1.0'  encoding="UTF-8"?>|, "\n";
    
}

sub initialize_xml_structure {
    my ( $lang ) = @_;
    
    my $twig = XML::Twig->new(map_xmlns => {'http://www.w3.org/XML/1998/namespace' => "xml"});
    $twig->set_pretty_print('indented');

    my $document = XML::Twig::Elt->new('document');
    $document->set_att( 'xml:lang' => $lang);
    
    my $header = XML::Twig::Elt->new('header');
    $header->paste('last_child', $document);
    
    my $body   = XML::Twig::Elt->new('body');
    $body->paste('last_child', $document);
    
    $twig->set_root( $document );

    return $twig;
}

sub handle_newstext_tags {
    my ( $twig, $string ) = @_;
    
    my $body = $twig->root->first_child('body');
    my $header = $twig->root->first_child('header');
    my $notitle = 1;
    my @text_array;
    my $maxtitle = 80;
    my $title;
    my $p;
    
    while ( $string =~ s/(\@(.*?)\:[^\@]*)// ) {
        push @text_array, $1;
    }
    for my $line (@text_array) {
        if ( $line =~ /^\@(.*?)\:(.*?)$/ ) {
            my $tag  = $1;
            my $text = $2;

            if ( $tag =~ /(titt|m.titt)/ && $text ) {
                $text =~ s/[\r\n]+//;

                # If the title is too long, there is probably an error
                # and the text is treated as normal paragraph.
                if ( length($text) > $maxtitle ) {
                    $p = XML::Twig::Elt->new('p');
                    $p->set_text($text);
                    $p->paste( 'last_child', $body );
                    $p = undef;
                    next;
                }
                if ($notitle) {
                    $title = XML::Twig::Elt->new('title');
                    $title->set_text($text);
                    $title->paste( 'last_child', $header );
                    $notitle = 0;
                }
                my $p = XML::Twig::Elt->new('p');
                $p->set_att( 'type', "title" );
                $p->set_text($text);
                my $section = XML::Twig::Elt->new('section');
                $p->paste( 'last_child', $section );
                $section->paste( 'last_child', $body );
                $p = undef;
                next;
            }
            if ( $tag =~ /(tekst|ingress)/ ) {
                my $p = XML::Twig::Elt->new('p');
                $p->set_text($text);
                $p->paste( 'last_child', $body );
                $p = undef;
                next;
            }
            if ( $tag =~ /(byline)/ ) {
                $text =~ s/[\r\n]+//;
                my $a = XML::Twig::Elt->new('author');
                my $p = XML::Twig::Elt->new('person');
                $p->set_att( 'firstname', "" );
                $p->set_att( 'lastname',  "$text" );
                $p->paste( 'last_child', $a );
                $p = undef;
                $a->paste( 'last_child', $header );
                next;
            }
            my $p = XML::Twig::Elt->new('p');
            $p->set_text($text);
            $p->set_att( 'type', "title" );
            $p->paste( 'last_child', $body );
            $p = undef;
            next;
        }
        else {
            carp "ERROR: line did not match: $line\n";
            return "ERROR";
        }
    }
}

# Add preliminary xml-structure for the text files.
sub txtclean {

    my ( $file, $outfile, $lang ) = @_;

    my $replaced = qq(\^\@\;|–&lt;|\!q|&gt);

    # Open file for printing out the summary.
    my $FH1;
    open( $FH1, ">$outfile" );

    print_header( $FH1, $lang );
    
    # Initialize XML-structure
    my $twig = initialize_xml_structure($lang);
    my $body = $twig->root->first_child('body');
    my $header = $twig->root->first_child('header');
    my $title;
    # Start reading the text
    # enable slurp mode
    local $/ = undef;
    if ( !open( INFH, "$file" ) ) {
        print STDERR "$file: ERROR open failed: $!. ";
        
    } else {

        my $text    = 0;
        my $p;

        while ( my $string = <INFH> ) {

            #		print "string: $string\n";
            $string =~ s/($replaced)//g;
            $string =~ s/\\//g;

            # remove all the xml-tags.
            $string =~ s/<.*?>//g;
            $string =~ s/[<>]//g;
            
            

            if ( !$string ){
            } else {
                # The text contains newstext tags:
                if ( $string =~ /\@(.*?)\:/ ) {
                    handle_newstext_tags( $twig, $string );
                }
                    
                # The text does not contain newstext tags:
                else {
                    my $notitle = 0;
                    my $p_continues = 0;

                    my @text_array = split( /[\n\r]/, $string );
                    for my $line (@text_array) {
                        $line .= "\n";
                        if ( !$p ) {
                            $p = XML::Twig::Elt->new('p');
                            $p->set_text($line);
                            $p_continues = 1;
                            next;
                        }
                        if ( $line =~ /^\s*\n/ ) {
                            $p_continues = 0;
                            next;
                        }
                        if ($p_continues) {
                            my $orig_text = $p->text;
                            $line = $orig_text . $line;
                            $p->set_text($line);
                        }
                        else {
                            $p->paste( 'last_child', $body );
                            $p = undef;
                            $p = XML::Twig::Elt->new('p');
                            $p->set_text($line);
                            $p_continues = 1;
                        }
                    }
                }
            }
        }
        close INFH;

        if ( $p && $body ) {
            $p->paste( 'last_child', $body );
        }
        
        $twig->print($FH1);

        close $FH1;
    }
}

1;

__END__
