#!/usr/bin/perl

package FilenameDemo;
use strict;
use warnings;

my $filename;

sub new {
  my $class = shift;
  my %args = @_;
  my $self = bless ( {}, ref($class) || $class);

  if ( exists $args{filename} ) {
    $filename = $args{filename};
  } # if ( exists $args{filename} )
  return $self;
} # sub new
  
sub filename {
    my $self = shift;
    return $filename;
} # sub filename

package main;

my $demo = FilenameDemo->new( filename => $0 );

print qq(My name is ) . $demo->filename . qq(\n);
print qq(I am a ) . ref($demo) . qq( type of object\n);
