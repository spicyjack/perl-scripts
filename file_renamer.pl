#!/usr/bin/perl -w

# program that strips words from a filename
# it also now removes bad things from the filename

# usage: filename_strip.pl /path/to/mp3s word_to_strip
#
# (c)2000 Brian Manning

# external modules
use Getopt::Std;
use strict;

# variables
my $DEBUG; # are we debugging?
my %opts; # command line options hash
my @filelist; # list of files, built with glob or a real list of files
my ($file, $newname); # a file from @filelist, new file name
my @splitname; # full path split up

	### begin script ###
	
	# get the command line switches
	&getopts("dhCve:l:p:w:", \%opts);

	if ( exists $opts{h} ) {
		warn "Usage: file_renamer.pl [options]\n";
		warn "[options] consist of:\n";
		warn " -h show this help list\n";
		warn " -d Debug mode - Doesn't do anything destructive.  " . 
			"Automagically sets -v\n";
		warn " -v Verbose mode - extra noisy\n";
		warn " -w word to replace in the filename " . 
			" (cannot be combined with -f)\n";
		warn " -C be case sensitve in matching words to replace\n";
		warn " -l filename to a list of files to parse/rename\n";
		warn " -e filename extension to match when not using a filelist\n";
		warn " -p path to files when not using a filelist\n";
		# exit out
		exit 0;
	} # if ( exists $opts{h} )
	
	# was a filename extension passed in?
	if ( exists $opts{e} && exists $opts{p} ) {	
		@filelist = <$opts{p}/*.$opts{e}>;
	} elsif ( exists $opts{l} ) {
		open (LIST, $opts{l});
		@filelist = <LIST>;
		close (LIST);
	} else {
		die "Please pass either a -l (list of files) or a -p (path) and " .
			"-e (extension)\nto filter a specific set of files";
	} # if ( exists $opts{e} && exists $opts{p} )

	foreach $file (@filelist) {
		chomp($file);
 		if ( $opts{d} || $opts{v} ) { warn "Stripping $file\n";}
		# split the full filename, this is so we don't do strange shit to the
		# path
		@splitname = split("/", $file);
		chomp(@splitname);
		# copy the old name over to $newname
		$newname = $splitname[-1];
		if ( $opts{d} || $opts{v} ) { warn "original filename is $newname\n";}
		if ( exists $opts{e} ) {
			if ( $opts{C} ) {
				$newname =~ s/$opts{w}//;
			} else {
				$newname =~ s/$opts{w}//;
			} # if ( $opts{C} )
		} # if ( exists $opts{e} )
		$newname =~ s/\&/-n-/g;
		$newname =~ s/ /_/g;
		$splitname[-1] = $newname;

		if ( $opts{d} ) { 
			warn "would have renamed $file\n to new name " . 
				join("/",@splitname) . "\n\n";
		} else {	
			if ( $opts{v} ) { 
				warn "renaming $file\nto " . join("/",@splitname);
			} # if ( $opts{v} )
			rename ( $file, join("/",@splitname) ) || 
				die "Couldn't rename $file : $!";
		} # if ( $opts{d} )
	} # foreach
