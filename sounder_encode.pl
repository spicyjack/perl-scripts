#!/usr/bin/perl -w

# audix_strip_front.pl
#
# wrapper program that will go through a directory of text files, 
# and send the ones named audix*.txt to the audix_strip.pl script


@files= <*.wav>;
$counter = 1;

foreach $wavfile (@files) {
	$mp3file = $wavfile;
	$mp3file =~ s/$\.wav/.mp3/;
	print "Re-encoding $mp3file as #$counter\n";
	system("/usr/bin/nice -n 19 /usr/local/bin/lame -h -b 128 \"$wavfile\" \"$mp3file\""); 
	$counter++;	
}

