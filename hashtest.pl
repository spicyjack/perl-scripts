#!/usr/bin/perl -w

# hash tester, I'm trying to see if a filename can be a valid key

my %hash;
my $key;
my $file;

foreach $file ( </lib/*> ) {
	$hash{$file} = `dpkg -S $file`;
	chomp($hash{$file});
	if ( $hash{$file} =~ /not found/ ) {
		print "hash key $file is not part of a package\n";
	} else {
		print "hash key $file is " . $hash{$file} . "\n";
	} # if ( $dpkgout =~ /not found.$/ )
} # foreach $file ( </lib/*> )
