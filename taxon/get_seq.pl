#!/usr/bin/perl
use strict;
use warnings;
use autodie;

use Path::Tiny;
use Bio::DB::EUtilities;

my $id  = shift || "NC_001284";
my $dir = shift || ".";

if ( !-d $dir ) {
    path($dir)->mkpath;
}

# Some .gb files only contain assembling infomation, so we need download both
# types.
# When network connection is aweful, downloads may be incomplete.
my @types = qw(gb fasta);

for my $type (@types) {
    my $factory = Bio::DB::EUtilities->new(
        -eutil   => 'efetch',
        -db      => 'nucleotide',
        -rettype => $type,
        -email   => 'mymail@foo.bar',
        -id      => [$id],
    );
    my $file = path( $dir, "$id.$type" )->absolute->stringify;
    print "Saving file to [$file]\n";

    # local shadowsocks proxy
    if ( $ENV{SSPROXY} ) {
        $factory->proxy( [ 'http', 'https' ], 'socks://127.0.0.1:1080' );
    }

    # dump HTTP::Response content to a file (not retained in memory)
    $factory->get_Response( -file => $file );
    print "Done.\n";
}

__END__

=head1 NAME

get_seq.pl - retrieve nucleotide sequences from NCBI via Bio::DB::EUtilities

=head1 SYNOPSIS

    perl get_seq.pl <Accession> [Output directory]
    
    # export SSPROXY
    perl get_seq.pl NC_001284 .

=cut