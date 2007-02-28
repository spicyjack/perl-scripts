#!/usr/bin/perl

# $Id$
# Copyright (c)2007 by Brian Manning <elspicyjack at gmail dot com>

=pod

=head1 NAME

moddeps.pl

=head1 VERSION

The current version of this script is 0.1 (23Feb2007)

=cut

$VERSION = 0.1;

package PerlModDepWrapper;
use strict;
use warnings;

sub new {
	my $class = shift;
	if ( ref($class) ) {
		die qq(PerlDepShell is not meant to be subclassed... sorry.);
	} # if ( ref($class) )
	my $this = bless ({}, $class);
	return $this;
} # sub new

sub drop_index {
#Module::Dependency::Info::dropIndex();
    my $logger = get_logger();
    $logger->warn(q(drop_index));
} # sub drop_index

sub load_index_file {
	my $logger = get_logger();
    $logger->warn(q(load_index_file));
=pod

	if ( scalar(@_) == 1 ) {
		# see if the file argument exists/is readable
		if ( -r $_[0] ) {
			Module::Dependency::Indexer::setIndex($_[0]);
		} else {
			$logger->warn(q(File ) . $_[0] . q( not found/not readable));
		} # if ( -r $_[0] )
	} # if ( scalar(@_) == 1 )

=cut

} # sub load_index_file

sub save_index_file {
    my $logger = get_logger();
    $logger->warn(q(save_index_file));
} # sub save_index_file

sub create_index_file {
    my $logger = get_logger();
    $logger->warn(q(create_index_file));
} # sub save_index_file

############
### MAIN 
############

package main;
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
    # list of modules to load
    my %load_modules = ( q(Log::Log4perl) => q(get_logger :levels),
                    q(AppConfig) => undef,
                    q(Term::ShellUI) => undef, 
					q(Time::HiRes) => q(gettimeofday tv_interval), 
					q(Module::Dependency::Indexer) => undef,
					q(Module::Dependency::Info) => undef,
#q(PerlModDepWrapper) => undef,
				); # %modules
	foreach ( keys(%load_modules) ) {
        if ( defined $load_modules{$_} ) {
    	    eval "use $_ qw(" . $load_modules{$_} . ");";
        } else {
    	    eval "use $_";
        }
   	 	die   " === ERROR: $_ failed to load:\n" 
        	. "     Do you have the $_ module installed?\n"
        	. "     Error output from Perl:\n$@" if $@;
	}
} # BEGIN

require PerlModDepWrapper;

### Begin Script ###

# create a config object with some default variables
my $Config = AppConfig->new();
	
