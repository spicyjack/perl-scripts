#!/usr/bin/env perl

# $Id$
# borrowed from the Net::SNMP Perl POD page
#
# demo of SNMP::Translate

# external modules
use lib qw(../../SNMP-Translate/lib);
use SNMP::Translate;

# create an SNMP session
# .1.3.6.1.2.1.1.3.0 SNMPv2-MIB::sysUpTime.0
#my $rosetta = SNMP::Translate->new( oid => q(.1.3.6.1.2.1.1.3),
my $rosetta = SNMP::Translate->new( 
    #binpaths => [ q(/opt/local/bin), q(/usr/bin) ],
    binpaths => [ q(/usr/bin), q(/opt/local/bin) ],
    #oid => q(.1.3.6.1.2.1.1.3),
    oid => q(SNMPv2-MIB::sysUpTime),
    debug => 1 
);
$rosetta->translate();

exit 0;

# vi: set ft=perl sw=4 ts=4 cin:
# EOL
