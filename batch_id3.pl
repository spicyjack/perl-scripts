#!/usr/bin/perl -w

# $Id$
# Batch MP3 ID3 tagger
# (c)2003 Brian Manning
# 
# will change the text tags located in MP3 files in various ways
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

# TODO's
# 
# - pull the date for the comment field using the date command
# or perl equivalent; use the date trick for ripit.pl as well; see
# thumbnails.pl for one example of how to do it
# - pull Artist, Album, Track number and track name (Title) from
# the path and filename
# - year and genre fields will have to be prompted for
# use directives
use Getopt::Std; # parse command line parameters
use strict; # strictness is good
my $ID3 = "/usr/bin/id3"; # path to the id3 binary

### begin main script body ###

# some variables please
my %opts; # for &getopts
my @files = <*>; # all the files in the current directory
my $total_files = 0; # how many files we changed
my $start_time = time; # time we started processing files

	# read in the command line options
	&getopts("cdhinsv", \%opts);
	# c - change comment only
	# d - debugging
	# i - ignore path, change Track, Title, and Comment tags only
	# h - show help
	# n - don't make changes, just pretend you're going to make changes
	# s - show tags 

	# show help?
	if ( $opts{h} ) { 
		&ShowHelp;
		exit 1;
	} # if ( $opts{h} )

	
	# count the time it takes to process
	# TODO parse out the filename/path here
	# use code from mp3_reencode.pl
		
	# loop thru @files, processing MP3 files only
	foreach my $file (@files) {  
		chomp($file); # remove any trailing EOL's

		# now format the filename so it doesn't make the shell barf
		# add in extra backwhacks to hide shell metacharacters
		$file =~ s/ /\\ /g;
		$file =~ s/\(/\\\(/g;
		$file =~ s/\)/\\\)/g;
		$file =~ s/\,/\\\,/g;
		$file =~ s/\&/\\\&/g;
		$file =~ s/\'/\\\'/g;
#		$file =~ s/\\/\\\\/g;

		# are we displaying tags, or modifying tags?
		if ($show eq "show") {
			system("id3 -l $file");
			if ($total_lines % 5 == 0 and $total_lines != 0) {
				print "Line $total_lines; Press any key to continue";
				$answer = <STDIN>;
				$answer = ""; # this should take care of -w
			}
		}	
		elsif ($show eq "verbose") {
			print "Showing $file\n";
			system("id3 -l $file");
		}
		else { 

			#system("id3 -c  \"SpicyJack's Stash, (R)2000\" $_");	
			my $id3cmd = "id3 -c  \"SpicyJack's Stash, (R)2000\" ";
			system("id3 -c  \"SpicyJack's Stash, (R)2000\" $_");	
		}
	# update total files changed
		$total_lines++;
	}

# tell'em how we did...
	$total_time=time - $start_time;
	$total_min = $total_time /60;
	print "Processed $total_lines lines\n";
	print "in $total_time seconds, or $total_min minutes.\n";

### end main script body ###

############
# ShowHelp #
############
sub ShowHelp {
# display a list of script options and exit
	print "$0:\n";
	print "Batch MP3 ID3 Tagger\n";
	print "Script options:\n";
	print "-c change comment only (edit script to set comment\n";
	print "-d debug, noisy output\n";
	print "-i ignore path, change Track, Title and Comment tags only\n";
	print "   (Track and Title will be taken from the filename)\n";
	print "-n don't make any changes, just pretend\n";
	print "-s show existing tags, don't make any changes\n";
} # sub ShowHelp

# end of line
