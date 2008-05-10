#!/usr/bin/env perl

    package ZeroDemo;
    use Moose; 

    sub BUILD {
        my $self;
        # see if '/dev/zero' exists; 
        # create the object only if the file does exist
        if ( -e '/dev/one' ) {
            return $self;
        } else {
            die('ERROR: /dev/zero does not exist');
        } 
    } # sub BUILD 

    package main;
    use Moose; # needed for the call to 'blessed' below
    
    # '$0' is the name of this script, set automatically by Perl
    my $demo = ZeroDemo->new( example_file => $0 );

    print qq(Created a ) . $demo->meta->name . qq( type of object\n);
