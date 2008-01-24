#!/usr/bin/env perl

# $Id$
# borrowed from the Net::SNMP Perl POD page
#
# demo of SNMP::Translate

# external modules
use lib qw(../../SNMP-Translate/lib);
use SNMP::Translate;

# create an SNMP session
my $rosetta = SNMP::Translate->new( oid => q(.1.3.6.1.2.1.1.3),
                                    binpaths => [ q(/usr/bin) ],
                                    debug => 1 );

$rosetta->init();
$rosetta->translate();

exit 0;

# vi: set ft=perl sw=4 ts=4 cin:
# EOL
