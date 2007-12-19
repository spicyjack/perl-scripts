#!/usr/bin/env perl

use strict;
use warnings;
# $Id$
# Copyright (c)2001 by Brian Manning
#
# demo of Net::SNMP

# external modules
use Net::SNMP;

# create an SNMP session
my ($snmp_session, $session_error) = Net::SNMP->session(
#-hostname   => shift || q(localhost),
#-community  => shift || q(public),
    -hostname   => shift || q(localhost),
    -community  => shift || q(devilduck),
    -port       => shift || q(161),
    -version    => shift || q(2c),
); # my ($snmp_session, $session_error) = Net->SNMP->session

# verify it was created correctly
if ( ! defined ($snmp_session) ) {
    printf(qq(Error creating SNMP session: %s), $session_error);
    exit 1;
} # if ( ! defined ($snmp_session) )

my $snmpOidString; 
#$snmpOidString = q(SNMPv2-MIB::sysUpTime);
#$snmpOidString = q(.1.3.6.1.2.1.1.3.0); # SNMPv2-MIB::sysUpTime.0
#$snmpOidString = q(.1.3.6.1.2.1.1.4.0); # SNMPv2-MIB::sysContact.0 
#$snmpOidString = q(.1.3.6.1.4.1.2021.8.1.101.1); # UCD-SNMP-MIB::extOutput.1
$snmpOidString = q(.1.3.6.1.2.1.25.2.2.0); # HOST-RESOURCES-MIB::hrMemorySize.0
my $result = $snmp_session->get_request(-varbindlist => [$snmpOidString]);

if ( ! defined ($result) ) {
    printf(qq(Error getting %s: %s\n), $snmpOidString, $snmp_session->error);
    $snmp_session->close;
    exit 1;
} # if ( ! defined ($result) ) 

printf(qq($snmpOidString for host '%s' is %s\n), $snmp_session->hostname(),
    $result->{$snmpOidString});

$snmp_session->close;

exit 0;

# vi: set ft=perl sw=4 ts=4 cin:
# EOL
