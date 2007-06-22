#!/usr/bin/perl

my @order = qw(MESSAGE_ID ADDRESS_CLASS ADDRESS _VERSION
    MINOR_VERSION FRAGMENT_ID TOTAL_FRAGMENTS MSG_COMPRESSION_TYPE DATA );

foreach my $item ( @order ) {
    my @words = split(/_/, $item);
    my $acronym;
    foreach my $word ( @words ) {
        $acronym .= substr($word, 0, 1); 
    } # foreach my $word
    warn(q(Shrunk ) . join(q(_), @words) . qq( down to ') 
        . lc($acronym) . qq('\n));
} # foreach my $item ( @order )

