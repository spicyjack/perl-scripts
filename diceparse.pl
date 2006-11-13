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
use Term::ReadPassword;

=pod

=head1 NAME

diceparse.pl

=head1 SYNOPSIS

diceparse.pl [OPTIONS]

General Options

  [-h|--help|--longhelp]    Shows script help information
  [-r|-rl|--ranlength]      Create this many Diceware words randomly
  [-v|--verbose]            Show verbose script output
  [-l|-dl|-list|--dicelist] Diceware wordlist to parse for user input.  
  [-D|--debug]              Show debugging output during script execution

=head1 OVERVIEW

Reads a Diceware wordlist, then parses user input to generate a password using
the Diceware wordlist previously read.  Diceware wordlists can be obtained from
L<http://world.std.com/~reinhold/diceware.html>.

=head1 MODULES

=over 4

=cut

# variables
my $DEBUG; # are we debugging?
my $VERBOSE; # verbose script output; otherwise, just print the diceware word
my $ranlength; # how many random numbers to use for creating a diceware word
my $dicelist; # path to the word list
my %diceware; # wordlist with numbers as the index

	### begin script ###
	
    # http://tinyurl.com/a3e62 <- Getopt::Long docs
	# get the command line switches
    my $parser = new Getopt::Long::Parser;
	$parser->configure();
    $parser->getoptions(q(h) => \&ShowHelp, q(help) => \&ShowHelp,
        q(longhelp) => \&ShowHelp,
  		q(r=i) => \$ranlength, q(rl=i) => \$ranlength,
		q(ranlength=i) => \$ranlength,
        q(debug) => \$DEBUG, q(D) => \$DEBUG,
		q(verbose) => \$VERBOSE, q(v) => \$VERBOSE,
        q(l=s) => \$dicelist, q(list=s) => \$dicelist, q(dl=s) => \$dicelist, 
        q(dicelist=s) => \$dicelist, q(wordlist=s) => \$dicelist,
    );

    my @program_name = split(/\//,$0);
    if ( ! defined $dicelist ) {
        die qq(ERROR: ) . $program_name[-1] . qq(\n)
            . qq(ERROR: No Diceware wordlist file passed in\n)
            . qq(ERROR: Please use ) . $program_name[-1] . qq( --help )
            . qq(for a complete list of options\n);
    } # if ( ! defined $dicelist )

    my $counter = 0;
    if ( -r $dicelist ) {
        open (LIST, "< $dicelist");
    	foreach my $line (<LIST>) {
	    	chomp($line);
			if ( $line =~ m/^[1-6]{5}/ ) {
		        $counter++;
				my ($dicenum, $diceword) = split(/\t/, $line);
				$diceware{$dicenum} = $diceword;
	            #print q(line # ) . sprintf(q(%03d), $counter) . q(:  ') 
	            print q(number: ) . $dicenum . q(, word: ') 
					. $diceword . qq('\n) if ( $DEBUG );
			} # if ( m/^\d{5}/ )
    	} # foreach
    } # if ( -r $dicelist )
    # if ranlength is not set, read in the dice numbers from the user
    my $dicein;
    if ( ! $ranlength ) {
    	print qq(Read in $counter Diceware words\n) if ( $VERBOSE );
    	print q(Enter in the list of numbers to translate )
            . qq(into Diceware words:\n);
    	$Term::ReadPassword::USE_STARS = 1;
    	$dicein = read_password(q(diceware string: ));
    } else {
        open(RANDOM, qq(</dev/random));
        my $rawrandom;
        sysread(RANDOM, $rawrandom, $ranlength);
        warn(q(read ) . length($rawrandom) . q( bytes from /dev/random));
        # read each byte in $rawrandom, interpret as a die roll
        foreach ( unpack(q(C), $rawrandom) ) {
            print (qq(ord of this byte of rawrandom is ) . ord($_) . qq(\n));
        }
        die;
    } # if ( ! $ranlength )
    my $dicepassword;
    my $original_in = $dicein;
    my $offset = 0;
    # while $dicein has data
    while ( length($dicein) > 4 ) {
        # test a block of 5 bytes
        # substr($scalar, offset, length)
        #my $teststring = substr($dicein, $offset, 5);
        my $teststring = substr($dicein, $offset, 5);
        if ( $teststring =~ m/[1-6]{5}/ ) {
            # we got a match, 5 numbers in a row;
            # add the diceware string to the password
            $dicepassword .= $diceware{$teststring};
            # and then shorten $dicein by 5 characters 
            $dicein = substr($dicein, 5);
            # reset the offset
            #$offset = 0;
        } else {
            # no match, shorten the $dicein string
            $dicein = substr($dicein, 1);
        } # if ( m/[1-6]{5}/ )
    } # while ( length($dicein) > 0 )

	if ( $VERBOSE ) {
		# pretty print the output
		print qq(input was: $original_in\n);
		print qq(output is: $dicepassword\n);
	} else {
		# just print the generated password
		print $dicepassword . qq(\n);
	}
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

