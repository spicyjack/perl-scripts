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

# TODO
# - write a switch that you can turn on that will rotate all files with the
# base dcp_#### name, instead of individual files

# use directives
use Getopt::Std;

# begin
my (%opts, $filedate, $rotate_direction); 
my ($basename, $systemstr); # base image file name, system call string
&getopts("dhq129f:", \%opts);
$JPEGTRAN="/usr/bin/jpegtran";

    # check for command line options
	if ( exists $opts{h} ) { &ShowHelp; exit 0;}

	# are we debugging?
    if ( exists $opts{d} ) { $DEBUG = 1; }

	# are we debugging?
    if ( exists $opts{q} ) { $QUIET = 1; }

	if ( ! -r $opts{f} ) { 
		die "ripit.pl: error - $! - exiting\n";
	} # if ( ! -r $opts{f} )
	
    # check for existence of jpegtrans
    if ( ! -x $JPEGTRAN ) {
        warn "Please install jpegtran, and re-run this script.\n";
    } # if ( ! -x $JPEGTRAN )

	if ( exists $opts{f} &&
			( exists $opts{1} || exists $opts{2} || exists $opts{9} ) ) {
		# pull the file date for putting back on later
		$filedate = &FileDate($opts{f}, "mtime");
		# move the old file to a new file with a temp name
		warn "rotate.pl: creating tempfile \"tmp$opts{f}\"\n" if ! $QUIET;
		rename($opts{f}, "tmp$opts{f}");
		# check for half size/thumbnail images as well
		# get the base of the filename
		# set up basename variable first
		$basename = $opts{f};
		$basename =~ s/\.jpg$//i;
		# now if it exists, move it
		if ( -r "$basename.half.jpg" ) {
			rename("$basename.half.jpg", "tmp$basename.half.jpg");
			warn "         : halfsize file found, renaming\n" if ! $QUIET;
		} # if ( exists "$basename.half.jpg" )
		if ( -r "$basename.8th.jpg" ) {
			rename("$basename.8th.jpg", "tmp$basename.8th.jpg");
			warn "         : eighthsize file found, renaming\n" if ! $QUIET;
		} # if ( exists "$basename.8th.jpg" )
		
		# how far are we rotating?
		if ( exists $opts{1} ) {
			# rotate 180
			warn "rotate.pl: Rotating $opts{f} 180 degrees\n" if ! $QUIET;
			$rotate_direction = "180";
		} elsif ( exists $opts{2} ) {
			#rotate 270
			warn "rotate.pl: Rotating $opts{f} 270 degrees\n" if ! $QUIET;
			$rotate_direction = "270";
		} elsif ( exists $opts{9} ) {
			#rotate 90 
			warn "rotate.pl: Rotating $opts{f} 90 degrees\n" if ! $QUIET;
			$rotate_direction = "90";
		} # if (  exists $opts{1} )

		# rotate the original file; build the system string
		$systemstr = "$JPEGTRAN -rot $rotate_direction -trim";
		$systemstr .= " tmp$opts{f} > $opts{f}";
		# now do it
		if ($DEBUG) {
			warn "rotate.pl: would have called jpegtrans with:\n";
			warn $systemstr . "\n";
		} else {
			system($systemstr) == 0 or die "rotate failed: $?";
		} # if ($DEBUG)

		# got a half size file?
		if ( -r "tmp$basename.half.jpg" ) {
			# yep, rotate it
			warn "rotate.pl: half file found, rotating\n" if ! $QUIET;
			$systemstr = "$JPEGTRAN -rot $rotate_direction";
			$systemstr .= " -trim tmp$basename.half.jpg";
			$systemstr .= " > $basename.half.jpg";
			system($systemstr) == 0 or die "rotate failed: $?";
		} # if (exists "$basename.half.jpg" )			

		# got a 8th size file?
		if ( -r "tmp$basename.8th.jpg" ) {
			# yep, rotate it
			warn "rotate.pl: eigth file found, rotating\n" if ! $QUIET;
			$systemstr = "$JPEGTRAN -rot $rotate_direction";
			$systemstr .= " -trim tmp$basename.8th.jpg";
			$systemstr .= " > $basename.8th.jpg";
			system($systemstr) == 0 or die "rotate failed: $?";
		} # if (exists "$basename.8th.jpg" )			
		
		# remove the temp file
		warn "rotate.pl: deleting \"tmp$opts{f}\"\n" if ! $QUIET;
		if (! $DEBUG) { unlink("tmp$opts{f}");}

		# check for and delete the smaller files as well
		if ( -r "tmp$basename.half.jpg") { 
			if (! $DEBUG) { unlink("tmp$basename.half.jpg"); }
		} # if (exists "tmp$basename.half.jpg")
		if ( -r "tmp$basename.8th.jpg") { 
			if (! $DEBUG) { unlink("tmp$basename.8th.jpg"); }
		} # if (exists "tmp$basename.8th.jpg")
		
		# re-date the newly rotated file
		warn "rotate.pl: resetting timestamp on $opts{f}\n" if ! $QUIET;
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
    
