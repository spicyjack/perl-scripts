#!/usr/bin/perl -w

# created 08/05/02 for rotating images, keeping their ctimes intact
#
# (C) 2002 by Brian Manning <brian@sunset-cliffs.org>
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

# use directives
use Getopt::Std;

# begin
my (%opts, %captions, $filedate);
&getopts("dh129f:", \%opts);
$JPEGTRAN="/usr/bin/jpegtran";

    # check for command line options
	if ( exists $opts{h} ) { &ShowHelp; exit 0;}

	# are we debugging?
    if ( exists $opts{d} ) { $DEBUG = 1; }

    # check for existence of jpegtrans
    if ( ! -x $JPEGTRAN ) {
        warn "Please install jpegtran, and re-run this script.\n";
    } # if ( ! -x $JPEGTRAN )

	if ( exists $opts{f} && 
			( exists $opts{1} || exists $opts{2} || exists $opts{9} ) ) {
		# pull the file date for putting back on later
		$filedate = &FileDate($opts{f}, "mtime");
		# move the old file to a new file with a temp name
		warn "rotate.pl: creating tempfile \"tmp$opts{f}\"" if $DEBUG;
		rename($opts{f}, "tmp$opts{f}");
		# how far are we rotating?
		if ( exists $opts{1} ) {
			# rotate 180
			warn "rotate.pl: Rotating $opts{f} 180 degrees" if $DEBUG;
			system("$JPEGTRAN -rot 180 -trim tmp$opts{f} > $opts{f}");
		} elsif ( exists $opts{2} ) {
			#rotate 270
			warn "rotate.pl: Rotating $opts{f} 270 degrees" if $DEBUG;
			system("$JPEGTRAN -rot 270 -trim tmp$opts{f} > $opts{f}");
		} elsif ( exists $opts{9} ) {
			#rotate 90 
			warn "rotate.pl: Rotating $opts{f} 90 degrees" if $DEBUG;
			system("$JPEGTRAN -rot 90 -trim tmp$opts{f} > $opts{f}");
		} # if (  exists $opts{1} )
		# remove the temp file
		warn "rotate.pl: deleting \"tmp$opts{f}\"" if $DEBUG;
		unlink("tmp$opts{f}");
		# re-date the newly rotated file
		warn "rotate.pl: resetting timestamp on $opts{f}" if $DEBUG;
		utime($filedate, $filedate, $opts{f});
	} else {
		&ShowHelp;
		exit 0;
	} # if ( exists $opts{f} && 

### end of main script ###
    
############
# FileDate #
############
sub FileDate {
# pulls file's mtime using stat()
    @filestat = stat($_[0]);
    if ( $_[1] eq "year") {
        $filedate = (localtime($filestat[9]))[5] + 1900;
    } elsif ( $_[1] eq "mtime" ) {
        $filedate = $filestat[9];
    } else { 
        $filedate = localtime($filestat[9]);
    } # if ( $_[1] eq "year")
    return $filedate;
} # sub filedate

############
# ShowHelp #
############
sub ShowHelp {
# shows the help message
	warn "Usage: rotate.pl [options]\n";
	warn "[options] may consist of\n";
	warn " -h show this help\n";
	warn " -d run in debug mode (extra noisy output)\n";
	warn " -2 rotate 270 degrees (90 degrees counterclockwise)\n";
	warn " -1 rotate 180 degrees (flip picture on it's vertical axis)\n"; 
	warn " -9 rotate 90 degrees (90 degrees clockwise)\n";
	warn " -f filename of the image to rotate\n";
} # sub ShowHelp
# end of line
    
