#!/usr/bin/perl

# $Id$
# Copyright (c)2007 by Brian Manning <elspicyjack at gmail dot com>

=pod

=head1 NAME

demo.pl

=head1 SYNOPSIS

Simple script to call out other scripts in order to demonstrate different user
interfaces in Perl.

=head1 VERSION

The current version of this script is $Revision$ $Date$

=cut

############
### MAIN 
############
package main;
$main::VERSION = (q$Revision$ =~ /(\d+)/g)[0];
use strict;
use warnings;

#    This program is free software; you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published
#    by the Free Software Foundation; version 2 dated June, 1991.

#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.

#    You should have received a copy of the GNU General Public License
#    along with this program;  if not, write to the Free Software
#    Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111, USA.

# sitewide
BEGIN {
    # module loading block
	#
	# note that some of these modules are loaded above in their own package
	# spaces, but since this BEGIN block is run first when the script is first
	# loaded, and has the most verbose debugging if there's a problem loading a
	# module, the modules are loaded in main's packagespace as well
    my %load_modules = ( 
                    q(AppConfig) => undef,
                    q(File::Glob) => q(:glob),
                    q(JSON) => undef,
					q(Log::Log4perl) => q(get_logger :levels),
                    q(Term::ShellUI) => undef, 
                    q(Time::HiRes) => q(gettimeofday tv_interval),
				); # %modules
	foreach ( keys(%load_modules) ) {
        # if there are values assigned to the module key...
        if ( defined $load_modules{$_} ) {
    	    eval "use $_ qw(" . $load_modules{$_} . ");";
        } else {
    	    eval "use $_";
        } # if ( defined $load_modules{$_} )
   	 	die   " === ERROR: $_ failed to load:\n" 
        	. "     Do you have the $_ module installed?\n"
        	. "     Error output from Perl:\n$@" if $@;
	} # foreach ( keys(%load_modules) )
} # BEGIN

### Begin Script ###

# create a config object with some default variables
my $Config = AppConfig->new();
	
# Help Options
# add a "program_name" parameter to $Config
my @program_name = split(/\//,$0);
$Config->define(q(program_name|pn=s));
$Config->set(q(program_name), $program_name[-1]);
$Config->define(q(help|h!));
$Config->define(q(os_name));
$Config->set(q(os_name), $^O);

# do we need to show the help file?
if ( $Config->get(q(help)) ) {
	&ShowHelp();
} # if ( $Config->get_help() || $Config->get_longhelp() )

# set up the logger
my $logger_conf = qq(log4perl.rootLogger = INFO, Screen\n)
    . qq(log4perl.appender.Screen = ) 
        . qq(Log::Log4perl::Appender::ScreenColoredLevels\n)
    . qq(log4perl.appender.Screen.stderr = 1\n)
	. qq(log4perl.appender.Screen.layout = PatternLayout\n)
	. q(log4perl.appender.Screen.layout.ConversionPattern = %d %p %m%n)
	. qq(\n);
#log4perl.appender.Screen.layout.ConversionPattern = %d %p> %F{1}:%L %M - %m%n

# create the logger object
Log::Log4perl::init( \$logger_conf );
my $logger = get_logger("");

# create a JSON parser object
my $json_parser = JSON->new->ascii->pretty->allow_nonref;
# open the filehandle
open(JSONFH, "< examples.json") || die qq(Can't open examples.json: $!);
# read the lines into an array
my @json_lines = <JSONFH>;
# run it through the decoder to create the perl object reference
my $json_object = $json_parser->decode( join(" ", @json_lines) );
# recast the perl object reference into a hash
my %example_object = %$json_object;
# use the hash to get the list of examples for this platform
my $example_slice = $example_object{$Config->get(q(os_name))};
# now verify that all of the files in that list can be read
my $checked_examples = &check_for_examples(example_slice => $example_slice);
# then create the Term::ShellUI object
my $term = new Term::ShellUI( 	
		commands => get_commands($Config, $checked_examples),
		app => q(UI demo),
		prompt => q(UI_demo> ),);
#		debug_complete => 2 );

print qq(=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=\n);
print $Config->get(q(program_name)) . qq(, a Perl dependency shell, );
print qq(script version: ) . sprintf("%1.1f", $main::VERSION) . qq(\n);
print q(CVS: $Id$) . qq(\n);
print qq(For help with this script, type 'help' at the prompt\n);
# print out how many demo files were found on this platform
my @checked_keys = keys(%$checked_examples);
print qq(Found a total of ) . scalar(@checked_keys) 
    . qq( examples for platform ') . $Config->get(q(os_name)) . qq('\n);
# yield to Term::ShellUI
$term->run();

exit 0;

################
# get_commands #
################
sub get_commands {
	# the config object
	my $Config = shift; 
	my $examples_hash = shift; 
    # recast the hash reference into a real hash
    my %examples = %$examples_hash;
	# grab the logger singleton object
	my $logger = get_logger();

    # this is an anonymous hash containing all of the menu items
	return {
### help
	'help'  =>  { desc => q(Print list of commands) 
                    . q( or info about specific command),
    	args => sub { shift->help_args(undef, @_); },
        meth => sub { shift->help_call(undef, @_); },
        doc => <<HELPDOC
Some examples of commands using the 'help' command:
 
help command
he command
he co
help someothercommand
he so              

HINT: Most commands can be abbreviated to two or three letters :)
HELPDOC
	}, # help
    '?'     =>  { syn => q(help) },
	'h'     =>  { syn => q(help) },
### quit
    'quit'  =>  { desc => q(Exit this script),
        meth => sub { shift->exit_requested(1); } 
	}, #quit
    'exit'  =>  { syn => q(quit) },
    'q'     =>  { syn => q(quit) },
    'x'     =>  { syn => q(quit) },
### view
    'view'  =>  {
        desc => qq(Opens a file read-only in vim),
        minargs => 1,
        maxargs => 1,
        proc => sub { 
            my $file = shift;
            if ( &check_file(file => $examples{$file}) ) {
                if ( $file eq q(xeyes) ) {
                    # we're done
                    $logger->warn(q(You don't want to do that...));
                    return;
                } else {
                    # run perl with the name of the file
                    system(q(/usr/bin/vim -R ) . $examples{$file});
                } # if ( $file == q(xeyes) )
            } else {
                $logger->warn(qq(No match for '$file'));
            } # if ( &check_file( file=> $file) )
        } # view->proc
	}, # view
    'v'      =>  { syn => q(view) },
    'vi'     =>  { syn => q(view) },
### edit
    'edit'  =>  {
        desc => qq(Edits a file in vim),
        minargs => 1,
        maxargs => 1,
        proc => sub { 
            my $file = shift;
            if ( &check_file(file => $examples{$file}) ) {
                if ( $file eq q(xeyes) ) {
                    # we're done
                    $logger->warn(q(You don't want to do that...));
                    return;
                } else {
                    # run perl with the name of the file
                    system(q(/usr/bin/vim ) . $examples{$file});
                } # if ( $file == q(xeyes) )
                
            } else {
                $logger->warn(qq(No match for '$file'));
            } # if ( &check_file( file=> $file) )
        } # view->proc
	}, # view
    'e'      =>  { syn => q(view) },
    'ed'     =>  { syn => q(view) },
### run
    'run' => { 
        desc => q(Run a demo),
        minargs => 1,
        maxargs => 1,
        proc => sub {
            my $file = shift;
            if ( &check_file(file => $examples{$file}) ) {
                if ( $file eq q(xeyes) ) {
                    # call the name of the file by itself
                    system($examples{$file});
                } elsif ( $file eq q(examples.json) ) {
                    $logger->warn(q(You don't want to do that...));
                    return;
                } else {
                    # run perl with the name of the file
                    system(q(env perl ) . $examples{$file});
                } # if ( $file == q(xeyes) )
            } else {
                $logger->warn(qq(No match for '$file'));
            } # if ( &check_file( file=> $file) )
        }, # run->proc            
    }, # run
	'ru'     =>  { syn => q(run) },
### linecount
    'loc' => { 
        desc => q(Count how many lines of code),
        minargs => 1,
        maxargs => 1,
        proc => sub {
            my $file = shift;
            if ( &check_file(file => $examples{$file}) ) {
                if ( $file eq q(xeyes) ) {
                    # call the name of the file by itself
                    $logger->warn(q(You don't want to do that...));
                    return;
                } else {
                    open(FH, "<" . $examples{$file});
                    my $loc_counter;
                    foreach my $line ( <FH> ) {
                        next if ( $line =~ /^#/ );
                        next if ( $line =~ /^$/ );
                        next if ( $line =~ /\/\// );
                        $loc_counter++;
                    } # foreach $line ( <FH> )
                    close(FH);
                    $logger->info(q(File ') . $examples{$file} . q(')); 
                    $logger->info(qq(has $loc_counter lines of code));
                } # if ( $file == q(xeyes) )
            } else {
                $logger->warn(qq(No match for '$file'));
            } # if ( &check_file( file=> $file) )
        }, # run->proc            
    }, # run
	'lines'     =>  { syn => q(loc) },
	'count'     =>  { syn => q(loc) },
### list
	'list'	=>  { 
        #maxargs => 1,
        desc => q(List demo scripts in the current directory),
        proc => sub { 
            my @keys = keys(%examples);
            $logger->info(q(Found the following demo scripts:));
            foreach my $key (@keys) {
                $logger->info(qq(\t) . $key);
            } # foreach my $key (@keys)
            $logger->info(q(Found ) . scalar(@keys) . qq( demo files total));
        }, # list->proc
	}, # list
	'li'    =>  { syn => q(list) },
	'l'     =>  { syn => q(list) },
	} # return
} # sub get_commands

#############
# Functions #
#############
sub check_for_examples {
# check all of the examples listed in the 'examples.json' file; if you can't
# read the file, don't list it.  Returns the total number of examples, and a
# reference to the valid examples hash
#print Dumper $example_slice;
    # input arguments
    my %args = @_;
	my $logger = get_logger();

    # a hash of example filenames, and the full paths to those files
    my %valid_examples;
    # bless the $example_slice into a hash
    my %examples = %{$args{example_slice}};
    # create a list of paths
    my @path_keys = keys(%examples);
    $logger->debug(q(Path keys are: ) . join(":", @path_keys));
    # enumerate over those paths
    foreach my $path ( @path_keys ) {
        # bless the list of examples contained in $path into an array 
        my @examples_list = @{$examples{$path}};
        # then enumerate over each example in the @examples_list 
        $logger->debug(q(examples list is: ) . join(":", @examples_list));
        foreach my $example_file ( @examples_list ) {
            # normalize the full path to the file
            my $check_example = $path . q(/) . $example_file;
            # then check the actual file (path + filename)
            if ( &check_file(file => $check_example) ) {
                # dirty nasty greasy hack to get the last element of the split
                my $basename = (split("/", $check_example))[-1];
                $basename =~ s/\.pl$//;
                $valid_examples{$basename} = $check_example;
            } # if ( &check_file(file => $check_example) )
        } # foreach my $example_file ( @examples_list )
    } # foreach my $path ( @path_keys )
    return \%valid_examples;
} # sub check_for_examples

sub check_file {
# confirms that a file exists
    my %args = @_;
    if ( -e $args{file} ) {
        return 1;
    } else {
        return undef;
    } # if ( -e $args{file} )
} # sub check_file

sub confirm {
# confirms an action with the user prior to performing that action
	my %args = @_;
	my $logger = get_logger();
	$logger->warn($args{confirm_warning});
	print $args{prompt} . q( );
	my $read = <STDIN>;
	return 1 if ( $read =~ /y/ig ); 
	return undef;
} # sub confirm

sub ShowHelp {
# shows the help message
    my $logger = get_logger("");
    warn qq(\nUsage: $0 [options]\n\n);
    warn qq([options] may consist of one or more of the following:\n);
    warn qq(\n General Options:\n);
    warn qq( -h|--help          show this help\n);
	exit 0;
} # sub ShowHelp

# vi: set ft=perl sw=4 ts=4 cin:
