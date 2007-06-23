#!/usr/bin/env perl

# demo of P5NCI from 'Perl Hacks'

use P5NCI::Library;

my $lib = P5NCI::Library->new( library => q(m) );
$lib->install_function( q(cbrt), q(dd) );

print cbrt( 27 ), qq(\n);
print cbrt( 31 ), qq(\n);
