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

# the bitmask for what gets returned in a 'get' call
use constant {
    NONE        => 0b0000,
    PARENTS     => 0b0001,
    CHILDREN    => 0b0010,
    FILENAME    => 0b0100,
}; # use constant
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
my $term = new Term::ShellUI( 	
		commands => get_commands($Config, $example_slice),
		app => q(UI demo),
		prompt => q(UI_demo> ),);
#		debug_complete => 2 );

print qq(=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=\n);
print $Config->get(q(program_name)) . qq(, a Perl dependency shell, );
print qq(script version: ) . sprintf("%1.1f", $main::VERSION) . qq(\n);
print q(CVS: $Id$) . qq(\n);
print qq(For help with this script, type 'help' at the prompt\n);

my ($total_examples, $checked_examples ) 
    = &check_for_examples(example_slice => $example_slice);
print qq($total_examples are available examples for platform ') 
    . $Config->get(q(os_name)) . qq('\n);
#use Data::Dumper;
#print Dumper $example_slice;
# yield to Term::ShellUI
$term->run();

exit 0;

################
# get_commands #
################
sub get_commands {
	# the config object
	my $Config = shift; 
# TODO parse $example_slice and see if all of the files it mentions are
# available, if they are, list them when the user calls 'list', run them when
# the user calls 'run', and open them in vim when the user calls 'view'
	my $example_slice = shift; 
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
        desc => qq(Opens a file in vim),
        minargs => 1,
        maxargs => 1,
        proc => sub { 
            my $file = shift;
            if ( &check_file( file=> $file) ) {
                system(qq(/usr/bin/vim $file));
            } else {
                $logger->warn(qq(Can't find file '$file'));
            } # if ( &check_file( file=> $file) )
        } # view->proc
	}, # view
    'v'      =>  { syn => q(view) },
    'vi'     =>  { syn => q(view) },
### run
    'run' => { 
        desc => q(Run a demo),
        cmds => {
            "Win32::GUI" => { 
                desc => qq(Runs the Win32::GUI Widget Demos),
                proc => sub { 
                    # FIXME
                    # create a list of valid demos, list them under 'list',
                    # run them here
                    system qq(/opt/local/bin/widget);
                }, # run->Tk->proc
            }, # run->Tk
            "Tk" => { 
                desc => qq(Runs the Perl/Tk Widget Demo),
                proc => sub { 
                    $logger->info(qq(Starting Tk Widget demo));
                    system qq(/opt/local/bin/widget);
                }, # run->Tk->proc
            }, # run->Tk
            "Gtk2::GladeXML" => { 
                desc => qq(Runs the Gtk2::GladeXML Widget Demo),
                proc => sub { 
                    $logger->info(qq(Starting Gtk2-GladeXML Widget demo));
                    system qq(perl /Users/brian/Files/Windows_Software/)
                        . qq(Gtk2Perl/examples/Gtk2-GladeXML/hello-world.pl);
                }, # run->Gtk2-Glade->proc
            }, # run->Gtk2-Glade
            "Gnome2::Canvas" => { 
                desc => qq(Runs the Gnome2::Canvas Widget Demo),
                proc => sub { 
                    $logger->info(qq(Starting Gnome2-Canvas Widget demo));
                    system qq(perl /Users/brian/Files/Windows_Software/)
                        . qq(Gtk2Perl/examples/Gnome2-Canvas/canvas.pl);
                }, # run->Gnome-Canvas->proc
            }, # run->Gnome-Canvas
            "xlogo" => { 
                desc => qq(Runs the xlogo command to test the X server),
                proc => sub {
                    my $xlogo = q(/usr/X11R6/bin/xlogo);
                    if ( -e $xlogo ) { 
                        system($xlogo) 
                    } else {
                        $logger->warn(q(xlogo not found/not available));
                    } # if ( -e $xlogo )
                }, # run->xlogo->proc
            }, # run->xlogo
            "file" => { 
                desc => qq(Runs a file from the 'list' command),
                minargs => 1,
                maxargs => 1,
                proc => sub { 
                    my $file = shift;
                    if ( defined $file && -e $file ) {
                        $logger->info(qq(Running file $file));
                        system qq(perl $file);
                    } else {
                        $logger->error(qq(Can't find file '$file'));
                    } # if ( -e $file )
                }, # run->file->proc
            }, # run->file
        }, # run->cmds            
    }, # run
	'ru'     =>  { syn => q(run) },
### list
	'list'	=>  { 
        #maxargs => 1,
        desc => q(List demo scripts in the current directory),
        proc => sub { 
            $logger->info(q(Built-in apps: ));
            foreach my $file ( qw(Win32::GUI Tk 
                        Gtk2::GladeXML Gnome2::Canvas) ) {
                eval "use $file;";
                if ( length($@) == 0 ) {
                    # the eval didn't barf
                    $logger->info(qq(\t$file));
                } # if ( ! defined $@ )
            } # foreach my $file ( qw(Tk GTK ) )
            # now get the scripts out on the filesystem
            $logger->info(q(External scripts: ));
            my @filelist = bsd_glob(q(*.pl));
            my @validlist;
            foreach my $file ( @filelist ) {
                #$logger->warn(qq(file is $file));
                #next if ( $file =~ /demo\.pl/ );
                $logger->info(qq(\t$file));
                push(@validlist, $file);
            } # foreach my $file ( @filelist )
            $logger->info(q(Found ) . scalar(@validlist) 
                . ' valid file(s) total');
        }, # list->proc
	}, # list
	'li'     =>  { syn => q(list) },
	'lis'    =>  { syn => q(list) },
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
    # a hash of example filenames, and the full paths to those files
    my %valid_examples;
    # bless the $example_slice into a hash
    my %examples = $args{example_slice};
    # create a list of paths
    my @path_keys = keys(%examples);
    # enumerate over those paths
    foreach my $path ( @path_keys ) {
        # bless the list of examples contained in $path into an array 
        my @examples_list = $examples{$path};
        # then enumerate over each example in the @examples_list 
        foreach my $example_file ( @examples_list ) {
            # normalize the full path to the file
            my $check_example = $path . q(/) . $examples{$example_file};
            # then check the actual file (path + filename)
            if ( &check_file(file => $check_example) ) {
                if ( exists $valid_examples
        } # if ( &check_file(file => $example_file) )
    } # foreach my $key ( @check_keys )
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
