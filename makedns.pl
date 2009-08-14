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
my $serial_file = q(/tmp/dns_serial.txt);
my $serial;
if ( -r $serial_file ) {
    $serial = qx#/bin/cat $serial_file | tr -d '\n'#;
    $serial++;
} else {
    $serial = 1;    
}
# write the serial to the tempfile
qx#echo $serial > $serial_file#;
# build up the complete serial number now
my $date_command = q(/bin/date +%Y%m%d);
my $date_serial = qx/$date_command | tr -d '\n'/;

%dnsinfo = (	
                # serial number
                serial => $date_serial . sprintf('%02d', $serial),
				refresh => "3H", # refresh
				retry => "45M", # how often to retry when initial try fails
				expire => "8D", # max time to cache the zone
				ttl => "3D", # minimum time to live
			);

# set up @ns
@ns = ("naranja", "lagrange");

# set up @mx
@mx = ("10 smtp"); # on hosts that use it, mail is a CNAME to lagrange

# a list of domains to generate zones for 
# the 'public' key is to specify if that host gets all of the funky hostnames
# I use, or if it gets just a basic set that covers all of the services...
%domains = (	
				"portaboom.com"				=> { 	internal => "n",
													primary => "lagrange"},
                "antlinux.com"              => {    internal => 'n',
				                                    primary => 'lagrange'},
                "tennsat.com"               => {    internal => "n",
                                                    primary => "lagrange"},
                "tiedyelady.com"            => {    internal => "n",
                                                    primary => "lagrange"},
                "erolotus.com"              => {    internal => "n",
                                                    primary => "lagrange"},
                "hobartrax.com"             => {    internal => "n",
                                                    primary => "lagrange"},
                "blkmtnpub.com"             => {    internal => "n",
                                                    primary => "lagrange"},
                "blkmtnconsult.com"         => {    internal => "n",
                                                    primary => "lagrange"},
                "spicyjack.com"             => {    internal => "n",
                                                    primary => "lagrange"},
                "streambake.com"            => {    internal => "n",
                                                    primary => "lagrange"},
                "srdrive4life.com"          => {    internal => "n",
                                                    primary => "lagrange"},
                "srdrive4life.org"          => {    internal => "n",
                                                    primary => "lagrange"},
			);

%hosts = (	
    "localhost"	=> { 	ip => "127.0.0.1",
	                    public => "y"},
    "android"	=> { 	alias => "lagrange",
                        public => "y"},
    "calavera" 	=> {	ip => "76.88.101.33",
                        public => "y"},
    "cosas"     => {    alias => "lagrange",
                        public => "y"},
    "cvs"       => {    alias => "calavera",
                        public => "y"},
    "dbx"       => {    alias => "lagrange",
                        public => "y"},
    "db"        => {    alias => "calavera",
                        public => "y"},
    "dev"       => {    alias => "lagrange",
                        public => "y"},
#   "dropbox"   => {    ip => "calavera",
#                       public => "y"},
    "files"     => {    ip => "127.0.0.1",
                        public => "y"},
    "gallery"   => {    alias => "calavera",
                        public => "y"},
    "hg"        => {    alias => "bitbucket.org.",
                        public => "y"},
    "lagrange" 	=> {	ip => "65.49.60.55",
                        public => "y"},
    "mail"		=> { 	alias => "localhost",
                        public => "y"},
    "naranja"  	=> { 	ip => "63.198.132.114",
                        public => "y"},
    "purl" 	    => {	ip => "65.49.60.56",
                        public => "y"},
    "shell" 	=> {	alias => "lagrange",
                        public => "y"},
    "smtp" 		=> {	alias => "localhost",
                        public => "y"},
    "stream" 	=> {	alias => "lagrange",
                        public => "y"},
    "vend"      => {    alias => "lagrange",
                        public => "y"},
    "wiki"      => {    alias => "lagrange",
                        public => "y"},
    "www"		=> {	alias => "lagrange",
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
foreach $domain ( sort(keys(%domains)) ) {
	# where are we writing data to?
	if ( defined $DEBUG ) {
		warn "makedns: output will go to the screen instead of to files\n";
		$OUT = *STDERR;
	} else {
		open(FH, q(> ) . $domain . q(.dns) );
		$OUT = *FH;
	} # if ( defined $DEBUG )

	# write the domain header info to the filehandle
	print $OUT ";\n";
	print $OUT "; Zone record file for $domain\n";
	print $OUT "; created on $date\n";
	print $OUT ";\n\n";
	print $OUT "\$TTL 3D\n\n";
    if ( $domain eq q(portaboom.com) ) {
        print $OUT q($GENERATE 10-80 ${0,2,x}011bac A 172.27.1.$) . qq(\n);
    } # if ( $domain eq q(antlinux.com) )
	print $OUT '@ IN SOA naranja.' . "$domain. $soa_email.$domain. (" . qq(\n);
	print $OUT spaceify(4, 15, $dnsinfo{serial}) . "; zone serial\n";
	print $OUT spaceify(4, 15, $dnsinfo{refresh}) . "; refresh\n";
	print $OUT spaceify(4, 15, $dnsinfo{retry}) . "; how often to retry\n";
	print $OUT spaceify(4, 15, $dnsinfo{expire}) . "; max time to cache zone\n";
	print $OUT spaceify(4, 15, $dnsinfo{ttl}) . "; minimum time to live\n";
	print $OUT ")\n\n";

	# print the MX and NS records
	print $OUT "; print the MX and NS records\n";
	print $OUT spaceify(4, 15, "NS " . $ns[0]) . "\n";	
	print $OUT spaceify(4, 15, "NS " . $ns[1]) . "\n";	
	print $OUT spaceify(4, 15, "MX " . $mx[0]) . "\n\n";	

	# print a host record for the FQDN
	print $OUT "; print a host record for the FQDN\n";
	print $OUT spaceify(0, 20, $domain . q(.)) . q(IN A ) 
        . $hosts{$domains{$domain}{primary}}{ip} . "\n\n";

	print $OUT "; print the other host records for this zone\n";
	# loop thru the hosts
	foreach $host ( sort(keys(%hosts)) ) {
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
        print $OUT qq(; vi: set filetype=dns :\n);
		close ($OUT);
	} # if ( defined $DEBUG )
} # foreach $domain ( keys(%domains) )

#############
# spaceify  #
#############
sub spaceify {
    my $leading_space = shift;
    my $field_width = shift;
    my $string_data = shift;
    # take the width of the field, subtract the length of the string
    # print that many spaces
    return q( ) x $leading_space . $string_data 
        . q( ) x ($field_width - length($string_data) );
} # sub GetRecord

#############
# GetRecord #
#############
sub GetRecord {
# extracts specific record info from the hashes
	my $hosts_ref = $_[0]; # reference to hosts hash
	my $host = $_[1]; # host value to look at
	my $returnval; # what's going back

    my %hosts = %{$hosts_ref};
	if ( exists $hosts{$host}{ip} ) {
		# this is an A record
		$returnval = spaceify(0, 20, $host)
            . "IN A " . $hosts{$host}{ip} . "\n";
	} elsif ( exists $hosts{$host}{alias} ) {
		$returnval = spaceify(0, 20, $host) 
            . "IN CNAME " . $hosts{$host}{alias} . "\n";	
    } else {
		die "makedns: ip or alias not found";
	} # if ( exists $hosts{$host}{ip} )
	
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

# vi: set ft=perl sw=4 ts=4:
