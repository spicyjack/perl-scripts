#!/usr/bin/perl -w

# script to reencode MP3's at a different bitrate

# TODO
# fix the variables to all be delcared before use
# add a use strict directive
# change all the prints to warns

use Getopt::Std; # parsing command line switches

my %opts; # hash for command line options
&getopts("f:l:w", \%opts); # go get the command line options

	# set the output directory, no trailng slash please!
	$outdir = "/home/brian/out";

	# make sure we were passed a path to search for MP3's
	if ( ! ($opts{f} || $opts{l}) ) { 
		print "mp3_reencode.pl (c) 2001 Brian Manning\n";
		print "Usage:\n";
		print "mp3_reencode.pl [-f|-l] <parameter> \n";
		print "-f: system(find) *.mp3 on <parameter> and reencode\n";
		print "-l: read the file <parameter> and reencode each file found\n";
		print "-w: output to a .wav file (for burning audio CD's)\n";
		exit 1;
	}	
	
	# here's where we get the list of files to reencode
	if ( exists $opts{f} ) {
		# call system(find $path) to get a list of MP3's		
		print "Executing system(find)...\n";
		@filelist = `find $ARGV[1] -name \"*.mp3\" -print`;
	} else {
		# or open the passed in list of files
		open (MP3LIST, "$opts{l}");
		@filelist = <MP3LIST>;
		close (MP3LIST);
	} # if $ARGV[0]

	# open the database connection

	$total_files = 1; # set a line counter 
	$start_time = time; # set the overall start time 
	
	# read in each line of the 'find', then run it against the database
	foreach $file (@filelist) {
		chomp($file);
		@parts = split('/', $file);
		$maxparts = @parts;
		$artist = $parts[$maxparts - 3];
		$album = $parts[$maxparts - 2];
		$song = $parts[$maxparts - 1];
		print "\n============================\n";
		print "reencoding song #$total_files\n";
		# make the artist directory if it does not exist already
		if ( ! -d "$outdir/$artist" ) { # artist directory not there
			mkdir("$outdir/$artist",0777) || 
			die "cannot mkdir $outdir/$artist: $!\n";
		} # if ! -d $artist
		# make the album directory if needed
		if ( ! -d "$outdir/$artist/$album" ) { # album directory not there
			mkdir("$outdir/$artist/$album",0777) || 
			die "cannot mkdir $outdir/$artist/$album: $!\n";
		} # if ! -d $artist/$album
		# now reencode the file
		$song_time = time;
		if ( ! $opts{w} ) {
			# re-encode at a lower bitrate
			$command = "/usr/local/bin/lame -h -S -b 128 ";

		} else {
			# output to a wav file
			$song =~ s/mp3$/wav/i;
			$command = "/usr/local/bin/lame --decode ";
		} # if ( ! $opts{w} )

		# the extra part of the command string that gives the file to re-encode
		$command .= "\"$file\" \"$outdir/$artist/$album/$song\"";
		$encode_time = time - $song_time;
		system($command);
		print "reencoded $artist/$album/$song in $encode_time secs\n";
		# update total input lines parsed
		$total_files++;
	} # foreach $file (@filelist)


	# tell'em how we did...
	$total_time=time - $start_time;
	$total_min = $total_time / 60;
	print "Reencoded $total_files MP3's ";
	print "in $total_time seconds, or $total_min minutes.\n";

exit 0;
