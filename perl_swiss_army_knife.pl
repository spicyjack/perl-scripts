#!/usr/bin/perl
# $Id$

# A script to print out a bunch of info about the current Perl environment
# by Brian Manning (brian {at} xaoc dot org)

# The original script most likely appears in the Perl Cookbook from O'Reilly.
# Hacks for obtaining the module version string were taken from:
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

my $DEBUG = 0;
my $print_module_names = 0;
my @found_modules; # a list of modules that were found in @INC paths
my $global_working_dir; # the directory that File::Find started processing in
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
    # FIXME excluding vendor/site perl directories is bad; we should instead
    # see if this path is a parent of a path that's already been searched, and
    # *THEN* skip it if it has already been searched
    next if ( $this_dir =~ /vendor_perl$/ );
    next if ( $this_dir =~ /site_perl$/ );
    if ( tainted($1) ) {
        die qq(ERROR: this_dir still tainted: $1);
    } # if ( tainted($1) )
    if ( -d $1 ) {
        print q(=== @INC: ) . qq($1 ===\n) if ($DEBUG);
        # the find() method calls the callback on every file and directory
        # found in $1
        find(\&modules, $1);
    } # if ( -d $1 )
} # foreach my $this_dir ( @INC )

# reset counter
$i=1;
foreach my $module ( sort { $a->[0] cmp $b->[0] } @found_modules ) {
    printf(qq(%4d %-60s: %s\n),
        $i++, $module->[0], MM->parse_version($module->[1]));
    printf(qq(   - ) . $module->[1] . qq(\n)) if ($print_module_names);
}

# print the butt-end of the HTML if this is CGI
if ( exists $ENV{'REQUEST_METHOD'} ) {
    print "</body></html>\n";
} # if ( exists $ENV{'REQUEST_METHOD'} ) {

exit 0;

### modules ###
sub modules {
    my $current_file = $_;
    print qq(Recieved $current_file from caller\n) if ($DEBUG);
    if ($current_file eq q(.) ) {
        $global_working_dir = $File::Find::dir;
        print qq(New working directory: $global_working_dir\n) if ($DEBUG);
    }
    if (-d $current_file && $current_file =~ /^[a-z]/) {
        $File::Find::prune = 1; return;
    }
    return unless /\.pm$/;
    # Use the contents of $global_working_dir to trim off the beginning
    # of $current_dir, so the end result is full the name of the module
    # without having to figure out the module's namespace/full path
    my $current_dir = $File::Find::dir;
    my $curr_file = "$current_dir/$current_file";
    my $module_name = substr($curr_file, length($global_working_dir));
    print qq(module name is: $module_name\n) if ($DEBUG);
    # remove leading slash
    $module_name =~ s!^/!!;
    # remove trailing '.pm'
    $module_name =~ s!\.pm$!!;
    # convert remaining slashes to double colons
    $module_name =~ s!/!::!g;
    print qq(Module $module_name; filename $curr_file\n) if ($DEBUG);
    #push(@found_modules, [ $module_name, "$current_dir/$current_file" ]);
    push(@found_modules, [ $module_name, $curr_file ]);
    $i++;
} # sub modules

