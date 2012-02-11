#!/usr/bin/perl
# $Id$

# A script to print out a bunch of info about the current Perl environment
# by Brian Manning (elspicyjack {at} gmail &sdot; com)

# The original script most likely appears in the Perl Cookbook from O'Reilly.
# Hacks for the module version were taken from:
# perl module version - http://www.perlmonks.org/?node_id=37237

# File::Find was used because it comes with core Perl, i.e. you don't have to
# install any external modules to use this script.  The only downside is that
# File::Find sucks balls to use.

# if the script detects that it's running as under a CGI environment (the
# REQUEST_METHOD environment variable is set), it will wrap the plaintext
# output in the correct HTML tags so the browser will render it in the same
# manner as if the script were running in a shell.

use strict;
use warnings;
use ExtUtils::MakeMaker;
use File::Find; # File::Find was first released with perl 5
use Scalar::Util qw(tainted);

my @found_modules; # a list of modules that were found in @INC paths
my $working_dir; # the directory that File::Find started processing in
my $i=1;    # a counter

# are we CGI?
if ( exists $ENV{'REQUEST_METHOD'} ) {
    print "Content-type: text/html","\n\n";
    print "<html><body><pre>\n";
} # if ( exists $ENV{'REQUEST_METHOD'} )

print "##################################################################\n";
print "# Perl Executable Name (\$^X)                                     #\n";
print "##################################################################\n";
print qq(Executable name: $^X\n\n);

print "##################################################################\n";
print "# Perl Runtime Environment (\%ENV)                                #\n";
print "##################################################################\n";

# print the runtime environment
foreach my $key ( sort(keys(%ENV)) ) {
    print(sprintf("%2d", $i) . qq( $key = ) . $ENV{$key} . qq(\n));
    $i++;
} # while (($key, $val) = each %ENV)
print "\n";

$i=1;    # reset counter

# print the @INC array
print "##################################################################\n";
print "# Perl Module Include Paths (\@INC)                               #\n";
print "##################################################################\n";
printf qq(%2d %s\n), $i++, $_ for sort(@INC);
print "\n";

$i=0;    # reset counter

# print installed modules
print "##################################################################\n";
print "# Installed Perl Modules (\&modules in \@INC)                      #\n";
print "##################################################################\n";
# NOTES
#   1. Prune man, pod, etc. directories
#   2. Skip files with a suffix other than .pm
#   3. Format the filename so that it looks more like a module
#   4. Print it

# go through each directory in the @INC list
foreach my $this_dir ( @INC ) {
    # untaint the directory
    #print qq(tainted: $this_dir\n);
    # save the name of the directory as $1
    $this_dir =~ /([a-zA-Z0-9\/\._-]+)/;
    if ( tainted($1) ) {
        die qq(ERROR: this_dir still tainted: $1);
    } # if ( tainted($1) )
    if ( -d $1 ) {
        print qq(Calling find on $1\n);
        # the find() method calls the callback on every file and directory
        # found in $1
        find(\&modules, $1);
    } # if ( -d $1 )
} # foreach my $this_dir ( @INC )

# reset counter
$i=1;
#foreach $module ( sort(@found_modules) ) {
#    eval "require $module";
#    printf (qq(%4d %-50s: %s\n), $i++, $module, $module->VERSION) unless ($@);
    #$printf (qq(%4d %-50s\n), $i++, $module);
#$i=1;
foreach my $module ( sort { $a->[0] cmp $b->[0] } @found_modules ) {
    printf(qq(%4d %-50s: %s\n),
        $i++, $module->[0], MM->parse_version($module->[1]));
} # foreach $module ( sort(@found_modules) )

# print the butt-end of the HTML if this is CGI
if ( exists $ENV{'REQUEST_METHOD'} ) {
    print "</body></html>\n";
} # if ( exists $ENV{'REQUEST_METHOD'} ) {

exit 0;

### modules ###
sub modules {
    my $current_file = $_;
    print qq(Recieved $current_file from caller\n);
    if ($current_file eq q(.) ) {
        $working_dir = $File::Find::dir;
        print qq(New working directory: $working_dir\n);
    }
    if (-d $current_file && $current_file =~ /^[a-z]/) {
        $File::Find::prune = 1; return;
    }
    return unless /\.pm$/;
    # FIXME use the contents of $working_dir to trim off the beginning of
    # $current_dir, so the end result is full the name of the module without
    # having to figure out the module's namespace/full path
    my $current_dir = $File::Find::dir;
    my $filename = "$File::Find::dir/$current_file";
    $filename =~ s!^$current_file/!!;
    $filename =~ s!\.pm$!!;
    $filename =~ s!/!::!g;
    print qq(this inc dir is $current_file, filename $filename\n);
    push(@found_modules, [ $filename, "$File::Find::dir/$current_file" ]);
    $i++;
} # sub modules

