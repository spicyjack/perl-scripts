#!/usr/bin/perl -T

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

=pod

=head2 Package Archive

The Archive object grabs information from an archive of some kind and allows
this information to be queried.  The L<Archive> object contains an
L<Archive::Attributes> object and a hash of L<Archive::File> objects keyed by
filename.

=cut

package Archive;

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

