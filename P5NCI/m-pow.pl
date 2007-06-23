#!/usr/bin/env perl

# demo of P5NCI from 'Perl Hacks'

use P5NCI::Library;

my $lib = P5NCI::Library->new( library => q(m) );
# returns a double, expects two doubles
$lib->install_function( q(pow), q(ddd) );

print pow( 3, 3 ), qq(\n);
print pow( 5, 5 ), qq(\n);
