#!/usr/bin/perl -W

# Copyright (c)2004 Brian Manning
# brian (at) antlinux dot com

# runs an instance of User Mode Linux, based on the option switches passed into
# the script

# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307 USA 

# external modules and compiler directives
use Getopt::Long;
use Pod::Usage;
use strict;

### script-wide variables ###
my ($DEBUG, $umlcmd);
# command line options
my (%disk, %console, $memsize, $umlid, $singleuser, $append, $umlbin, $umlbase);

# script defaults
# always start a UML session with more than 32M
my $minmem = 32;
# UML binary to use, can be overridden from the command line
my $umlbinarylocation = "/usr/local/src/antlinux/uml/linux";

# command line options
my (%ubd, %eth, %console);
my ($DEBUG, $memsize, $uml_id, $singleuser, $append, $umlbin, $umlbase);

### begin ###
# get command line options
&GetOptions('h' => \&ShowHelp, 'help' => \&ShowHelp, 
        'longhelp' => \&ShowHelp, 
        'debug' => \$DEBUG, 'D' => \$DEBUG,
        'disk=s' => \%ubd, 'd=s' => \%ubd, # UML Disks
        'eth=s' => \%eth, 'e=s' => \%eth, # UML ethernet devices
        'con=s' => \%console, 'c=s' => \%console, # UML console devices
        'mem=i' => \$memsize, 'm=i' => \$memsize, # UML memory size
        'umid=s' => \$uml_id, 'i=s' => \$uml_id, # UML ID for uml_mconsole
        'single' => \$singleuser, 's' => \$singleuser, # start VM in single
        'append=s' => \$append,  # append strings for the UML kernel
        'umlbin=s' => \$umlbin, 'x=s' => $umlbin, # path to UML binary
        'base=s' => \$umlbase, 'b=s' => $umlbase, # base path to UML files
        );

# FIXME add a check for $umlbase here and in the file tests below; if it
# exists, it changes all of the below paths

# FIXME use --con for console and --ssl for serial console.  See
# http://user-mode-linux.sourceforge.net/input.html for more information on how
# each style of console works

#/usr/local/src/antlinux/uml/linux \
#mem=128m umid=initrd con=pty con0=fd:0,fd:1 con1=port:8998 con2=port:8999 \
#ubd2=/usr/local/src/antlinux/uml/Debian-3.0r0.ext2 \
#ubd1=/usr/local/src/antlinux/bf-uml/initrd \
#ubd0=/usr/local/src/antlinux/sid-base.img single

