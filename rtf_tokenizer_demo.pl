#!/usr/bin/env perl

# demo of RTF::Tokenizer

# Takes an RTF file on STDIN, dumps the tokens found in the file

use strict;
use warnings;
use 5.010;

use Data::Dumper;
use RTF::Tokenizer;

my $tokenizer = RTF::Tokenizer->new( file => \*STDIN );

my @tokens = $tokenizer->get_all_tokens();
foreach my $array ( @tokens ) {
   printf(qq(type: %s; arg: %s; param: %s\n),
      $array->[0], $array->[1], $array->[2]);
}

