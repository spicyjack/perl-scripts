#!/usr/bin/env perl

# script to demo Math::Base36
use strict;
use warnings;
use 5.010;

# system modules
use Math::Base36 qw(:all);

say q(=-=-=-= Math::Base36 Demo =-=-=-=);
for my $x (1 .. 1_000) {
   say q(- ) . lc(encode_base36($x));
}
