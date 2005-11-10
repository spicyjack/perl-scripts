#!/usr/bin/perl -w

# script to add the track number to MP3 ID3 tags from the filename if there's a
# track number in the filename 
use strict;
use Getopt::Std; # parsing command line switches
use File::Find::Rule;

my %opts; # hash for command line options
&getopts("dhp:", \%opts); # go get the command line options

	# make sure we were passed a path to search for MP3's
	if ( ! $opts{p} || $opts{h} ) { 
		warn  "mp3_track_tag.pl (c) 2005 Brian Manning\n";
		warn "Usage:\n";
		warn "mp3_track_tag.pl [-p path]\n";
        warn "-d  Debug: don't actually change files\n";
		warn "-h  prints this help message\n";
		warn "-p  Path to search for MP3s to check tags\n";
        exit 1;
	} # if ( ! $opts{p} || $opts{h} )	
	
    my $total_files = 1; # set a line counter 
    my $start_time = time; # set the overall start time 

	# read in each line of the 'find', then run it against the database
	foreach my $file ( File::Find::Rule->file()
                        ->name('*.mp3')
                        ->in($opts{p}) ) {

        # for each $file, check for leading digits, then add track info if the
        # digits are found
        my @mp3file = split("/", $file);
        if ( $mp3file[-1] =~ /^\d\d/ ) {
            print qq(\n------------------------------------------------\n\n);
            print qq(Matched track ) . $mp3file[-1] . qq(; tag info is:\n);
            # get the tag info first
            my $command = qq(id3v2 -l "$file");
            my $output = `$command`;
            print $output . qq(\n);
            # then get the track number from the file
            my $track = $mp3file[-1];
            $track =~ s/^(\d+).*\.mp3/$1/; 
            # now build the re-track-numbering command
            # convert tags from ID3V1 to ID3V2 with '--convert'
            $command = qq(id3v2 --track $track "$file");
            if ( $opts{d} ) {
                print "Debug: command is: $command\n";
            } else {
                $output = `$command`;
                if ( $? != 0 ) {
                    print qq(Warning: id3v2 command returned an error:\n$!\n);
                } # if ( $? == 0 )
            } # if ( $opts{d} )

            # increment the total files counter
            $total_files++;
        } # if ( $mp3file[-1] =~ /^\d\d/ ) 
	} # foreach my $file ( File::Find::Rule->file())

    print qq(\n------------------------------------------------\n\n);

	my $total_time= time - $start_time;
	my $total_min = $total_time / 60;
	print "Retagged $total_files MP3's \n";
	print "in $total_time seconds, or $total_min minutes.\n";

exit 0;
