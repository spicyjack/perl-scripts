#!/usr/bin/perl

    package Moose::Demo;
    use Moose; # automagically sets 'strict' and 'warnings'

    has 'script_name' => ( is => 'rw', required => 1);

    package main;
    
    # '$0' is the name of this script, set automatically by Perl
    my $demo = Moose::Demo->new( script_name => $0 );

    print "My name is " . $demo->script_name . "\n";
    print "I am a " . $demo->meta->name . " type of object\n";
    print qq(I am also a ref ) . ref($demo) . qq( type of object\n);

    # setting the object attribute directly
    $demo->{script_name} = "something else";
    print qq(My name is now ) . $demo->script_name . qq(\n);
    # setting the object attribute via moose's accessor
    $demo->script_name("something entirely different");
    print qq(My name is now ) . $demo->script_name . qq(\n);

    # the below is here to show that moose is not just a blessed hash
    # reference; the attributes can be, but the object itself is not
    #foreach my $key (keys($demo)) {
    #    print qq(This key '$key' has a value of ) . $demo{$key} . qq(\n);
    #} # foreach my $key (keys($demo))
