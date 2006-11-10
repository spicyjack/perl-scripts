#!/usr/bin/perl -w

# makedns.pl
# (c)2002 Brian Manning
#
# A DNS forward zone file generator

#   This program is free software; you can redistribute it and/or modify
#   it under the terms of the GNU General Public License as published by
#   the Free Software Foundation; version 2 dated June, 1991.
#
#   This program is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU General Public License for more details.
#
#   You should have received a copy of the GNU General Public License
#   along with this program;  if not, write to the Free Software
#   Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111, USA.

# compiler declarations
use strict;
use Getopt::Std; # parsing command line switches

# constants
my $DEBUG; # are we debugging?
my %domains; # a list of domains we'll be generating zones for
my %hosts; # record of hosts, some will be used with all domains, others won't
my %dnsinfo; # other constants that make up a DNS zone file
my @ns; # list of nameservers
my @mx; # list of mail exchange servers
my $soa_email = "dns"; # soa e-mail address
my %opts; # hash for command line options
&getopts("dh", \%opts); # go get the command line options

if ( exists $opts{h} ) {
    warn "\n-- $0 --\n";
    warn "Options:\n";
    warn "-h:  shows this help text\n";
    warn "-d:  debug, print to screen instead of file\n";
    exit 0;
} # if ( exists $opts{h} )

# set up %dnsinfo
# FIXME automate the serial number
%dnsinfo = (	serial => "2006091201", # serial number
				refresh => "3H", # refresh
				retry => "45M", # how often to retry when initial try fails
				expire => "8D", # max time to cache the zone
				ttl => "3D", # minimum time to live
			);

# set up @ns
@ns = ("naranja", "observer");

# set up @mx
@mx = ("10 smtp"); # on hosts that use it, mail is a CNAME to observer

# a list of domains to generate zones for 
# the 'public' key is to specify if that host gets all of the funky hostnames
# I use, or if it gets just a basic set that covers all of the services...
%domains = (	
				"portaboom.com"				=> { 	internal => "n",
													primary => "observer"},
				"portaboom.org"				=> { 	internal => "n",
													primary => "observer"},
                "antlinux.com"              => {    internal => 'n',
				                                    primary => 'observer'},
			);

%hosts = (	"localhost"	=> { 	ip => "127.0.0.1",
								public => "y"},
			"observer" 	=> {	ip => "72.14.141.184",
								public => "y"},
			"naranja"  	=> { 	ip => "63.198.132.114",
								public => "y"},
			"mail"		=> { 	alias => "observer",
								public => "y"},
			"www"		=> {	alias => "observer",
								public => "y"},
			"dns"		=> {	alias => "naranja",
								public => "y"},
			"kpri"		=> {	alias => "observer",
								public => "y"},
			"smtp" 		=> {	ip => "72.14.141.184",
								public => "y"},
			"sf" 		=> {	ip => "66.35.250.210",
								public => "y"},
            "portaboom" => {    alias => "observer",
                                public => "y"},
            "anywipe"   => {    alias => "observer",
                                public => "y"},
            "anyshell"  => {    alias => "observer",
                                public => "y"},
            "quickmap"  => {    alias => "observer",
                                public => "y"},
            "ff"        => {    alias => "observer",
                                public => "y"},
            "foto"      => {    alias => "observer",
                                public => "y"},
            "files"     => {    alias => "observer",
                                public => "y"},
            "gallery"   => {    alias => "observer",
                                public => "y"},
            "streamcast" => {   alias => "observer",
                                public => "y"},
            "vend"      => {   alias => "observer",
                                public => "y"},
            "wiki"      => {   alias => "observer",
                                public => "y"},
            "propaganda" => {   alias => "observer",
                                public => "y"},
            "dev" =>        {   alias => "observer",
                                public => "y"},
            "cvs" =>        {   alias => "observer",
                                public => "y"},

); # %hosts		
							
# are we running in DEBUG mode 
if ( exists $opts{d} ) {
    $DEBUG = 1;
} # if ( $opts{d} )

# variables
my $host; # a host from the hash
my $domain; # a domain from the hash
my $OUT; # pointer to the output file handle
my $date = `/bin/date`;
my $tmp; # for reading input
chomp($date);

