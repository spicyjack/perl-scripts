#!/usr/bin/perl -w

# hash tester, I'm trying to see if a filename can be a valid key

my %hash;
my $key;
my $file;

foreach $file ( </home/manningb/cvs/scripts/*> ) {
	$hash{$file} = $file;
	print "hash key $file is " . $hash{$file} . "\n";
}
