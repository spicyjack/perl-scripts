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

my $term = new Term::ShellUI( 	
		commands => get_commands($Config),
		app => q(UI demo),
		prompt => q(UI_demo> ),);
#		debug_complete => 2 );

print qq(=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=\n);
print $Config->get(q(program_name)) . qq(, a Perl dependency shell, );
print qq(script version: ) . sprintf("%1.1f", $main::VERSION) . qq(\n);
print q(CVS: $Id$) . qq(\n);
print qq(  For help with this script, type 'help' at the prompt\n);

# yield to Term::ShellUI
$term->run();

exit 0;

################
# get_commands #
################
sub get_commands {
	# the config object
	my $Config = shift; 
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
### run
    'run' => { 
        desc => q(Run a demo),
        cmds => {
            "Tk" => { 
                desc => qq(Runs the Perl/Tk Widget Demo),
                proc => sub { 
                    $logger->info(qq(Starting Tk Widget demo));
                    system qq(/opt/local/bin/widget);
                }, # run->Tk->proc
            }, # run->Tk
            "Gtk2-GladeXML" => { 
                desc => qq(Runs the Gtk2-Glade Widget Demo),
                proc => sub { 
                    $logger->info(qq(Starting Gtk2-GladeXML Widget demo));
                    system qq(perl /Users/brian/Files/Windows_Software/)
                        . qq(Gtk2Perl/examples/Gtk2-GladeXML/hello-world.pl);
                }, # run->Gtk2-Glade->proc
            }, # run->Gtk2-Glade
            "Gnome2-Canvas" => { 
                desc => qq(Runs the Gnome2-Canvas Widget Demo),
                proc => sub { 
                    $logger->info(qq(Starting Gnome2-Canvas Widget demo));
                    system qq(perl /Users/brian/Files/Windows_Software/)
                        . qq(Gtk2Perl/examples/Gnome2-Canvas/canvas.pl);
                }, # run->Gnome-Canvas->proc
            }, # run->Gnome-Canvas
            "file" => { 
                desc => qq(Runs a file from the 'list' command),
                proc => sub { 
                    $logger->info(qq(Running file));
                    system qq(perl Gtk2Perl/examples/Gnome-Canvas/canvas.pl);
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
            foreach my $file ( qw(Tk Gtk2-GladeXML Gnome2-Canvas) ) {
                $logger->info(qq(\t$file));
            } # foreach my $file ( qw(Tk GTK ) )
            my @filelist = bsd_glob(q(*.pl));
            $logger->info(q(Found ) . scalar(@filelist) . q( files total));
            foreach my $file ( @filelist ) {
                next if ( $file =~ /.*data\.pl/ );
                $logger->info(qq(\t$file));
            } # foreach my $file ( @filelist )
        }, # list->proc
	}, # list
	'li'     =>  { syn => q(list) },
	'lis'    =>  { syn => q(list) },
	} # return
} # sub get_commands

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

############
# ShowHelp #
############
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
