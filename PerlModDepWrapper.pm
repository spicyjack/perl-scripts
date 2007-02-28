#!/usr/bin/perl

# $Id$
# Copyright (c)2007 by Brian Manning <elspicyjack at gmail dot com>

=pod

=head1 NAME

moddeps.pl

=head1 VERSION

The current version of this script is 0.1 (23Feb2007)

=cut

$VERSION = 0.1;

package PerlModDepWrapper;
use strict;
use warnings;
use Log::Log4perl qw(get_logger :levels);

sub new {
	my $class = shift;
	if ( ref($class) ) {
		die qq(PerlDepShell is not meant to be subclassed... sorry.);
	} # if ( ref($class) )
	my $this = bless ({}, $class);
	return $this;
} # sub new

sub drop_index {
#Module::Dependency::Info::dropIndex();
    my $logger = get_logger();
    $logger->warn(q(drop_index));
} # sub drop_index

sub load_index_file {
	my $logger = get_logger();
    $logger->warn(q(load_index_file));
=pod

	if ( scalar(@_) == 1 ) {
		# see if the file argument exists/is readable
		if ( -r $_[0] ) {
			Module::Dependency::Indexer::setIndex($_[0]);
		} else {
			$logger->warn(q(File ) . $_[0] . q( not found/not readable));
		} # if ( -r $_[0] )
	} # if ( scalar(@_) == 1 )

=cut

} # sub load_index_file

sub save_index_file {
    my $logger = get_logger();
    $logger->warn(q(save_index_file));
} # sub save_index_file

sub create_index_file {
    my $logger = get_logger();
    $logger->warn(q(create_index_file));
} # sub save_index_file

# vi: set ft=perl sw=4 ts=4 cin:
