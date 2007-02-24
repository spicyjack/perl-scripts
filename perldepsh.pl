#!/usr/bin/perl

# $Id$
# Copyright (c)2007 by Brian Manning <elspicyjack at gmail dot com>

=pod

=head1 NAME

perldepsh.pl

=head1 VERSION

The current version of this script is 0.1 (23Feb2007)

=cut

$VERSION = 0.1;
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
    my %modules = ( q(Log::Log4perl) => q(get_logger :levels),
                    q(AppConfig) => undef,
                    q(Term::ShellUI) => undef, 
					q(Time::HiRes) => q(gettimeofday tv_interval), 
					q(Module::Dependency::Indexer) => undef,
					q(Module::Dependency::Info) => undef,
					q(PerlDepShell) => undef,
				); # %modules
	foreach ( keys(%modules) ) {
        if ( defined $modules{$_} ) {
    	    eval "use $_ qw(" . $modules{$_} . ");";
        } else {
    	    eval "use $_";
        }
   	 	die   " === ERROR: $_ failed to load:\n" 
        	. "     Do you have the $_ module installed?\n"
        	. "     Error output from Perl:\n$@" if $@;
	}
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
# more script behaivor options 
$Config->define(q(debug|DEBUG|d=s@));
$Config->define(q(expert|e!));
$Config->define(q(getmods|gm|g=s@));
$Config->define(q(nocolorlog|nocolourlog|nocl));
$Config->define(q(colorlog));
$Config->define(q(interactive|i!));
# set interactive mode by default, the user can turn it back off
$Config->set(q(interactive), 1);
$Config->define(q(dbfile|db=s));

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

my $perldepsh = new PerlDepShell( indexfile => $Config->get(q(dbfile)) );
my $term = new Term::ShellUI( 	commands => get_commands($Config, $perldepsh),
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
	my $perldepsh = shift; 
	# grab the logger singleton object
	my $logger = get_logger();
    my @modlist;

    if ( scalar( @{$Config->get(q(getmods))} ) > 0 ) {
        @modlist = @{$Config->get(q(getmods))};
    } # if ( scalar( @{$Config->get(q(getmods))} ) > 0 )

	return {
### help
	'help'  =>  { desc => q(Print list of commands/info about specific command),
    	args => sub { shift->help_args(undef, @_); },
        meth => sub { shift->help_call(undef, @_); },
        doc => <<HELPDOC
Some examples of the 'help' command:
 
help help
h help
h h
help list
h list              
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
                proc => sub { $perldepsh->drop_index(); },
            }, # idx->drop
            'clear'     =>  { syn => q(drop) },
            'delete'     =>  { syn => q(drop) },
            'dr'     =>  { syn => q(drop) },
            'del'     =>  { syn => q(drop) },
			### load
            'load' => {
                desc => q(Loads an index from a file),
                proc => sub { &load_index_file(); }
            }, # idx->load
            'lo'     =>  { syn => q(load) },
			### save 
            'save' => {
                desc => q(Saves an index to a file),
                proc => sub { &save_index_file(); }
            }, # idx->load
            'sa'     =>  { syn => q(save) },
			### create
            'create' => {
                desc => q(Creates a new index file),
                proc => sub { &create_index_file(@_); },
            }, # idx->create
            'cr' => { syn => q(create) },
            'new' => { syn => q(create) },
            'all' => { 
                desc => q(Wipes all databases and lists),
                proc => sub { 
                    $filedb->clear_filedb(); 
                    $filedb->clear_pkgs();
                    @modlist = undef; 
                }, # clear->all
            }, # clear->all
            'a'     =>  { syn => q(all) },
        }, # clear->cmds
    }, # clear
