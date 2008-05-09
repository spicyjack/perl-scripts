#!/usr/bin/env perl

use strict;
use warnings;
# $Id$
# borrowed from the Net::SNMP Perl POD page
#
# demo of Net::SNMP get_bulk_request()

# external modules
# need to import :snmp to get the functions oid_lex_sort and oid_base_match
use Net::SNMP qw(:snmp);

# create an SNMP session
my ($snmp_session, $session_error) = Net::SNMP->session(
#-hostname   => shift || q(localhost),
#-community  => shift || q(public),
    -hostname       => shift || q(nob),
    -community      => shift || q(SkinnyRO),
    -port           => shift || q(161),
    -version        => shift || q(2c),
    -nonblocking    => 1,
); # my ($snmp_session, $session_error) = Net->SNMP->session

# verify it was created correctly
if ( ! defined ($snmp_session) ) {
    printf(qq(Error creating SNMP session: %s), $session_error);
    exit 1;
} # if ( ! defined ($snmp_session) )

my $snmpOidString; 
# external command output
#$snmpOidString = q(.1.3.6.1.4.1.2021.8.1.101.1); # UCD-SNMP-MIB::extOutput.1
# OID's internal to snmpd
#$snmpOidString = q(SNMPv2-MIB::sysUpTime);
#$snmpOidString = q(.1.3.6.1.2.1.1.3.0); # SNMPv2-MIB::sysUpTime.0
#$snmpOidString = q(.1.3.6.1.2.1.1.4.0); # SNMPv2-MIB::sysContact.0 
#$snmpOidString = q(.1.3.6.1.2.1.25.2.2.0); # HOST-RESOURCES-MIB::hrMemorySize.0
$snmpOidString = q(1.3.6.1.2.1.25.2); # HOST-RESOURCES-MIB::hrStorage
#$snmpOidString = q(1.3.6.1.2.1.2.2); IF-MIB::ifTable

my $result = $snmp_session->get_bulk_request(
    -callback       => [\&table_callback, {}],
    -maxrepetitions => 10,
    -varbindlist    => [$snmpOidString],
); # my $result = $snmp_session->get_bulk_request

if ( ! defined ($result) ) {
    printf(qq(Error getting %s: %s\n), $snmpOidString, $snmp_session->error);
    $snmp_session->close;
    exit 1;
} # if ( ! defined ($result) ) 

$snmp_session->snmp_dispatcher();

$snmp_session->close;
exit 0;

sub table_callback {
    my ($snmp_session, $table) = @_;

    if (!defined($snmp_session->var_bind_list)) {
        printf("ERROR: %s\n", $snmp_session->error);   
    } else {

        # Loop through each of the OIDs in the response and assign
        # the key/value pairs to the anonymous hash that is passed
        # to the callback.  Make sure that we are still in the table
        # before assigning the key/values.

        my ($next, $oid);

        # oid_lex_sort: returns a list of OID's sorted lexographically
        # oid_base_match: compares two OID's, returns true if the second OID
        # is the same as or a child of the first OID
        foreach $oid (oid_lex_sort(keys(%{$snmp_session->var_bind_list}))) {
            if (!oid_base_match($snmpOidString, $oid)) {
                $next = undef;
                last;
            } # if (!oid_base_match($snmpOidString, $oid))
            $next = $oid; 
            $table->{$oid} = $snmp_session->var_bind_list->{$oid};   
        } # foreach my $oid (oid_lex_sort(keys(%{$snmp_session->var_bind_list})

         # If $next is defined we need to send another request 
         # to get more of the table.

        if (defined($next)) {
            $result = $snmp_session->get_bulk_request(
                -callback       => [\&table_callback, $table],
                -maxrepetitions => 10,
                -varbindlist    => [$next]
            ); 

            if (!defined($result)) {
               printf("ERROR: %s\n", $snmp_session->error);
            }
        } else {
            # We are no longer in the table, so print the results.
            foreach $oid (oid_lex_sort(keys(%{$table}))) {
               printf("%s => %s\n", $oid, $table->{$oid});
            } 
        } # if (defined($next))
    } # if (!defined($snmp_session->var_bind_list))
} # sub table_callback

# vi: set ft=perl sw=4 ts=4 cin:
# EOL
