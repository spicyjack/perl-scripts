#!/usr/bin/perl -w

# program that strips words from a filename

# usage: filename_strip.pl /path/to/mp3s word_to_strip
#
# (c)2000 Brian Manning

# so @ARGV[0] should have the full path
# and @ARGV[1] is the word you want to strip out

# Constants

$CASE_SENSITIVE=0; 	# '0' for true, anything else for false


@mp3directory= <@ARGV[0]/*.mp3>;

foreach $newname (@mp3directory) {
 #   print "Stripping $newname ...\n";
	$oldname = $newname;
	if ( $CASE_SENSITIVE ) {
		$newname =~ s/@ARGV[1]//;
	} else {
		$newname =~ s/@ARGV[1]//i;
	}
#	print "New filename is $newname\n";
	print "Renaming $oldname\n to new name $newname\n\n";
	rename ( $oldname, $newname );
} # foreach
