#!/usr/bin/perl

# moose demo
package HashDemo;
use Moose;
use Moose::Util::TypeConstraints;
has 'file' => ( is => 'rw', isa => q(HashRef) );

package main;
use Moose;

my $demo = HashDemo->new( file => { 1 => q(/path/to/some/file) } );
my %hash = %{$demo->file}; # make a copy of the hash
$hash{y} = q(/path/to/something/else);
print q(demo->file is ) . $demo->file . qq(\n);
print q(hash is ) . \%hash . qq(\n);
&dump_hash($demo, \%hash);
# prints "this hash key/value pair is 1 : /path/to/some/file"

# this overwrites the existing hash contents in $demo->file
$demo->file( { 2 => q(/path/to/file2), 3 => q(/path/to/file3) } );
%hash = %{$demo->file}; # make a copy of the hash
$hash{y} = q(/path/to/something/else);

print q(demo->file is ) . $demo->file . qq(\n);
print q(hash is ) . \%hash . qq(\n);
&dump_hash($demo, \%hash);
# prints:
# this hash key/value pair is 3 : /path/to/file3
# this hash key/value pair is 2 : /path/to/file2
exit 0;

sub dump_hash {
    my $demo = shift; # pop the object reference off of the call stack
    my $hash = shift; # reference to a copy of the moose hashref
	print q(demo->file is ) . $demo->file . qq(\n);
	print q(hash is ) . $hash . qq(\n);
    foreach my $key ( keys(%{$demo->file}) ) {
        print qq(demo hash key/value pair is $key : ) 
            . $demo->{file}{$key} . qq(\n);
    } # foreach my $key ( keys(%{$demo->file}) )
    foreach my $key ( keys(%hash) ) {
        print qq('hash' hash key/value pair is $key : ) 
            . $hash{$key} . qq(\n);
    } # foreach my $key ( keys(%{$demo->file}) )
} # sub dump_hash
