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
use Pod::Usage;

=pod

=head1 NAME

diceparse.pl

=head1 SYNOPSIS

diceparse.pl [OPTIONS]

General Options

  [-h|--help|--longhelp]    Shows script help information
  [-D|--debug]              Show debugging output during script execution
  [-l|-dl|-list|-dicelist]  Diceware wordlist to parse for user input.  

=head1 OVERVIEW

Reads a Diceware wordlist, then parses user input to generate a password using
the Diceware wordlist previously read.  Diceware wordlists can be obtained from
L<http://world.std.com/~reinhold/diceware.html>.

=head1 MODULES

=over 4

=cut

# psuedocode:
# Enter the node parsing function with the diceware word and diceware numbers:
# - Is there still is a list of numbers rolled with the dice?
# Y - shift off a number from the left side, create a new node object from it,
# then recurse the function with the diceware word and the remaining numbers
# N - Assign the text to the current node object
#
# new( 	[-|--]number => (packed number of rolled dice), 
# 		[-|--]text => (text string) )
# get( 	[-|--]number => (packed number of rolled dice) ), returns (text string)

# @numbers = unpack(C5, $number)
# foreach (@numbers) {
# 	if ( exists $node[$_] ) {
# 	}
# }

package Diceparse::Node;
# $this->node_number = node number
# $this->next = list of nodes that are next in lookup order
# $this->node_text = word that belongs to this node

=pod

=item Diceparse::Node

Contains a Diceware node, or a pointer either to the next number in a Diceware
sequence, or a Diceware word 

=cut

package main;
# variables
my $DEBUG; # are we debugging?
my $dicelist; # path to the word list

	### begin script ###
	
    # http://tinyurl.com/a3e62 <- Getopt::Long docs
	# get the command line switches
    my $parser = new Getopt::Long::Parser;
	$parser->configure();
    $parser->getoptions(q(h) => \&ShowHelp, q(help) => \&ShowHelp,
        q(longhelp) => \&ShowHelp,
        q(debug) => \$DEBUG, q(D) => \$DEBUG,
        q(l=s) => \$dicelist, q(list=s) => \$dicelist, q(dl=s) => \$dicelist, 
        q(dicelist=s) => \$dicelist, q(wordlist=s) => \$dicelist,
    );

    my $counter = 0;
    if ( -r $dicelist ) {
        open (LIST, "< $dicelist");
    	foreach my $line (<LIST>) {
            $counter++;
	    	chomp($line);
            print q(line # ) . sprintf(q(%03d), $counter) . q( is ') 
                . $line . qq('\n);
            die(q(counter reached 20)) if ( $counter == 19 );
    	} # foreach
    } # if ( -r $dicelist )
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

} # sub ShowHelp	

=pod

=head1 VERSION

The CVS version of this file is $Revision$. See the top of this file for
the author's version number.

=head1 AUTHOR

Brian Manning

=cut

# vi: set sw=4 ts=4 cin:
# end of line
1;

