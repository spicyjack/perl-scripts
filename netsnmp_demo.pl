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
my ($snmp_session, $session_error) = Net->SNMP->session(
    -hostname   => shift || q(localhost),
    -community  => shift || q(public),
    -port       => shift || q(161),
); # my ($snmp_session, $session_error) = Net->SNMP->session

# verify it was created correctly
if ( ! defined ($snmp_session) ) {
    printf(qq(Error creating SNMP session: %s), $session_error);
    exit 1;
} # if ( ! defined ($snmp_session) )

my $sysUpTime = q(SNMPv2-MIB::sysUpTime);

my $result = $snmp_session->get_request(-varbindlist => [$sysUpTime]);

if ( ! defined ($result) ) {
    printf(qq(Error getting %s: %s\n", $sysUpTime, $snmp_session->error));
    $snmp_session->close;
    exit 1;
} # if ( ! defined ($result) ) 

# vi: set ft=perl sw=4 ts=4 cin:
# end of line
1;

