#!/usr/bin/perl -w


$counter =0;
@playlist= <./filelist.txt>;

if ($ARGV[0] eq "") {
	print "Please enter a destination directory.  Exiting...\n";
	exit 1;
}

foreach $mp3file (@playlist) {

	system ("cp $mp3file $ARGV[0]");

	$counter = $counter + 1;
	print "Copied $counter files\n";
}

