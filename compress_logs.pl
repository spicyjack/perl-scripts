#!/usr/bin/perl -w

# created 01/28/02 for compressing files with a certain name
# (C) 1999 by Brian Manning <brian@sunset-cliffs.org>
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307 USA 

# uses Getopt::Std for the command line switches
#use Getopt::Std;
use strict;

# variables
my (@filedir, $filename, %opts, $count);

# set up the %opts hash
#getopt("df:", \%opts);
#getopt("d", \%opts);
$opts{d} = $ENV{DEBUG};

# set $count to 0
$count = 0;

# get all the named.conf files in the directory
if ( defined $opts{f} ) {
	warn "File spec passed in; searching for " . $opts{f} if defined $opts{d};
	@filedir= <$opts{f}>;
} else {
	warn "No filespec passed in; searching for named.conf.*" 
		if defined $opts{d};
	@filedir= <named.conf.*>;
} # if ( defined $opts{f} )

# walk thru them one by one, compress them if they are not already compressed
foreach $filename (@filedir) {
	# check for a .gz extension, if it's not there, compress the file
	warn "checking $filename" if defined $opts{d};
	if ( $filename !~ /\.gz$/ ) {
		if ( defined $opts{d} ) {
			warn "fake-gzipping $filename";
		} else {
			system("/opt/bin/gzip -9 $filename");
		} # if ( defined $opts{d} )
		# add another to the count
		$count++;
	} # if ( $filename !~ /\.gz$/ )
} # foreach $oldname


