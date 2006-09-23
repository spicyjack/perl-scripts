#!/usr/bin/perl

# $Id$
# script that collects numbers and outputs diceware words from a list
# Copyright (c)2006 Brian Manning <elspicyjack at gmail dot com>

#   This program is free software; you can redistribute it and/or modify
#   it under the terms of the GNU General Public License as published by
#   the Free Software Foundation; version 2 dated June, 1991.
#
#   This program is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU General Public License for more details.
#
#   You should have received a copy of the GNU General Public License
#   along with this program;  if not, write to the Free Software
#   Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111, USA.

use strict;
use warnings;
# external modules
use Getopt::Long;

package Diceware::Node;
# $this->node_number = node number
# $this->next = list of nodes that are next in lookup order
# $this->node_text = word that belongs to this node

package main;
# variables
my $DEBUG; # are we debugging?
my $dicelist; # path to the word list

	### begin script ###
	
    # http://tinyurl.com/a3e62 <- Getopt::Long docs
	# get the command line switches
    $parser = new Getopt::Long::Parser;
	$parser->configure()
    $parser->getoptions(q(h) => \&ShowHelp, q(help) => \&ShowHelp,
        q(longhelp) => \&ShowHelp,
        q(debug) => \$DEBUG, q(D) => \$DEBUG,
        q(l=s) => \$dicelist, q(list=s) => \$dicelist, q(dl=s) => \$dicelist, 
        q(dicelist=s) => \$dicelist, q(wordlist=s) = \$dicelist,
    );



	# was a filename extension passed in?
	if ( exists $opts{e} && exists $opts{p} ) {	
		@filelist = <$opts{p}/*.$opts{e}>;
	} elsif ( exists $opts{f} ) {
		open (LIST, $opts{f});
		@filelist = <LIST>;
		close (LIST);
	} else {
		die "Please pass either a -f (list of files) or a -p (path) and " .
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
		# is there a file extension?
		if ( exists $opts{e} ) {
			if ( ! exists $opts{w} ) { $opts{w} = "";}
			# are we case-sensitive matching on a pattern
			if ( $opts{C} ) {
				$newname =~ s/$opts{w}//;
			# no, we're case-insensitve matching on a pattern
			} else {
				$newname =~ s/$opts{w}//i;
			} # if ( $opts{C} )
		} # if ( exists $opts{e} )
		$newname =~ s/&/-n-/g;
		$newname =~ s/ /_/g;
        # are we just lowercasing the filename?
        if ( $opts{l} ) { $newname = lc($newname);}
		$splitname[-1] = $newname;

		if ( $opts{d} ) { 
			warn "would have renamed $file\n to new name " . 
				join("/",@splitname) . "\n\n";
		} else {	
			if ( $opts{v} ) { 
				warn "renaming $file\nto " . join("/",@splitname);
			} # if ( $opts{v} )
			rename ( "$file", join("/",@splitname) ) || 
				die "Couldn't rename $file : $!";
		} # if ( $opts{d} )
	} # foreach

	### end main script ###

sub ShowHelp {
# shows the POD documentation (short or long version)
    my $whichhelp = shift;  # retrieve what help message to show 
    shift; # discard the value
    
    # call pod2usage and have it exit non-zero
    # if if one of the 2 shorthelp options were not used, call longhelp
    if ( ($whichhelp eq q(help))  || ($whichhelp eq q(h)) ) {
        pod2usage(-exitstatus => 1); 
    } else {
        pod2usage(-exitstatus => 1, -verbose => 2);
    }


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
		warn " -f filename containing a list of files to parse/rename\n";
		warn " -e filename extension to match when not using a filelist\n";
		warn " -p path to files when not using a filelist\n";
		warn " -l just lowercase the filenames found with -e and -p\n";
		# exit out
		exit 0;
	} # if ( exists $opts{h} )
} # sub ShowHelp	

=pod

=head1 NAME

SomeScript

=head1 SYNOPSIS

diceware.pl [options]

Where options would be one or more of the following:
  -h|--help         Prints a brief help message then exits
  --longhelp        Prints entire help file (including examples)

=head1 DESCRIPTION

B<SomeScript> does I<Something>

=cut

################
# SomeFunction #
################
sub SomeFunction {
} # sub SomeFunction
				
=pod

=head1 CONTROLS

=over 5

=item B<Description of Controls>

=over 5

=item B<A Control Here>

This is a description about A Control.

=item B<Another Control>

This is a description of Another Control

=back 

=back

=head1 FUNCTIONS 

=head2 SomeFunction()

SomeFunction() is a function that does something.  

=head1 VERSION

The CVS version of this file is $Revision$. See the top of this file for the
author's version number.

=head1 AUTHOR

Brian Manning

=cut

# vi: set sw=4 ts=4 cin:
# end of line
1;

