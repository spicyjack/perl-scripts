#!/usr/bin/perl

use lib "/sw/lib/perl5/5.8.1"; # for the Mac
my $i=0;	# a counter

# print the runtime environment
print "##################################################################\n";
print "# Perl Runtime Environment (\%ENV)                                #\n";
print "##################################################################\n";
while (($key, $val) = each %ENV) {
    print "$i $key = $val\n";
	$i++;	
} # while (($key, $val) = each %ENV)
print "\n";

$i=0;	# reset counter

# print the @INC array
print "##################################################################\n";
print "# Perl Module Include Paths (\@INC)                               #\n";
print "##################################################################\n";
printf "%d %s\n", $i++, $_ for @INC;
print "\n";
# FIXME add leading zeros to the %d

$i=0;	# reset counter

# print installed modules
print "##################################################################\n";
print "# Installed Perl Modules (\&modules in \@INC)                      #\n";
print "##################################################################\n";
# NOTES
#   1. Prune man, pod, etc. directories
#   2. Skip files with a suffix other than .pm
#   3. Format the filename so that it looks more like a module
#   4. Print it
use File::Find;
foreach $start (@INC) { find(\&modules, $start); }
	
sub modules {
	if (-d && /^[a-z]/) { $File::Find::prune = 1; return; }
		return unless /\.pm$/;
       	my $filename = "$File::Find::dir/$_";
      	$filename =~ s!^$start/!!;
       	$filename =~ s!\.pm$!!;
        $filename =~ s!/!::!g;
        print "$i $filename\n";
		$i++;
} # sub modules

