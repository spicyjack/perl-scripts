#!/usr/bin/perl

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

# FIXME
# - go through the moose archives and see if anyone has tried something
# similar to what you are trying to do re: object creation and having
# something that checks for external files

=pod

=head1 NAME

B<archive_diff.pl> compares the contents of two archives, checking for files
that are in one archive and not the other and vice versa.

=head1 VERSION

The CVS version of this file is $Revision$. See the top of this file for
the author's version number.

=head1 SYNOPSIS

 perl archive_diff.pl -1 first_filelist.txt -2 second_filelist.txt 

=head2 Package Archive

The Archive object grabs information from an archive of some kind and allows
this information to be queried.  The L<Archive> object has the following
attributes:

=over 5

=item attrib

The archive attributes.  Contained in an object of L<Archive::Attributes>
type.

=item filename 

The name of the archive file.  The file is checked to see if it exists and is
readable when an object is created from this class.

=item contents

A hash of L<Archive::File> objects keyed by filename.

=back

=cut

#### Package 'Archive' ####
package Archive;
use Moose; # comes with 'strict' and 'warnings'
use Moose::Util::TypeConstraints;

# a subtype for holding the name of a file in the archive
# this should make it so that the file is checked when the object is created
# Str is from Moose::Util::TypeConstraints
subtype ArchiveFilename
    => as Str
    => where { ( -r $_ ) };

has q(attrib) => ( is => q(rw), isa => q(Archive::Attributes));
has q(filename) => ( is => q(rw), isa => q(ArchiveFilename), required => 1 );
has q(contents) => ( is => q(rw), isa => q(HashRef[Archive::File]) );

=pod

=head3 get_filename()

Returns the filename of the archive

=cut 

sub get_filename { return shift->filename; }

#### end Package 'Archive' ####

=pod

=head2 Package Archive::Diff

This file takes two L<Archive> objects as arguments, and when queried using
the object methods, will return a formatted list that shows the differences in
the contents of the two archives.


=cut

#### Package 'Archive::Diff' ####
package Archive::Diff;
use Moose; # comes with 'strict' and 'warnings'
use Moose::Util::TypeConstraints;

has q(first) => ( is => q(rw), isa => q(Archive), required => 1 );
has q(second) => ( is => q(rw), isa => q(Archive), required => 1 );

=pod

=head3 simple_diff()

Shows a simple comparison, whether or not a file is in one archive or the
other.

=head3 full_diff()

Shows not only if files are in one archive but not another, but if the same
file in both archives differs in timestamp or uncompressed size.

=cut

sub simple_diff {
	my $self = shift;
	my $first = $self->first;
	my $second = $self->second;

	print qq(The first filename is ) . $first->filename . qq(\n);
	print qq(The second filename is ) . $second->filename . qq(\n);
} # sub simple_diff

#### end Package 'Archive::Diff' ####

=pod 

=head2 Package Archive::Attributes

Contains metadata attributes for an archive file.  

=over 5

=item version

The version of the program that created this archive.  May or may not come from
the archive itself;  a asterisk B<*> denotes the version number of the program
on the system, as the archive itѕelf does not hold any version information.

=back

=cut

#### Package 'Archive::Attributes' ####
package Archive::Attributes;
use Moose;
use Moose::Util::TypeConstraints;

has q(version) => ( is => q(rw), isa => q(Str) );

#### end Package 'Archive::Attributes' ####

=pod 

=head2 Package Archive::File

An object that holds information about a file in an archive.  You would most
likely create as many L<Archive::File> objects as you had individual files and
directories in an archive.  L<Archive::File> has the following attributes:

=over 5 

=item name

The name of the file that is a member of this L<Archive>.

=item timestamp

The timestamp of the file as stored in the archive.

=item  orig_size

The uncompressed size of the file stored in the archive.

=item attributes

The attributes stored with the file in the archive.

=back

=cut

package Archive::File;
use Moose;
use Moose::Util::TypeConstraints;

has q(name) => ( is => q(rw), isa => q(Str) );
has q(timestamp) => ( is => q(rw), isa => q(Str) );
has q(usize) => ( is => q(rw), isa => q(Str) );
has q(attributes) => ( is => q(rw), isa => q(Str) );

#### end Package 'Archive::File' ####

#### Package 'main' ####
package main;

use strict;
use warnings;
use Getopt::Long;
use Log::Log4perl qw(get_logger :levels);
use Time::Local;
use Pod::Usage;

my ($DEBUG, $first_file, $second_file, $first_obj, $second_obj, $colorlog);
# colorize Log4perl output by default 
$colorlog = 1;

my $goparse = Getopt::Long::Parser->new();
$goparse->getoptions(   q(DEBUG|D)                      => \$DEBUG,
                        q(help|h)                       => \&ShowHelp,
                        q(first-file|first|1st|1=s)     => \$first_file,
                        q(second-file|second|2nd|2=s)   => \$second_file,
                        q(colorlog!)                    => \$colorlog,
                    ); # $goparse->getoptions

# always turn off color logs under Windows, the terms don't do ANSI
if ( $^O =~ /MSWin32/ ) { $colorlog = 0; } 

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
# if they're both readable, read them and bless them into objects
if ( defined $first_file ) {
    # read in the file and bless it into an Archive object
    $first_obj = Archive->new( filename => $first_file );
    if ( $@ ) {}

} else {
    $logger->fatal(q(First file not specified with --first-file switch));
    &HelpDie;
} # if ( defined $first_file )

if ( defined $second_file ) {
    # read in the file and bless it into an Archive object
    $second_obj = Archive->new( filename => $second_file );
} else {
    $logger->fatal(q(Second file not specified with --second-file switch));
    &HelpDie;
} # if ( defined $first_file ) 

# print some debugging
print qq(The first object's filename is ) . $first_obj->get_filename();
print qq(The second object's filename is ) . $second_obj->get_filename();
my $diff = Archive::Diff->new( first => $first_obj, second => $second_obj );

$diff->simple_diff();

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

=head1 AUTHOR

Brian Manning E<lt>elspicyjack at gmail dot comE<gt>

=cut

# vi: set sw=4 ts=4 cin:
# end of line
