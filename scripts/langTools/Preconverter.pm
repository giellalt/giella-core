package langTools::Preconverter;
use strict;
use File::Basename;
use File::Path;
use Cwd;
use utf8;
use Carp qw(cluck carp);
use XML::Twig;
use Encode;

sub new {
    my ( $class, $filename, $test ) = @_;

    my $abs_path = Encode::decode_utf8( Cwd::abs_path($filename) );
    if ( !-e $filename ) {
        print "$filename: file doesn't exist\n";
        die("$filename: file doesn't exist");
    }
    unless ( $abs_path =~ m/orig\// ) {
        print "$abs_path: filename must exist inside a corpus directory\n";
        die("$abs_path: filename must exist inside a corpus directory");
    }

    my $self = {};
    $self->{_orig_file}     = $abs_path;
    $self->{_test}          = $test;
    $self->{_bindir}        = "$ENV{'GTHOME'}/gt/script";
    $self->{_corpus_script} = $self->{_bindir} . "/corpus";
    $self->{_tmpfile_base} =
      join( '', map { ( 'a' .. 'z' )[ rand 26 ] } 0 .. 7 );

    my @values = split( "/orig/", $abs_path );
    $self->{_tmpdir} = $values[0] . "/tmp";
    if ( !-e $self->{_tmpdir} ) {
        File::Path::mkpath( $self->{_tmpdir} );
    }
    @values = split( "/", $values[1] );
    $self->{_doclang} = $values[0];

    bless $self, $class;

    $self->{_intermediate_xml2} =
      $self->getTmpDir() . "/" . $self->getTmpFilebase() . ".tmp2";
    $self->{_intermediate_xml} =
      $self->getTmpDir() . "/" . $self->getTmpFilebase() . ".tmp1";

    return $self;
}

sub getTest {
    my ($self) = @_;
    return ( $self->{_test} );
}

sub getOrig {
    my ($self) = @_;
    return $self->{_orig_file};
}

sub getTmpFilebase {
    my ($self) = @_;
    return $self->{_tmpfile_base};
}

sub getTmpDir {
    my ($self) = @_;
    return $self->{_tmpdir};
}

sub gettmp1 {
    my ($self) = @_;
    return $self->{_intermediate_xml};
}

sub gettmp2 {
    my ($self) = @_;
    return $self->{_intermediate_xml2};
}

sub getDoclang {
    my ($self) = @_;
    return $self->{_doclang};
}

sub exec_com {
    my ( $self, $com ) = @_;

    my $result = system($com);
    if ( $self->{_test} ) {
        print STDERR $self->getOrig() . " exec_com: $com\n";
        if ( $result != 0 ) {
            print STDERR "Errnr: $result. Errmsg: $!\n";
        }
    }

    return $result;
}

1;
