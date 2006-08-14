#!/usr/bin/perl

use strict;
use warnings;
use Net::DNS;

	my $host = q(google.com);
    my $dns = Net::DNS::Resolver->new()->search($host);
	my @answers = $dns->answer();
	foreach (@answers) {
		#print q( answer is a ) . ref($_) . qq(\n);
		#use Data::Dumper;
		#print Dumper $_;
		print qq(found host $host at: ) . $_->address() . qq(\n);
	}
		
