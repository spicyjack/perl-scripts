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

# FIXME
# - add handling of CGI inputs so you can set things like DEBUG and
# print_module_names; CGI is a core module since 5.004 :/
# - add detection of duplicate modules (same module, different paths); 
#   - flag the output in a way so it gets the user's attention
#   - try to also flag which module gets loaded by the order of what's in the
#   @INC path
# - pretty print the output with nice formatting when the output is HTML and
# not text
# - add a help method that prints the script's POD either on the command line
# or converts it to HTML
# - document this script via POD

use strict;
use warnings;
use ExtUtils::MakeMaker;
use File::Find; # File::Find was first released with perl 5
use Scalar::Util qw(tainted);

my $DEBUG = 0;
my $print_module_names = 0;
#my @found_modules; # a list of modules that were found in @INC paths
my %found_modules; # a list of modules that were found in @INC paths
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
    # skip the dot directory
    next if ( $this_dir =~ /\./ );
    #print qq(tainted: $this_dir\n);
    # untaint the directory
    # the colon is for Windows
    $this_dir =~ /([a-zA-Z0-9:\/\._-]+)/;
    if ( tainted($1) ) {
        die qq(ERROR: this_dir still tainted: $1);
    } # if ( tainted($1) )
    if ( -d $1 ) {
        print q(=== @INC: ) . qq($1 ===\n) if ($DEBUG);
        # the find() method calls the callback on every file and directory
        # found in $1
        find(\&found_object, $1);
    } # if ( -d $1 )
} # foreach my $this_dir ( @INC )

# print the list of modules that were found on the system
# reset counter
$i=1;
# sort the values (module names) from the found modules hash
# - print the filenames if requested
foreach my $module ( sort { $found_modules{$a} cmp $found_modules{$b} }
    keys(%found_modules) ) {

    printf(qq(%4d %-60s: %s\n),
        $i++,
        $found_modules{$module},
        MM->parse_version($module),
    );
    printf(qq(   - ) . $module . qq(\n)) if ($print_module_names);
}

# print the butt-end of the HTML if this is CGI
if ( exists $ENV{'REQUEST_METHOD'} ) {
    print "</body></html>\n";
} # if ( exists $ENV{'REQUEST_METHOD'} ) {

exit 0;

### objects that were found via File::Find ###
sub found_object {
    my $current_file = $_;
    print qq(Recieved $current_file from caller\n) if ($DEBUG);
    if ($current_file eq q(.) ) {
        $global_working_dir = $File::Find::dir;
        print qq(New working directory: $global_working_dir\n) if ($DEBUG);
    }
    if (-d $current_file && $current_file =~ /^[a-z]/) {
        $File::Find::prune = 1; return;
    }
    return unless ($current_file =~ /\.pm$/);
    # Use the contents of $global_working_dir to trim off the beginning
    # of $current_dir, so the end result is full the name of the module
    # without having to figure out the module's namespace/full path
    my $current_dir = $File::Find::dir;
    my $curr_file = "$current_dir/$current_file";
    # skip adding this file to the modules hash if it already exists in the
    # hash
    if ( exists $found_modules{$curr_file} ) {
        warn qq(Module file $curr_file already exists in found modules hash!)
            if ($DEBUG);
        return;
    }
    my $module_name = substr($curr_file, length($global_working_dir));
    print qq(module name is: $module_name\n) if ($DEBUG);
    # remove leading slash
    $module_name =~ s!^/!!;
    # remove trailing '.pm'
    $module_name =~ s!\.pm$!!;
    # convert remaining slashes to double colons
    $module_name =~ s!/!::!g;
    print qq(Module $module_name; filename $curr_file\n) if ($DEBUG);
    # store the module name as the value for a filename key
    $found_modules{$curr_file} = $module_name;
    $i++;
}