# Help Options
# add a "program_name" parameter to $Config
my @program_name = split(/\//,$0);
$Config->define(q(program_name|pn=s));
$Config->set(q(program_name), $program_name[-1]);
$Config->define(q(help|h!));
# script behaivor options 
$Config->define(q(debug|DEBUG|d=s@));
$Config->define(q(nocolorlog|nocolourlog|nocl));
$Config->define(q(colorlog));
$Config->define(q(interactive|i!));
# set interactive mode by default, the user can turn it back off
$Config->set(q(interactive), 1);
# path to the module index (module database)
$Config->define(q(dbfile|db=s));
# list of modules to query dependencies from the module index
$Config->define(q(module|mod|m=s@));
# paths to directories containing perl scripts/modules
$Config->define(q(libpath|path|p=s@));
# don't seed the libpath (for Mac OSX)
$Config->define(q(noseed|ns!));
# don't confirm before deleting files
$Config->define(q(noconfirm|nc!));

# parse the command line
$Config->args(\@ARGV);

# do we need to show the help file?
if ( $Config->get(q(help)) ) {
	&ShowHelp();
} # if ( $Config->get_help() || $Config->get_longhelp() )

# set some defaults, these will be superceded by the same command line
# parameters (if any)

# set a default database file if the user doesn't provide one 
# the user can change this later if they wish
if ( ! defined $Config->get(q(dbfile)) ) { 
    $Config->set(q(dbfile), qq(/tmp/perldep.$$.db)); 
} # if ( ! defined $Config->get(q(dbfile)) )

# do this unless 'noseed' is set
unless ( $Config->get(q(noseed)) ) {
    # seed the libpath with some defaults
    $Config->set(q(libpath), q(/usr/lib/perl));
    $Config->set(q(libpath), q(/usr/lib/perl5));
    $Config->set(q(libpath), q(/usr/share/perl));
    $Config->set(q(libpath), q(/usr/share/perl5));
} # if ( ! $Config->get(q(noseed)) )

# set up the logger
my $logger_conf = qq(log4perl.rootLogger = INFO, Screen\n);
if ( $Config->get(q(colorlog)) ) {
    $logger_conf .= qq(log4perl.appender.Screen = ) 
    	. qq(Log::Log4perl::Appender::ScreenColoredLevels\n);
} else {
    $logger_conf .= qq(log4perl.appender.Screen = )
		. qq(Log::Log4perl::Appender::Screen\n);
} # if ( $Config->get(q(colorlog)) )

$logger_conf .= qq(log4perl.appender.Screen.stderr = 1\n)
	. qq(log4perl.appender.Screen.layout = PatternLayout\n)
	. q(log4perl.appender.Screen.layout.ConversionPattern = %d %p %m%n)
	. qq(\n);
#log4perl.appender.Screen.layout.ConversionPattern = %d %p> %F{1}:%L %M - %m%n

if ( scalar(@{$Config->get(q(debug))}) ) {
    warn qq(logger_conf is:\n$logger_conf);
} # if ($Config->get(q(debug))) 

# create the logger object
Log::Log4perl::init( \$logger_conf );
my $logger = get_logger("");

if ( @{$Config->get(q(debug))} > 0 ) {
	if ( grep(/all/, @{$Config->get(q(debug))}) ) {
    	$logger->level($DEBUG);
    } elsif ( grep(/info/, @{$Config->get(q(debug))}) ) {
    	$logger->level($INFO);
    } else {
		$logger->warn(q("DEBUG" switch turned on, but the debug option used));
		$logger->warn(q(is not recognized by this script));
	} # if ( grep(/all/, @{$Config->debug()}) )
} # if ( scalar($Config->debug()) > 0 )

my $moddep = new PerlModDepWrapper( indexfile => $Config->get(q(dbfile)) );
my $term = new Term::ShellUI( 	commands => get_commands($Config, $moddep),
								app => q(perldepsh),
								prompt => q(perldepsh> ),);
#								debug_complete => 2 );

print qq(=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=\n);
print $Config->get(q(program_name)) . qq(, a Perl dependency shell, );
print qq(script version: ) . sprintf("%1.1f", $main::VERSION) . qq(\n);
print q(CVS: $Id$) . qq(\n);
print q(  For help with commands, type 'help' (without quotes) )
    . qq(at the prompt;\n);
#print qq(  You can view a list of command examples with 'show examples'\n);

# yield to Term::ShellUI
$term->run();

exit 0;

################
# get_commands #
################
sub get_commands {
	# the config object
	my $Config = shift; 
	# the depshell object, a wrapper around	Module::Dependency 
	my $moddep = shift; 
	# grab the logger singleton object
	my $logger = get_logger();
    my @modlist;

    if ( scalar( @{$Config->get(q(module))} ) > 0 ) {
        @modlist = @{$Config->get(q(module))};
    } # if ( scalar( @{$Config->get(q(getmods))} ) > 0 )

	return {
### help
	'help'  =>  { desc => q(Print list of commands/info about specific command),
    	args => sub { shift->help_args(undef, @_); },
        meth => sub { shift->help_call(undef, @_); },
        doc => <<HELPDOC
Some examples of the 'help' command:
 
help help
he help
he he
help show
he sh              
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
### idx (index)
    'idx' => { desc => q(Dependency index commands),
        cmds => {
			### drop
            'drop' => {
                desc => q(Drops the currently loaded index),
                proc => sub { $moddep->drop_index(); },
            }, # idx->drop
            'clear'     =>  { syn => q(drop) },
            'dr'     =>  { syn => q(drop) },
			### drop
            'delete' => {
                desc => q(Deletes an index file (if it exists) ),
                proc => sub { 
                    # do this unless 'noconfirm' is set
                    unless ( $Config->get(q(noconfirm)) ) {
                        # verify this is what the user really wants prior to
                        # doing it
                        return unless ( &confirm(
                                confirm_warning => 
                                qq(Do you really want to delete ) 
                                . $Config->get(q(dbfile)),
                                prompt => qq(Delete ) . $Config->get(q(dbfile))
                                . q( [Y/n]? ) ) );
                    } # if ( $Config->get(q(noconfirm) )
                    if ( -f $Config->get(q(dbfile)) ) {
                        if ( unlink($Config->get(q(dbfile))) == 0 ) { 
                            $logger->error(q(Unable to delete index file )
                                . $Config->get(q(dbfile)) . qq(: $!) );
                        } # if ( unlink($Config->get(q(dbfile))) == 0 )
                    } # if ( -f $Config->get(q(dbfile)) )
                }, # idx->delete->proc
            }, # idx->drop
            'del'     =>  { syn => q(delete) },
			### load
            'load' => {
                desc => q(Loads an index from a file),
                proc => sub { $moddep->load_index_file(); }
            }, # idx->load
            'lo'     =>  { syn => q(load) },
			### save 
            'save' => {
                desc => q(Saves an index to a file),
                proc => sub { $moddep->save_index_file(); }
            }, # idx->load
            'sa'     =>  { syn => q(save) },
			### create
            'create' => {
                desc => q(Creates a new index file),
                proc => sub { 
                    # check to see if the user specified a filename first
                    if ( scalar(@_) >= 1 ) {
                        # yep; set this file to be 'dbfile' if
                        # create_index_file returns success
                        $Config->set(q(dbfile), $_[0])
                            if ($moddep->create_index_file(filename => $_[0] ));
                    # then fall back to the 'dbfile' Config variable
                    } elsif ( $Config->get(q(dbfile)) ) {
                        $moddep->create_index_file(
                            filename => $Config->get(q(dbfile)) );
                    # barf otherwise
                    } else {
                        $logger->warn(q(No database file specified...));
                        $logger->warn(
                            q(Please specify a filename to use for the index));
                    } # if ( $Config->get(q(dbfile)) )
                }, # idx->create->proc
            }, # idx->create
            'cr' => { syn => q(create) },
            'new' => { syn => q(create) },
        }, # idx->cmds
    }, # idx
### show
	'show'	=>  { desc => q(Shows examples/current configuration values),
        maxargs => 1,
		cmds => {
		    ### examples
    		'examples' => {
                desc => q(Some usage examples),
		        proc => sub { print <<EXAMPLES
  Select a file:                          'file /path/to/some/file'
  Get dependencies:                       'get'
  Select file and get dependencies:       'get /path/to/some/file'
  View a list of files in the database:   'show files'
EXAMPLES
				}, # show->examples->proc
        	}, # show->examples
	    	'ex'     =>  { syn => q(examples) },
		}, # show->cmds
	}, # show
	'sh'     =>  { syn => q(show) },
### get
	'get'  =>  { desc => q(Get the dependencies for one or more Perl modules),
	# if getfiles is defined, or the file is passed in on @_
    	proc => sub {
			if ( scalar @modlist > 0 || scalar(@_) ) {
                # Process getfiles; if a list was passed in, process all of the
                # files or directories in the list; files will be processed
                # individually, directories will be have their contents
                # processed as individual files; add a --subdirectories option,
                # and recurse into subdirectories if requested
                # any files passed in replace the files that were in @modlist
				if ( scalar(@_) ) {
					# reset @modlist before we assign to it, or we will end up
					# appending the new entries
                    @modlist = undef;
                    @modlist = @_;
				} # if ( scalar(@_) )
                # getfiles may have multiple entries; loop across each one of
                # them
				$logger->debug(q(modlist currently holds:));
				$logger->debug( join(q(;), @modlist) );
				$logger->debug(q(the following modules were passed in:));
				$logger->debug( join(q(;), @_) );
                #$filedb->_start_timer(q(overall));
			} else {
				$logger->warn(q(Please input one or more modules to look));
				$logger->warn(q(up dependencies for.));
			} # if ( scalar @modlist > 0 || scalar(@_) )
		}, # get->proc
	}, # get
	'ge'     =>  { syn => q(get) },
### graph 
	'graph'	=>  { desc => q(Sets script configuration values),
		cmds => {
			'dependencies' => {
				desc => q(Flag for whether or not to recurse dependencies),
                proc => sub { 
					$logger->warn(q(This command is not implemented));
                }, # graph->cmds->dependencies->proc
            }, # graph->cmds->dependencies
			'de'     =>  { syn => q(dependencies) },
			'dep'     =>  { syn => q(dependencies) },
			'deps'     =>  { syn => q(dependencies) },
        }, # graph->cmds
    }, # graph
	'gr'     =>  { syn => q(graph) },

	} # return
} # sub get_commands

sub confirm {
	my %args = @_;
	my $logger = get_logger();
	$logger->warn($args{confirm_warning});
	print $args{prompt} . q( );
	my $read;
	$read = <STDIN>;
	return 1 if ( $read =~ /y/ig ); 
	return undef;
} # sub confirm

############
# ShowHelp #
############
sub ShowHelp {
# shows the help message
    warn qq(\nUsage: $0 [options]\n);
    warn qq([options] may consist of one or more of the following:\n);
    warn qq( -h|--help          show this help\n);
    warn qq( -d|--debug         run in debug mode (extra noisy output)\n);
    warn qq( -i|--interactive   run in interactive mode (default)\n);
    warn qq( -noi|--nointeractive   Don't run in interactive mode\n);
    warn qq( -m|--module	    Perl module to work out dependencies for\n);
    warn qq( (use --module multiple times to specifiy multiple modules)\n);
    warn qq( -nocl|--nocolorlog don't colorize the shell output\n);
	exit 0;
} # sub ShowHelp

# vi: set ft=perl sw=4 ts=4 cin:
