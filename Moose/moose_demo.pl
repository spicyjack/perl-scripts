#!/usr/bin/perl

# moose demo
package FilenameDemo;
use Moose;

#has q(filename) => ( isa => q(Str), is => q(rw) );
#has q(filename) => ( is => q(rw) );
has 'filename' => ( is => 'rw' );

package main;
use Moose;

my $demo = FilenameDemo->new( filename => $0 );

print qq(My name is ) . $demo->filename . qq(\n);
print qq(I am a ) . blessed $demo . qq( type of object\n);