# loop thru the domains
foreach $domain ( keys(%domains) ) {
	# where are we writing data to?
	if ( defined $DEBUG ) {
		warn "makedns: output will go to the screen instead of to files\n";
		$OUT = *STDERR;
	} else {
		open(FH, ">$domain.dns");
		$OUT = *FH;
	} # if ( defined $DEBUG )

	# write the domain header info to the filehandle
	print $OUT ";\n";
	print $OUT "; Zone record file for $domain\n";
	print $OUT "; created on $date\n";
	print $OUT ";\n\n";
	print $OUT "\$TTL 7D\n\n";
    if ( $domain eq q(antlinux.com) ) {
        print $OUT q($GENERATE 10-80 ${0,2,x}011bac A 172.27.1.$) . qq(\n);
    } # if ( $domain eq q(antlinux.com) )
	print $OUT '@ IN SOA naranja.$domain. $soa_email.$domain. (' . qq(\n);
	print $OUT "\t\t" . $dnsinfo{serial} . "\t; zone serial\n";
	print $OUT "\t\t" . $dnsinfo{refresh} . "\t\t\t; refresh\n";
	print $OUT "\t\t" . $dnsinfo{retry} . "\t\t\t; how often to retry\n";
	print $OUT "\t\t" . $dnsinfo{expire} . "\t\t\t; max time to cache zone\n";
	print $OUT "\t\t" . $dnsinfo{ttl} . "\t\t\t; minimum time to live\n";
	print $OUT ")\n\n";

	# print the MX and NS records
	print $OUT "; print the MX and NS records\n";
	print $OUT "\t\tNS " . $ns[0] . "\n";	
	print $OUT "\t\tNS " . $ns[1] . "\n";	
	print $OUT "\t\tMX " . $mx[0] . "\n\n";	

	# print a host record for the FQDN
	print $OUT "; print a host record for the FQDN\n";
	print $OUT "$domain.\t\t\t\tIN A " . $hosts{$domains{$domain}{primary}}{ip} 		. "\n\n";

	print $OUT "; print the other host records for this zone\n";
	# loop thru the hosts
	foreach $host ( keys(%hosts) ) {
		# is the host record meant for the public?
		if ( $hosts{$host}{public} eq "n" ) { 
			# no, it's internal, is this an internal domain?
			if ( $domains{$domain}{internal} eq "y" ) {
				# yes, format and print the record
				print $OUT &GetRecord(\%hosts, $host);
			} # if ( $domains{$domain}{internal} == "y" )
		} else {
			# this is a public record, so it should be printed regardless
			print $OUT &GetRecord(\%hosts, $host);
		} # if ( $hosts{$host}{public} == "n" )
	} # foreach $host ( keys(%hosts) )
	if ( defined $DEBUG ) {
		warn "makedns: end of host record\n";
		warn "makedns: hit <ENTER> to continue\n";
		$tmp = <STDIN>;
		undef $tmp;
	} else {
		close ($OUT);
	} # if ( defined $DEBUG )
} # foreach $domain ( keys(%domains) )

#############
# GetRecord #
#############
sub GetRecord {
# extracts specific record info from the hashes
	my $hosts = $_[0]; # reference to hosts hash
	my $host = $_[1]; # host value to look at
	my $returnval; # what's going back

	if ( exists $$hosts{$host}{ip} ) {
		# this is an A record
		$returnval = $host . "\t\t\t\tIN A " . $$hosts{$host}{ip} . "\n";
	} elsif ( exists $$hosts{$host}{alias} ) {
		$returnval = $host . "\t\t\t\tIN CNAME " . $$hosts{$host}{alias} . "\n";	} else {
		die "makedns: ip or alias not found";
	} # if ( exists $$hosts{$host}{ip} )
	
	# exit returning the return value
	return $returnval;
} # sub GetRecord 

# pseudocode
# loop thru the domains
# for each domains:
# 	open a file named $domain.dns
# 	write the domain header info
# 	loop thru the hosts
# 	for each host:
# 		check to see if it's public
# 		if it is, check for an IP or alias, and write out the appropriate text
