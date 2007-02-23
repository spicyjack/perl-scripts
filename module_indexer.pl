#!/usr/bin/perl

# $Id$
# Copyright (c)2007 by Brian Manning <elspicyjack at gmail dot com>

# script to build an index of all of the Perl modules on a system
use strict;
use warnings;

# external modules
use Module::Dependency::Indexer;
Module::Dependency::Indexer::setIndex( '/tmp/perl_dependency.dat' );
Module::Dependency::Indexer::makeIndex( qw(/usr/lib/perl /usr/lib/perl5
    /usr/share/perl /usr/share/perl5) );
Module::Dependency::Indexer::setShebangCheck( 0 );