# before we can start a UML session, we need:
# - uml binary (checked above)
# - at least one uml disk device
# optional:
# - additional uml disk devices
# - uml console devices (network or serial)
# - uml session ID
# - memory for UML session
# - networking
# - kernel options such as single user mode and/or other appended options
    
    # FIXME double check the below section, it got caught in a merging conflict
	# check for the UML binary
	if ( ! -x $umlbin ) {
        if ( -x "/usr/local/src/antlinux/uml/linux" ) {
            $umlbin = "/usr/local/src/antlinux/uml/linux"; 
        } else {
    		die "ERROR: Can't find UML binary, or UML binary not executable.\n" 
                . "Use --umlbin <UML binary> to specify correct UML binary\n>";
	} # if ( ! -x $umlbin )


	# check for one or more block devices
	if ( keys(%ubd) == 0 ) {
        die "ERROR: No UML block devices specified.\n" 
            . "Use --ubd <device #>=<block file> to specify device ID "
            . "and block device file\n"
            . "A 'block file' can be a file formatted with a valid "
            . "filesystem\n, or an ISO image file.\n";
    } else {
        foreach 
	} # if ( ! -x $umlbin )

	# check for the UML binary
	if ( ! -x $umlbin ) {
        # if it doesn't exist, check to see if the hardcoded binary is there
        if ( -x $umlbinarylocation ) {
            # yes, use it
            $umlbin = $umlbinarylocation; 
        } else {
            # no, exit
    		die "ERROR: no UML binary defined; use --umlbin <UML binary>\n";
        } # if ( -x $umlbinarylocation )
	} # if ( ! -x $umlbin )
    
    # add the binary to the command line
    $umlcmd = $umlbin;

    # check for the root disk
    if ( ! defined $disk{0} && ! -r $disk{0} ) {
        die "ERROR: UML root disk not defined or not readable;\n" 
            . "use --disk 0=<path to disk image>\n";
    } # if ( ! defined $disk{0} )
    
    # add the root disk
    $umlcmd .= " ubd0=" . $disk{0};

    # check each disk image file to make sure it exists and is readable
    # add disks to the command line that can be read from
    foreach my $file ( sort( keys(%disk) ) ) { 
        if ( ! -r $file ) {
            die "Warning: UML disk image $file not readable\n";
        } else {
            # add the key/disk image to the command line, as long as it's not
            # the 0 disk image (the root disk image already added above)
            if ($file != 0) {
                $umlcmd .= " ubd$file=" . $disk{$file};
            } # if ($file != 0)
        }# if ( ! -r $file )
    } # foreach my $file ( keys{%disk} )
            
    # check for console switch
    # hmm, looks like con=pty gets hosed if you use a hash for keying multiple
    # console switches.  hardcode it???
    $umlcmd .= " con=pty";
    foreach my $confd ( sort ( keys(%console) ) ) {
        # just pass these verbatim.  we trust our users!
        $umlcmd .= " con$confd=" . $console{$confd};
    } # foreach my $confd ( sort ( keys(%console) )

    # check for memory switch
    # check for uml ID switch
    # check for singleuser switch
    
    # run the command
    if ( $DEBUG ) {
        print "command is:\n" . $umlcmd . "\n";
    } else {
        print "command is:\n" . $umlcmd . "\n";
    } # if ( $DEBUG )
    
    exit 0
### fin ###

sub ShowHelp {
# shows the POD documentation (short or long version)
    my $whichhelp = shift;  # retrieve what help message to show 
    shift; # discard the value

    # call pod2usage and have it exit non-zero
    # if if one of the 2 shorthelp options were not used, call longhelp
    if ( ($whichhelp eq q(help))  || ($whichhelp eq q(h)) ) {
        pod2usage(-exitstatus => 1);
    } else {
        pod2usage(-exitstatus => 1, -verbose => 2);
    }
} # sub ShowHelp

__END__
=pod

=head1 NAME

umllinux.pl - starts a User Mode Linux session with specified hard drive images , network connections and console configurations

=head1 SYNOPSIS

umllinux.pl [OPTIONS] 

General Options

  -h|--help	    	Prints a brief help message then exits
  --longhelp		Prints entire help file (including examples)

Block Device Options

  --numsectors		Number of sectors to build traffic shaping rules for

Console Options

  --netmask		Netmask to use for XCore clients

=head1 OVERVIEW

This script will asssist with testing xcore on both the client and server sides
of the xcore session.

On the server side, the script sets up virtual 'sectors' that contain a specified
number of clients per sector.  Each sector is set up using traffic shaping rules so
that it has a default outbound bandwidth limit, and it has a specific number of IP
addresses in that sector for clients to use for making requests of the server. Custom
bandwidth limits can also be specified on a per-sector basis when the script is run
with the B<--sector> option.

On the client side, the script starts multiple XCore clients using a version of the
B<xcore.cfg> file that is customized for each client.  Each XCore client that is
started by the script is started in it's own sub-directory, so that multiple scripts
can be run on one host.  The client sub-directories are named with a hex-encoded
version of that client's IP address.

=head1 GENERAL OPTIONS

=over 

=item B<--help>

Prints a brief help message (script synopis and options), then exits.

=item B<--longhelp>

Prints entire help file to STDERR

=item B<--clients> (Required)

For Traffic Shaping: number of clients per sector to set up for.  For XCore clients:
number of xcore clients to start.

=item B<--ipstart> (Required)

For Traffic Shaping: starting IP address to use for clients.  IP addresses will
be given to the traffic shaping rules created in each sector.  For XCore clients:
starting IP address to use for XCore.  IP addresses will be incremented for
each XCore client that is started.

=back

=head1 TRAFFIC SHAPING OPTIONS

=over

=item B<--numsectors> (Required for Traffic Shaping)

Number of sectors to build traffic shaping rules for.  The number of sectors
multiplied by the number of clients will determine the total number of traffic shaping
rules that the script will create.  Using this option will cause the script to ignore
all script options that have to do with starting XCore clients.

=item B<--sector> (Optional for Traffic Shaping)

Create a custom sector using the notation <SectorID>=<Bandwidth in kilobytes>.  You
can designate multiple sectors as custom sectors, and the bandwidth for those sectors
will be adjusted as specified with this flag.  See the Examples section below for
usage examples.

=item B<--ethdev> (Required for Traffic Shaping)

Ethernet device to create traffic shaping rules on.  This device should
already be configured and running before you try to add traffic shaping rules
to it.

=item B<--bandwidth> (Required for Traffic Shaping)

Default bandwidth (in kilobytes) for all sectors.

=item B<--filterport> (Optional for Traffic Shaping)

Port to use for traffic shaper filtering.  Defaults to port 8088

=back

=head1 TRAFFIC SHAPING EXAMPLES

=over

perl trafficshape.pl --ethdev eth0 --clients 10 --numsectors 5 
--bandwidth 800 --ipstart 192.168.1.1 

perl trafficshape.pl --ethdev eth0 --clients 10 --numsectors 5 
--bandwidth 800 --ipstart 192.168.1.1 --sector 2=1000

perl trafficshape.pl --ethdev eth1 --ipstart 192.168.0.1 --clients 5
--numsectors 3 --sector 1=500 --sector 2=750 --bandwidth 800 

=back

=head1 XCORE CLIENT OPTIONS

=over

=item B<--xcoreclient> (Required for starting XCore clients)

Full path to the Xcore binary that you would like to use for testing.  Using
this option will cause the script to ignore all script options that deal with
Traffic Shaping.

=item B<--netmask> (Required for starting XCore clients)

Netmask of of the the network that the XCore server resides on.  Along with the
B<--gateway> flag below and the B<--ipstart> flag, a 'route' command is run on the
client that sets up the path to the server's network. 

=item B<--gateway> (Required for starting XCore clients)

IP address of the XCore server.  This is used with the B<--ipstart> and B<--netmask>
flags to add a route to the client machine that will enable XCore clients to contact
the server.

=item B<--xcoreconfig> (Required for starting XCore clients)

Full path to the Xcore configuration file to be used by the Xcore clients.
This file will be parsed so that the 'ds_addr' configuration directive is changed to
match the incremented IP address that was passed in using the B<--ipstart> option.

=item B<--xcoreoutdir> (Required for starting XCore clients)

Directory that Xcore clients will use for output.  Individual client sub-directories
will be created below this directory, using the IP address of the server encoded as
hexdecimal for the sub-directory name.

=item B<--xcoresleep> (Optional for starting XCore clients)

Time in seconds to wait between starts of multiple Xcore clients.  Defaults to
one second if nothing is passed in.


=back

=head1 XCORE CLIENT EXAMPLES

=over

perl trafficshape.pl --ipstart 192.168.0.1 --clients 5
--netmask 255.255.255.0 --gateway 10.4.1.1
--xcoreclient /path/to/xcore/client --xcoreoutdir /path/to/outdir 
--xcoresleep 3 --xcoreconfig xcore.cfg.default

=back

=head1 AUTHOR

Brian Manning <bmanning@qualcomm.com>

=cut