### show
	'show'	=>  { desc => q(Shows current script/configuration values),
        maxargs => 1,
		cmds => {
            # FIXME paginate the output of this function
 			### cache
			'cache' => {
                desc => q(Displays files/packages cached by the shell),
                cmds => {
                    'files' => {
        				desc => q(Displays a list of files cached by the shell),
		        		proc => sub {
				        	if ( $filedb->_count_filedb_keys() > 0 ) {
						    # yes, there are files in the database
    						if ( $filedb->_count_filedb_keys() > 1 ) {
	    						$logger->info(q(There are currently ) 
		    						. $filedb->_count_filedb_keys() 
			    					. q( files in the FileDb:)); 
				    		} else {
					    		$logger->info(q(There is currently 1 file )
						    		. q( in the FileDb:));
    						} # if ( $filedb->_count_filedb_keys() > 1 ) 
	    					foreach ( sort($filedb->_get_filedb_keys()) ){
                                # FIXME put something in here that detects
                                # symlinked files, and change the output when a
                                # symlinked file is output
                                # have a switch that you can toggle that shows
                                # what ldd resolves files to, and what the
                                # files actually are (symlinks resolved)
					    		$logger->info( qq(  $_) );
    						} # foreach (@{$filedb->_get_filedb_keys()})
	    				} else {
		    				$logger->info(q(There are currently no files )
			    				. q(in the FileDb));
				    	} # if ( $filedb->_count_filedb_keys() > 0 )
                    }, # cache->files->proc
				}, # cache->files
    			'fi'     =>  { syn => q(files) },
                'packages' => {
                    desc => q(Displays a list of packages cached by the shell),
		        	proc => sub {	
				        if ( $filedb->_count_pkg_keys() > 0 ) {
						    # yes, there are files in the database
    						if ( $filedb->_count_filedb_keys() > 1 ) {
	    						$logger->info(q(There are currently ) 
		    						. $filedb->_count_pkg_keys() 
                                    . q( packages in the PKGS database:)); 
				    		} else {
					    		$logger->info(q(There is currently 1 package )
						    		. q( in the PKGS database:));
    						} # if ( $filedb->_count_filedb_keys() > 1 ) 
	    					foreach ( sort($filedb->_get_pkg_keys()) ){
					    		$logger->info( qq(  $_) );
    						} # foreach (@{$filedb->_get_pkg_keys()})
	    				} else {
		    				$logger->info(q(There are currently no package )
			    				. q(in the PKGS database));
                        } # if ( $filedb->_count_filedb_keys() > 0 )
                    }, # cache->packages->proc
                }, # cache->packages
    			'pkgs' => { syn => q(packages) },
    			'pkg' => { syn => q(packages) },
    			'pa' => { syn => q(packages) },
		    	}, # cache->cmd
            }, # cache
	    	'ca'     =>  { syn => q(cache) },
		    ### examples
    		'examples' => {
                desc => q(Some usage examples),
		        proc => sub { print <<EXAMPLES
  Select a file:                          'file /path/to/some/file'
  Get dependencies:                       'get'
  Select file and get dependencies:       'get /path/to/some/file'
  View a list of files in the database:   'show files'
EXAMPLES
				}, # examples->proc
        	}, #examples
	    	'ex'     =>  { syn => q(examples) },
		    ### recursion
            'recursion' => {
                desc => q(Flag for deciding whether or not to recurse )
                    . q(dependencies),
                proc => sub { 
                    $logger->info(q(Recursion is currently set to )
                        . ($Config->get(q(recursion)) 
                        ? $Config->get(q(recursion)) : 0 ) );
                }, # recursion->proc
            }, # recursion
            're' => { syn => q(recursion) }, 
            'outformat' => {
                desc => q(Output format for writing package files),
                proc => sub { 
                    if ( defined $Config->get(q(outformat)) ) {
                        $logger->info(q(Output format is currently set to ')
                            . $Config->get(q(outformat)) . q('));
                    } else {
                        $logger->info(q(Output format is currently undefined));
                    } # if ( defined $Config->get(q(outformat)) ) 
                }, # outformat->proc
            }, # show->outformat
            'of' => { syn => q(outformat) }, 
    		### fileinfo
	    	'fileinfo'	=>  { 
		        desc => q(Dumps the FileInfo object for the current file(s)),
    	    	maxargs => 0,
	    		proc => sub { 	
                    # make sure getfiles is defined
                    if ( scalar(@modlist) > 0 ) {
                        foreach ( @modlist ) {
                            $logger->info(qq(Dumping FileInfo for $_ :));
        					my $fileinfo = $filedb->_get_file_obj($_);
                            # make sure FileInfo has been run
        	    			if ( defined $fileinfo ) { 
	        	    		    $fileinfo->dump_attribs();
                            } else {
                                $logger->warn(qq(FileInfo object does not ));
                                $logger->warn(qq(exist for file: $_) );
    		    			} # if ( defined $fileinfo )
                        } # foreach ( @modlist )         
                    } else {
    					$logger->warn(q(Get files list is undefined));
                    } # if ( scalar(@modlist > 0 )
		    	}, # info->proc
    		}, # info
	    	'fi'     =>  { syn => q(fileinfo) },
    		### attrib
	    	'attribute' =>  { 
    		    desc => q(Dumps one attribute from the FileInfo object),
	    		minargs => 1,
		    	maxargs => 1,
    			proc => sub {
	    		    if ( scalar(@modlist) > 0 ) { 
            	    	my $attrib = shift;
	        		    $attrib =~ s/^_//;
                        foreach ( @modlist ) {
    		    		    my $fileinfo = $filedb->_get_file_obj($_);
                            if ( defined $fileinfo ) {
                                $fileinfo->dump_attribs(q(_) . $attrib);
                            } else {
                                $logger->warn(qq(FileInfo object does not ));
                                $logger->warn(qq(exist for file: $_) );
                            } # if ( defined $fileinfo )
	    				} # foreach ( @modlist )
                    } else {
			    	    $logger->warn(q(Current file is undefined));
				    } # if ( defined @modlist
    			}, # attrib->proc
	    	}, # attrib
		    'at'     =>  { syn => q(attribute) },
    		'attrib'     =>  { syn => q(attribute) },
	    	### package
    		'package'	=>  { 
	    	    desc => q(Dumps the Package information for the current file),
	        	maxargs => 0,
			    proc => sub { 	
                    if ( scalar(@modlist) ) {
    				    foreach ( @modlist ) {
                            my $pkgobj = $filedb->_get_pkg_obj(
                                $filedb->_get_pkg_name($_) );
	                        if ( defined $pkgobj ) {
		                        $logger->info(qq(File '$_' belongs to ') 
					    		    . $filedb->_get_pkg_name($_) . q(') );
        	    	            $logger->info(q(Package attributes are:));
                                if ( ref($pkgobj) 
                                    ne qq(AntBuild::Pkg::DarwinPorts) ) {
                                        $logger->info(q(  combined_version: ) 
                                            . $pkgobj->get_source_version()
                                            . q(-) 
                                            . $pkgobj->get_distro_version() );
                                } # if ( ref($pkgobj)
	                            $pkgobj->dump_pkginfo();
            	            } else {
                	            $logger->warn(qq(File '$_'));
                      		    $logger->warn(q(does not belong to a package));
	                        } # if ( defined $pkgobj )
			    		} # foreach ( @modlist )
                    } # if ( defined @modlist )
                }, # pkg->proc
            }, # pkg
            'pkg' => { syn => q(package) },
            'pk' => { syn => q(package) },
		    ### versions
    		'versions' => { 
	    		desc => q(Dumps the version information for scripts/binaries),
	        	maxargs => 0,
			    proc => sub { 	
                    my @modules = qw( Log::Log4perl AppConfig 
                        Term::ShellUI Time::HiRes AntBuild::FileDb
                        AntLinux::Pkg::DarwinPorts );
                    $logger->info(q(Script/Program Versions:));
                    foreach ( @modules ) {
                        my $mod_ver = $_::VERSION;
                        $logger->info(qq(  $_ : $mod_ver));
                        if ( $_->can(q(get_version)) ) {
                            $logger->info(q(    Program version: ) 
                                . AntLinux::Pkg::DarwinPorts->get_version() );
                        } # if ( $_->can(q(get_version)) )
                    } # foreach ( @modules )
                }, # versions->proc
            }, # versions
		}, # show->cmds
	}, # show
	'sh'     =>  { syn => q(show) },
### get
	'get'  =>  { desc => q(Get and/or show dependencies for a file),
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
                    @modlist = undef;
                    @modlist = @_;
				} # if ( scalar(@_) )
                # getfiles may have multiple entries; loop across each one of
                # them
				$logger->debug(q(getfiles currently holds:));
				$logger->debug( join(q(;), @modlist) );
				$logger->debug(q(the following files were passed in:));
				$logger->debug( join(q(;), @_) );
                $filedb->_start_timer(q(overall));
                foreach my $gfentry ( @modlist ) {
    				if ( -e $gfentry && -r $gfentry ) {
                        # start the timer
                        $filedb->_start_timer($gfentry);
                        # get the file dependencies
					    my @dependencies 
						    = $filedb->get_file_deps($gfentry);
    					# print a total
	    				if ( $filedb->count_deps($gfentry) > 0 ) {
		    				$logger->info(q(For file ) 
						        . q(') . $gfentry  . q(';));
                            $logger->info(q(There are ) 
				    			. $filedb->count_deps($gfentry)
					    		. q( file dependencies,));
                            $logger->info(q(dependency searching took ) 
                                . $filedb->_stop_timer($gfentry) 
                                . q( seconds total.));
		    				$logger->info(q(The dependencies are:));
			    			# print each dependency
				    		foreach ( sort(@dependencies) ) {
					    		$logger->info( qq(  $_) );
						    } # foreach (@dependencies)
    					} else {
                            $filedb->_stop_timer($gfentry);
		    				$logger->info(q(File ') . $gfentry  . q(' )
                                . q(has no dependencies));
                            my $fileobj = $filedb->_get_file_obj($gfentry);
                            if ( $fileobj->is_S_IFLNK() ) {
                                $logger->info(q(File ') . $gfentry  . q(' )    
                                    . q(is a symlink to:));
                                $logger->info(q(  ') 
                                    . $fileobj->get_links_to() . q(') );
                            } # if ( $fileobj->is_S_IFLNK() )
                        } # if ( defined @dependencies )
    				} else {
	    				$logger->warn(q(File ') . $gfentry
		    				. q(' is either not a regular file, ));
			    		$logger->warn(q(does not exist, or is not readable));
    			  	} # if ( -r $gfentry && -f $gfentry )
                } # foreach my $gfentry ( @modlist )
                $logger->info(q(All dependencies found in ) 
                    . $filedb->_stop_timer(q(overall)) . q( seconds.));
			} else {
				$logger->warn(q(Current file is undefined));
			} # if ( scalar @modlist > 0 || scalar(@_) )
		}, # get->proc
	}, # get
	'ge'     =>  { syn => q(get) },
### set
	'set'	=>  { desc => q(Sets script configuration values),
		cmds => {
			'recursion' => {
                maxargs => 0,
				desc => q(Flag for whether or not to recurse dependencies),
                proc => sub { 
                    my $recursion = $Config->get(q(recursion));
                    $Config->set(q(recursion), ! $recursion);
                    $logger->info(q(Recursion set to: ) 
                        . $Config->get(q(recursion)) );
                }, # recursion->proc
            }, # set->recursion
	        're'     =>  { syn => q(recursion) },
			'outformat' => {
                desc => q(Sets the output format of packages),
                maxargs => 1,
                cmds => {
                    # tar/bzip2 
                    'tarbz2' => {
                        proc => sub { $Config->set(q(outformat), q(tarbz2)); 
                            $logger->info(q(Outformat set to: ) 
                                . $Config->get(q(outformat)) );
                        },
                        desc => q(Packages will be created using Tar/Bzip2),
                    }, 
                    'bz' => { syn => q(tarbz2) },
                    'bz2' => { syn => q(tarbz2) },
                    'tarbz' => { syn => q(tarbz2) },
                    # tar/gzip
                    'targz' => {
                        proc => sub { $Config->set(q(outformat), q(targz)); 
                            $logger->info(q(Outformat set to: ) 
                                . $Config->get(q(outformat)) );
                        },
                        desc => q(Packages will be created using Tar/Gzip),
                    }, 
                    'gz' => { syn => q(targz) },
                    'gzip' => { syn => q(targz) },
                    # cramfs
                    'cramfs' => {
                        proc => sub { $Config->set(q(outformat), q(cramfs));
                            $logger->info(q(Outformat set to: ) 
                                . $Config->get(q(outformat)) ); 
                        },
                        desc => q(Packages will be created using Cramfs),
                    }, 
                    'cram' => { syn => q(cramfs) },
                    # squashfs
                    'squashfs' => {
                        proc => sub {$Config->set(q(outformat), q(squashfs));
                            $logger->info(q(Outformat set to: ) 
                                . $Config->get(q(outformat)) );
                        },
                        desc => q(Packages will be created using Squashfs),
                    }, 
                    'sqs' => { syn => q(squashfs) },
                    'sfs' => { syn => q(squashfs) },
                    # perl archiver
                    'par' => {
                        proc => sub { $Config->set(q(outformat), q(par));
                            $logger->info(q(Outformat set to: ) 
                                . $Config->get(q(outformat)) ); 
                        },
                        desc => q(Packages will be created using Perl Archive),
                    }, 
                    # zip 
                    'zip' => {
                        proc => sub { $Config->set(q(outformat), q(zip));
                            $logger->info(q(Outformat set to: ) 
                                . $Config->get(q(outformat)) ); 
                        },
                        desc => q(Packages will be created using Zip),
                    }, 
                }, # outformat->cmds
            }, # outformat
	        'of'     =>  { syn => q(outformat) },
        }, # set->cmds
    }, # set
	'se'     =>  { syn => q(set) },
	'list'	=>  { desc => q(Loads/saves lists of dependencies),
		cmds => {
            'set' => {
                desc => q(set the list of files, )
                    . q(but don't run dependency checks),
                proc => sub {
                    # any files passed in replace the files that were in
                    # @modlist
    				if ( scalar(@_) ) {
                        # zero out the modlist first
                        @modlist = undef;
                        @modlist = @_;
			    	} # if ( scalar(@_) )
                }, # set->proc
            }, # list->set
			'show' => {
                desc => 
                    q(Displays the current list of files to the screen),
                # FIXME this needs to use the paginate method
                # get the current list of files
                proc => sub {
        			if (scalar @modlist > 0 ) {
                        $logger->info(q(The current file list is:));
    					foreach ( @modlist ) {
	    					$logger->info(qq(  $_));  
		    			} # foreach ( @modlist )
			    	} else {
				    	$logger->warn(q(Current file list is empty));
    				} # if (scalar @modlist > 0 )
                    # pass the list to paginate
                }, # show->proc
            }, # list->show
			'pshow' => {
                desc => 
                    q(Displays the current list of files/packages to screen),
                # FIXME this needs to use the paginate method
                # get the current list of files and their packages
                proc => sub {
        			if (scalar @modlist > 0 ) {
                        $logger->info(q(The current file list )
                            . q((with packages) is:));
                        foreach ( @modlist ) {
                            my $package = $filedb->_get_pkg_name($_);
                            if ( ! defined $package ) {
                                $package = q(<none>);
                            } # if ( ! defined $package )
                            $logger->info(q(  ) . $package . q(::) . $_);
                        } # foreach ( @modlist )
                        # paginate
                    } # if (scalar @modlist > 0 )
                }, # pshow->proc
            }, # list->pshow
			'load' => {
                desc => 
                    q(Loads a list of file or file/package dependency pairs),
                minargs => 1,
                maxargs => 1,
            # FIXME need to implement
                proc => sub {
                    # no colons = a plain list of files
                    # one pair of colons = a package/file pair list
                    # two or more pairs of colons = a package/file
                    # specification list (file/dev/dir)
                }, # load->proc 
# FIXME move all of the saving/loading of lists to it's own module under FileDb
            }, # list->load
			'save' => {
                desc => q(Saves a list of file dependencies),
                minargs => 1,
                maxargs => 1,
                proc => sub { 
					if ( $filedb->_count_filedb_keys() > 0 ) {
                        # verify the file doesn't exist before you write it
                        my $file = shift;
                        if ( -e $file ) {
							# confirm returns 'undef' if the user chooses 
							# anything but [Yy]
                            return if ( ! &confirm( confirm_warning => 
								qq(File $file exists; Overwrite?),
								prompt => q([Y/n]) ) );
                        } # if ( -e $file )
                        open(LIST, qq(> $file)) 
                            || $logger->logdie(qq(Can't open file $file)
                                . qq( for writing!\n\t$!) );
						foreach ( sort($filedb->_get_filedb_keys()) ) {
							print LIST qq($_\n);
						} # foreach (@{$filedb->_get_filedb_keys()})
                        close LIST;
                    } # if ( $filedb->_count_filedb_keys() > 0 )
                }, # save->proc
            }, # list->save
			'psave' => {
                desc => q(Saves a list of file/package dependency pairs),
                minargs => 1,
                maxargs => 1,
                proc => sub { 
					if ( $filedb->_count_filedb_keys() > 0 ) {
                        # verify the file doesn't exist before you write it
                        my $file = shift;
                        if ( -e $file ) {
							# confirm returns 'undef' if the user chooses 
							# anything but [Yy]
                            return if ( ! &confirm( confirm_warning => 
								qq(File $file exists; Overwrite?),
								prompt => q([Y/n]) ) );
                        } # if ( -e $file )
                        open(LIST, qq(> $file)) 
                            || $logger->logdie(qq(Can't open file $file)
                                . qq( for writing!\n\t$!) );
						foreach ( sort($filedb->_get_filedb_keys()) ) {
							my $package = $filedb->_get_pkg_name($_);
							if ( ! defined $package ) {
								$package = q(<none>);
							} # if ( ! defined $package )
							print LIST $package . q(::) . $_ . qq(\n);
						} # foreach (@{$filedb->_get_filedb_keys()})
                        close LIST;
                    } # if ( $filedb->_count_filedb_keys() > 0 )
                }, # psave->proc
            }, # list->psave
        }, # list->cmds
    }, # list 
	'archive'	=>  { desc => q(Commands to be used with archives of files),
		cmds => {
            'new' => {
                desc => q(Creates/opens an archive),
                proc => sub { # FIXME implement 
                }, # new->proc
            }, # archive->new
            'close' => {
                desc => q(Closes an archive, writing files as needed),
                proc => sub { # FIXME implement 
                }, # close->proc
            }, # archive->close                
        }, # archive->cmds
    }, # archive

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
    warn qq( -gf|--getfiles     file work out dependencies for\n);
    warn qq( -fp|--finkpath     path to Fink install (default: /sw)\n);
    warn qq( -pp|--portspath    path to DarwinPorts install )
        . qq((default: /opt/local)\n);
    warn qq( -nocl|--nocolorlog don't colorize the shell output\n);
    warn qq( -rpp|--rowsperpage number of rows per page of long output\n);
    warn qq( --norecursion      don't follow file dependencies\n);
    warn qq( -of|--outputformat output format of packages\n);
    warn qq( [tarbz2, targz, cramfs, squashfs, par, zip (default)] \n);
	exit 0;
} # sub ShowHelp

package PerlDepShell;
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
	Module::Dependency::Info::dropIndex();
} # sub drop_index

sub load_index_file {
	my $logger = get_logger();
	if ( scalar(@_) == 1 ) {
		# see if the file argument exists/is readable
		if ( -r $_[0] ) {
			Module::Dependency::Indexer::setIndex($_[0]);
		} else {
			$logger->warn(q(File ) . $_[0] . q( not found/not readable));
		} # if ( -r $_[0] )
	} # if ( scalar(@_) == 1 )
} # sub load_index_file

# vi: set ft=perl sw=4 ts=4 cin:
