#!/usr/bin/perl -w

# script to count the size of the mirror of id Software's Doom
# sums up the bytecount from the output of ls -laR on the mirror

# open the ls -laR file

# exit if we are not passed in a filename
if (! $ARGV[0]) { print "Usage: $0 ls_output\nExiting...\n"; exit 1;}

# open the file for reading
print "$0: opening $ARGV[0]\n";
$ls_output = open(LSOUT, $ARGV[0]);

# a counter would be nice
$counter = 0;
#$tmpcounter = 0;

# loop thru the file
while (<LSOUT>) {
	# any line without a d or '-' as the first character, discard
	#if ( /^-/ || /^d/ ) { # we've got a match
	if ( /^-/ ) { # we don't download directories, so don't count them
		# we've got a match
		# we want the 4th column from 0 (left edge)
		# /\s+/ == one or more spaces
		chomp($_);
		@line = split (/\s+/, $_);	
		#print join(":", @line);
		#print "\n";
		$counter += $line[4];
		#$tmpcounter +=1;
		#if ($tmpcounter == 10) {print "Tempcounter limit: $counter\n"; exit 1;}
	} # if ( /^-/ || /^d/ )
} # while (<LSOUT>)

print "Total bytes are: $counter\n";

exit 0;
