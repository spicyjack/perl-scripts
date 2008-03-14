#!/usr/bin/perl

use strict;
use warnings;
# $Id$
# Copyright (c)2008 by Brian Manning <elspicyjack at gmail dot com>
#
# compare the contents of two archive files side-by-side or in list format

#   This program is free software; you can redistribute it and/or modify
#   it under the terms of the GNU General Public License as published by
#   the Free Software Foundation; version 2 dated June, 1991.
#
#   This program is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU General Public License for more details.
#
#   You should have received a copy of the GNU General Public License
#   along with this program;  if not, write to the Free Software
#   Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111, USA.

=pod

=head1 NAME

archive_diff.pl

=head1 VERSION

The CVS version of this file is $Revision$. See the top of this file for
the author's version number.

=head1 SYNOPSIS

B<archive_diff.pl> compares the contents of two archives, checking for files
that are in one archive and not the other and vice versa.

=cut

package main;
use Getopt::Long;
use Log::Log4perl qw(get_logger :levels);
use Time::Local;
use Pod::Usage;

my ($DEBUG, $first_file, $second_file);
my $colorlog = 1;

my $goparse = Getopt::Long::Parser->new();
$goparse->getoptions(   q(DEBUG|D)                      => \$DEBUG,
                        q(help|h)                       => \&ShowHelp,
                        q(first-file|first|1st|1=s)     => \$first_file,
                        q(second-file|second|2nd|2=s)   => \$second_file,
                        q(colorlog!)                    => \$colorlog,
                    ); # $goparse->getoptions

# set up the logger
my $logger_conf = qq(log4perl.rootLogger = INFO, Screen\n);
if ( $colorlog ) {
    $logger_conf .= qq(log4perl.appender.Screen = )
        . qq(Log::Log4perl::Appender::ScreenColoredLevels\n);
} else {
    $logger_conf .= qq(log4perl.appender.Screen = )
        . qq(Log::Log4perl::Appender::Screen\n);
} # if ( $Config->get(q(colorlog)) )

$logger_conf .= qq(log4perl.appender.Screen.stderr = 1\n)
    . qq(log4perl.appender.Screen.layout = PatternLayout\n)
    . q(log4perl.appender.Screen.layout.ConversionPattern = %d %p %m%n)
    . qq(\n);
#log4perl.appender.Screen.layout.ConversionPattern = %d %p> %F{1}:%L %M - %m%n
# create the logger object
Log::Log4perl::init( \$logger_conf );
my $logger = get_logger("");
if ( defined $DEBUG ) {
    $logger->level($DEBUG);
} else {
    $logger->level($INFO);
} # if ( defined $DEBUG )

# check to make sure we can read the input files
if ( defined $first_file ) {
    if ( ! -r $first_file ) {
        $logger->fatal(q(Can't find/read ) . $first_file);
        &HelpDie;
    } # if ( ! -r $first_file )
} else {
    $logger->fatal(q(First file not specified with --first-file switch));
    &HelpDie;
} # if ( defined $first_file )

if ( defined $second_file ) {
    if ( ! -r $second_file ) {
        $logger->fatal(q(Can't find/read ) . $second_file);
        &HelpDie;
    } # if ( ! -r $second_file )
} else {
    $logger->fatal(q(Second file not specified with --second-file switch));
    &HelpDie;
} # if ( defined $first_file ) 

my $diff = Archive::Diff->new();

#$diff->compare(first => $first_file, second => $second_file);

exit 0;

sub HelpDie {
    my $logger = get_logger();
    $logger->fatal(qq(Use '$0 --help' to view script options));
    exit 1;

} # sub HelpDie 

# simple help subroutine
sub ShowHelp {
# shows the POD documentation (short or long version)
    my $whichhelp = shift;  # retrieve what help message to show
    shift; # discard the value

    # call pod2usage and have it exit non-zero
    # if if one of the 2 shorthelp options were not used, call longhelp
    if ( ($whichhelp eq q(help))  || ($whichhelp eq q(h)) ) {
        pod2usage(-exitstatus => 1);
    } else {
        pod2usage(-exitstatus => 1, -verbose => 2);
    } # if ( ($whichhelp eq q(help))  || ($whichhelp eq q(h)) )
} # sub ShowHelp

### end package main

=pod

=head2 Package Archive

The Archive object grabs information from an archive of some kind and allows
this information to be queried.  The L<Archive> object contains an
L<Archive::Attributes> object and a hash of L<Archive::File> objects keyed by
filename.

=cut

package Archive;
#use Moose; # comes with 'strict' and 'warnings'

#has q(attrib) => ( is => q(rw), isa => q(Archive::Attributes));
#has q(files) => ( is => q(rw), isa => q(ArrayRef[Archive::File]) );

sub new {
    print qq(This is Archive->new\n);
} # sub new
=pod

=head2 Package Archive::Diff

=cut

package Archive::Diff;

sub new {
    print qq(This is Archive::Diff->new\n);
    my $archive = Archive->new();
} # sub new

=pod 

=head2 Package Archive::Attributes

Contains attributes for an archive file.  Can be queried using the following
methods:

=head3 version

Version of the program that created this archive.  May or may not come from
the archive itself;  a asterisk B<*> denotes the version number of the program
on the system, as the archive itѕelf does not hold any version information.

=cut

package Archive::Attributes;

=pod 

=head2 Package Archive::File

An object that holds information about a file in an archive.  You would most
likely create as many L<Archive::File> objects as you had individual files and
directories in an archive.  L<Archive::File> can be queried using the
following methods:

=head3 name

=head3 timestamp

=head3 usize

=head3 attributes

=cut

package Archive::File;

=pod

=head1 AUTHOR

Brian Manning E<lt>elspicyjack at gmail dot comE<gt>

=cut

# vi: set sw=4 ts=4 cin:
# end of line
1;

