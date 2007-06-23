#!/usr/bin/env perl

# demo of P5NCI from 'Perl Hacks'

use P5NCI::Library;

my $lib = P5NCI::Library->new( library => q(z) );
# returns string, expects void
$lib->install_function( q(zlibVersion), q(tv) );

print qq(zlib version is: ) . zlibVersion() . qq(\n);
