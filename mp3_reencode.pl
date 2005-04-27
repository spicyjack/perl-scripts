#!/usr/bin/perl -w

# script to reencode MP3's at a different bitrate

# TODO
# fix the variables to all be delcared before use
# add a use strict directive
# change all the prints to warns
# add an output path option, but use the default $outdir if one is not passed
# in

# oneliner for reencoding FLAC files
# for FILE in *.flac; do newname=`ls ${FILE} | sed 's/flac$/mp3/'`;
# /sw/bin/flac -d -c $FILE | ~/Documents/bin/lame -h -S -b 256 - $newname; done

use Getopt::Std; # parsing command line switches

my %opts; # hash for command line options
&getopts("f:l:s:w", \%opts); # go get the command line options

	# set the output directory, no trailng slash please!
	$outdir = "/home/brian/out";

	# make sure we were passed a path to search for MP3's
	if ( ! ($opts{f} || $opts{l} || $opts{s}) ) { 
		print "mp3_reencode.pl (c) 2001 Brian Manning\n";
		print "Usage:\n";
		print "mp3_reencode.pl [-f path] [-l filename]\n";
		print "-s: re-encode a single file, use the full path to the file\n";
		print "-f: system(find) *.mp3 on a path and reencode\n";
		print "-l: reencode each file listed in filename\n";
		print "-w: output to a .wav file (for burning audio CD's)\n";
		print "Output will be sent to $outdir, with each album being\n";
		print "placed in it's own separate folder.\n"; 		exit 1;
	}	
	
	# here's where we get the list of files to reencode
	if ( exists $opts{f} ) {
		# call system(find $path) to get a list of MP3's		
		print "Executing system(find)...\n";
		@filelist = `find \"$opts{f}\" -name \"*.mp3\" -print`;
	} elsif ( exists $opts{s} ) {
		# single file, so just give filelist that file only
		$filelist[0] = $opts{s};
	} elsif ( exists $opts{l} ) {
		# or open the passed in list of files
		open (MP3LIST, "$opts{l}");
		@filelist = <MP3LIST>;
		close (MP3LIST);
	} else {
		# we didn't get any valid options. exit
		# we shouldn't ever reach this die statement
		die("Please use the -f, -s, or -l switches when running this script");
	}# if $ARGV[0]

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
