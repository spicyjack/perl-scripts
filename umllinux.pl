#!/usr/bin/perl -W

# external modules and compiler directives
use Getopt::Long;
use Pod::Usage;
use strict;

# script-wide variables
# command line options
my (%ubd, %console, $memsize, $uml_id, $singleuser, $append, $umlbin);

# script defaults
# always start a UML session with more than 32M
my $minmem = 32;
# UML binary to use, can be overridden from the command line
my $umlbinary = "/usr/local/src/antlinux/uml/linux";

# begin
# get command line options
&GetOptions('h' => \&ShowHelp, 'help' => \&ShowHelp, 
            'longhelp' => \&ShowHelp, 
            'debug' => \$DEBUG, 'd' => \$DEBUG,
			'ubd=i' => \%ubd, 'u=i' => \%ubd, 
            'mem=i' => \$memsize, 'm=i' => \$memsize,
            'con=s' => \%console, 'c=s' => \%console,
            'umid=s' => \$uml_id, 'i=s' => \$uml_id,
            'single' => \$singleuser, 's' => \$singleuser,
            'append=s' => \$append, 
            'umlbin=s' => \$umlbin, 'x=s' => $umlbin,
            'base=s' => \$umlbase, 'b=s' => $umlbase,
            );

#/usr/local/src/antlinux/uml/linux \
#mem=128m umid=initrd con=pty con0=fd:0,fd:1 con1=port:8998 con2=port:8999 \
#ubd2=/usr/local/src/antlinux/uml/Debian-3.0r0.ext2 \
#ubd1=/usr/local/src/antlinux/bf-uml/initrd \
#ubd0=/usr/local/src/antlinux/sid-base.img single

	# check for the UML binary
    # FIXME change the paths below to use $umlbinary
	if ( ! -x $umlbin ) {
        if ( -x "/usr/local/src/antlinux/uml/linux" ) {
            $umlbin = "/usr/local/src/antlinux/uml/linux"; 
        } else {
    		die "Error: no UML binary defined; use --umlbin <UML binary>\n>";
	} # if ( ! -x $umlbin )

# before we can start a UML session, we need:
# - uml binary (checked above)
# - at least one uml disk device
#
# optional:
# - additional uml disk devices
# - uml console devices (network or serial)
# - uml session ID
# - memory for UML session
# - networking
# - kernel options such as single user mode and/or other appended options
# end main script

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

# Links to related documents
# http://www.tldp.org/HOWTO/IP-Alias/commands.html
# http://www.knowplace.org/shaper/requirements.html#compiling
# http://iptables-tutorial.frozentux.net/chunkyhtml/index.html
# http://pingu.salk.edu/LDP/HOWTO/Adv-Routing-HOWTO/lartc.adv-filter.html
