#!/usr/bin/perl -w

# audix_strip_front.pl
#
# wrapper program that will go through a directory of text files, 
# and send the ones named audix*.txt to the audix_strip.pl script

$counter =0;
@playlist= <./files.m3u>;

if ($ARGV[0] eq "") {
	print "Please enter a destination directory.  Exiting...\n";
	exit 1;
}

foreach $mp3file (@playlist) {

# call audix_strip.pl
	system ("cp $mp3file $ARGV[0]");

# give the user a chance to read the stats
	$counter = $counter + 1;
	print "Copied $counter files\n";
}

