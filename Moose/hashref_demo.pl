#!/usr/bin/perl

# moose demo
package HashDemo;
use Moose;
use Moose::Util::TypeConstraints;
#has q(filename) => ( isa => q(Str), is => q(rw) );
#has q(filename) => ( is => q(rw) );
has 'file' => ( is => 'rw', isa => q(HashRef) );

package main;
use Moose;

my $demo = HashDemo->new( file => { 1 => q(/path/to/some/file) } );

# the below will work if it is uncommented and the rest of the file is
# commented
# print qq(My hash is ) . join(q(:), %{$demo->file}) . qq(\n);
# should output:
# [devilduck][bmanning Moose]$ perl hashref_demo.pl
# My hash is 1:/path/to/some/file

# this overwrites the existing hash contents in $demo->file
$demo->file( { 2 => q(/path/to/file2), 3 => q(/path/to/file3) } );

my %hash = %{$demo->file};
foreach my $key ( keys(%hash) ) {
    print qq(this hash key/value pair is $key : ) . $hash{$key} . qq(\n);
} # foreach my $key ( keys(%{$demo->file}) )

