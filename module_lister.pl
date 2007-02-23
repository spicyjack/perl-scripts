#!/usr/bin/perl

# $Id$
# (c)Copyright 2007 by Brian Manning (elspicyjack at gmail dot com)

# script to list out Perl module/script file dependencies

# FIXME add support for Shell::UI so that you can type modules in at a shell
# prompt; grab it from depsh.pl

use strict;
use warnings;
use Module::Dependency::Info;
Module::Dependency::Info::setIndex( '/tmp/perl_dependency.dat' );
        
# load the index (actually it's loaded automatically if needed so this is
# optional)
Module::Dependency::Info::retrieveIndex();
        
#$listref = Module::Dependency::Info::allItems();
#$listref = Module::Dependency::Info::allScripts();
        
# note the syntax here - the path of perl scripts, but the package name of
# modules.
foreach (qw( CGI HTTP::Daemon IO::Socket Socket) ) {
    print(qq(Listing dependencies for: $_\n));
    my $dependencyInfo = Module::Dependency::Info::getItem( $_ );
    if ( defined $dependencyInfo ) {
        print(qq($_ : Dependency Info\n));
        foreach my $dep ( keys %$dependencyInfo ) {
            print(qq($_ :\t$dep -> ) . $$dependencyInfo{$dep} . qq(\n));
        }
    } # if ( defined $dependencyInfo )
    my $filename = Module::Dependency::Info::getFilename( $_ );
    print(qq($_ : Filename: $filename\n)) if defined $filename;
    my $children = Module::Dependency::Info::getChildren( $_ );
    if ( defined $children ) {
        print(qq($_ : Inherits from:\n));
        foreach my $dep ( @$children ) {
            print(qq($_ :\t$dep\n));
        }
    } # if ( defined $children )
    my $parents = Module::Dependency::Info::getParents( $_ );
    if ( defined $parents ) {
        print(qq($_ : Modules that inherit from this module:\n));
        foreach my $dep ( @$parents ) {
            print(qq($_ :\t$dep\n));
        }
    } # if ( defined $parents )

    #$value = Module::Dependency::Info::relationship( 'Foo::Bar', 'strict' );
        
} # foreach (qw( CGI /home/brian/cvs/antlinux/scripts/ssl_demo/farkhttpd.pl ))

Module::Dependency::Info::dropIndex();

