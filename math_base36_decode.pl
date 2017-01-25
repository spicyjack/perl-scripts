#!/usr/bin/env perl

# script to demo Math::Base36
use strict;
use warnings;
use 5.010;

# system modules
use Math::Base36 qw(:all);

print q(Enter in a Base36 "number" to decode: );
my $base36_num = <STDIN>;
$base36_num = uc($base36_num);
chomp($base36_num);
if ( $base36_num =~ /[a-zA-Z0-9]+/ ) {
   say qq(Base36 string '$base36_num' decodes to: )
      . decode_base36($base36_num);
} else {
   say qq(ERROR: input '$base36_num' is not a valid Base36 string);
}
