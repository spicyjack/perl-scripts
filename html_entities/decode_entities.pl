#!/usr/bin/perl

use strict;
use warnings;

use HTML::Entities;

my @lines = <STDIN>;
foreach my $line ( @lines ) {
    chomp $line;
    print qq(Decoded entities are:\n) . decode_entities($line) . qq(\n);
}
