#!/usr/bin/perl -w

# Splits up a list of denied hosts that I have on my system
# add them back to the chains, so that they can't cause any more trouble

# constants
$interface="eth1";
$options="-j DENY -l";
my @line;

# check to see if the script was passed anything
    if ( $ARGV[0] eq "" ) {
		print 	"Usage: $0 <filename>, where <filename> is the\n",
				"of the file with saved output from ipfwadm\n";
		exit; 
	}   

# open the file, and split it, line by line; skip the first two lines
	open (IN, $ARGV[0]) || die "Can\'t open file $ARGV[0]: \n$!";
	
	while (<IN>) {
	#	print $_;
		@line = split /\s+/, $_;
#		print @line;
		$src = $line[2]; 
	#	print "$src\n";
		system ("/sbin/ipchains -A input -i $interface $options -s $src")
	} # while

