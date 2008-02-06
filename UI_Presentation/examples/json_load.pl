#!/usr/bin/env perl

# demo script to load a JSON data structure
use strict;
use warnings;
use JSON;
use Data::Dumper;

my $parser = JSON->new->ascii->pretty->allow_nonref;

my $json_string;
my $OS = $^O;

while ( <STDIN> ) {
    # add the line to the JSON string
    $json_string .= $_;
} # while ( <STDIN> )

my $object = $parser->decode($json_string);
my %object_hash = %$object;
my $slice = $object_hash{$OS};
my $dumper = Data::Dumper->new([$slice]);
print qq(Printing out all available scripts for '$OS' platform:\n);
print $dumper->Dump . qq(\n);

