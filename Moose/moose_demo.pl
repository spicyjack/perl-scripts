#!/usr/bin/perl

    package Moose::Demo;
    use Moose; # automagically sets 'strict' and 'warnings'

    has 'script_name' => ( is => 'rw', required => 1);

    package main;
    use Moose; # needed for the call to 'blessed' below

    # '$0' is the name of this script, set automatically by Perl
    my $demo = Moose::Demo->new( script_name => $0 );

    print qq(My name is ) . $demo->script_name . qq(\n);
    print qq(I am a ) . blessed $demo . qq( type of object\n);

    # comment this out or the script will not run
    $demo->{script_name} = "something else";
    print qq(My name is now ) . $demo->script_name . qq(\n);
    #foreach my $key (keys($demo)) {
    #    print qq(This key '$key' has a value of ) . $demo{$key} . qq(\n);
    #} # foreach my $key (keys($demo))
