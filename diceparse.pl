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

# TODO
# - suppress warning for Term::ReadPassword if given a --quiet switch
# - allow for multiple word lists, and add a way to choose a random
# wordlist later on

use strict;
use warnings;
# external modules
use Getopt::Long;
use Pod::Usage;
# $noreadpassword get checked below along with --stdin and --ranlength to make
# sure that the script has enough information to run
eval q(use Term::ReadPassword;);
my $noreadpassword;
if ( $@ ) {
    $noreadpassword = 1;
}

=pod

=head1 NAME

diceparse.pl

=head1 SYNOPSIS

diceparse.pl [OPTIONS]

General Options

  [-h|--help|--longhelp]   Shows script help information
  [-r|-rl|-ranlength]      Create this many Diceware words randomly
  [-pr|-perlrandom]        Use Perl's rand() function instead of /dev/random
  [-s|-si|-stdin]          Read Diceware numbers from STDIN
  [-l|-dl|-list|-dicelist] Diceware wordlist to parse for user input.  
  [-D|-d|-debug]           Show debugging output during script execution

=head1 OVERVIEW

Reads a Diceware wordlist, then parses user input to generate a password using
the Diceware wordlist previously read.  Diceware wordlists can be obtained from
L<http://world.std.com/~reinhold/diceware.html>.

=head1 MODULES

=over 4

=cut

# variables
my $DEBUG; # are we debugging?
my $perlrandom; # use rand() function instead of reading /dev/random directly
my $ranlength; # how many random numbers to use for creating a diceware word
my $dicelist; # path to the word list
my $stdin; # read the numbers from standard input
my %diceware; # wordlist with numbers as the index

	### begin script ###
	
    # http://tinyurl.com/a3e62 <- Getopt::Long docs
	# get the command line switches
    my $parser = new Getopt::Long::Parser;
	$parser->configure();
    $parser->getoptions(q(h) => \&ShowHelp, q(help) => \&ShowHelp,
        q(longhelp) => \&ShowHelp,
		q(pr) => \$perlrandom, q(perlrand) => \$perlrandom,
		q(perlrandom) => \$perlrandom,
  		q(r=i) => \$ranlength, q(rl=i) => \$ranlength,
		q(ranlength=i) => \$ranlength,
        q(debug:i) => \$DEBUG, q(D:i) => \$DEBUG,
        q(l=s) => \$dicelist, q(list=s) => \$dicelist, q(dl=s) => \$dicelist, 
        q(dicelist=s) => \$dicelist, q(wordlist=s) => \$dicelist,
		q(stdin) => \$stdin, q(standardin) => \$stdin, 
		q(si) => \$stdin, q(s) => \$stdin,
    );

    my @program_name = split(/\//,$0);

    if ( defined $noreadpassword && 
        ( ! defined $ranlength && ! defined $stdin) ) {
        die qq(Hmmm, there's a problem.  Term::ReadPassword can't load,\n)
			. q(and -ranlength/-stdin not used);
    }

    # grab the wordlist and parse it
    if ( ! defined $dicelist || ! -r $dicelist ) {
        die qq(ERROR: ) . $program_name[-1] . qq(\n)
            . qq(ERROR: No Diceware wordlist file passed in,\n)
            . qq(ERROR: or Diceware wordlist file not readable;\n)
            . qq(ERROR: Please use ) . $program_name[-1] . qq( --help )
            . qq(for a complete list of options\n);
    } # if ( ! defined $dicelist )

    my $counter = 0;

	open (LIST, "< $dicelist");
    foreach my $line (<LIST>) {
	 	chomp($line);
		if ( $line =~ m/^[1-6]{5}/ ) {
			$counter++;
			my ($dicenum, $diceword) = split(/\t/, $line);
			$diceware{$dicenum} = $diceword;
	        #print q(line # ) . sprintf(q(%03d), $counter) . q(:  ') 
	        print q(number: ) . $dicenum . q(, word: ') 
				. $diceword . qq('\n) if ( defined $DEBUG && $DEBUG > 0 );
		} # if ( $line =~ m/^[1-6]{5}/ )
	} # foreach
	print qq(Read in $counter Diceware words\n) if ( defined $DEBUG );

    # if ranlength is not set, read in the dice numbers from the user
    my $dicein = q();
    if ( ! $ranlength ) {
        # maybe $stdin was set instead
		if ( defined $stdin ) {
		    while(<STDIN>) {
                $dicein .= $_;
            }
            $dicein =~ s/\s/ /g;
		} else {
            # nope, grab the numberlist from the user
        	print q(Enter in the list of numbers to translate )
                . qq(into Diceware words:\n);
        	$Term::ReadPassword::USE_STARS = 1;
        	$dicein = read_password(q(diceware string: ));
        } # if ( defined $stdin )
    } else {
		my @bytes; # list of bytes generated randomly
		if ( defined $perlrandom ) {
			# generate random numbers via perl's built-in rand() function
			srand();
			for ( my $x = 1; $x < $ranlength * 5; $x++ ) {
				push(@bytes, int(rand(6)) + 1);
			} # for ( my $x = 1; $x > $ranlength * 5; $x++ )
			$dicein = join(q(), @bytes);
		} else {
			# generate random numbers via the system's /dev/random device
	        open(RANDOM, qq(</dev/random));
  			my $rawrandom;
			while ( length($dicein) < $ranlength * 5 ) {
				# sysread(FILEHANDLE, $buffer, read_length)
		        sysread(RANDOM, $rawrandom, 1);
				my $byte = sprintf("%u", unpack(q(C), $rawrandom));
				if ( $byte < 252 ) {
					# to represent 6 possible values, we can divide 252 by 6,
					# and add one to the result to get the possibility of
					# values between 1 and 6 
					# append the value to the $dicein string
					$dicein .= int($byte/42) + 1;
				} # if ( $byte < 252 )
        	} # while ($dicein < $ranlength)
			close(RANDOM);
		} # if ( defined $perlrand )
    } # if ( ! $ranlength )
    my $dicepassword;
    my $original_in = $dicein;
    # while $dicein has data
    while ( length($dicein) > 4 ) {
        # test a block of 5 bytes
        # substr($scalar, offset, length)
        my $teststring = substr($dicein, 0, 5);
        if ( $teststring =~ m/[1-6]{5}/ ) {
            # we got a match, 5 numbers in a row;
            # add the diceware string to the password
			# FIXME if there is more than one wordlist passed in, choose which
			# wordlist to use here
            $dicepassword .= $diceware{$teststring};
            # and then shorten $dicein by 5 characters 
            $dicein = substr($dicein, 5);
        } else {
            # no match, shorten the $dicein string
            $dicein = substr($dicein, 1);
        } # if ( m/[1-6]{5}/ )
    } # while ( length($dicein) > 0 )

	if ( defined $DEBUG ) {
		# pretty print the output
		print qq(input was: $original_in\n);
		print qq(output is: $dicepassword\n);
	} else {
		# just print the generated password
		print $dicepassword; # . qq(\n);
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
