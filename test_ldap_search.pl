#!/usr/bin/perl

use strict;
use warnings;

use Net::LDAP;
#use Term::ReadKey;

# exit if no name was passed in
if ( scalar(@ARGV) == 0 ) {
    die qq(Usage: $0 name_to_search_for\n);
}

my $username = $ARGV[0];

#my $username = q(bogususer);
#my $ldap = Net::LDAP->new ( "test.example.com", debug => 3 ) or die "$@";
#my $ldap = Net::LDAP->new ( "test.example.com" ) or die "$@";
my $ldap = Net::LDAP->new ( "edir-sd.qualcomm.com" ) or die "$@";
#ReadMode("noecho");
#print "Enter the LDAP password: ";
#my $passwd = ReadLine(0);
#ReadMode("restore");
#chomp $passwd;
#print qq(\n);

my $mesg = $ldap->bind (
#    "cn=$username,ou=Users,ou=San Diego,dc=na,dc=example,dc=com",
#    password => "$passwd",
#    base => 'o=example',
#    version => 3
); # use version 3 for changes/edits

#if ( defined $mesg ) { print $mesg . qq(\n); }

#$my $base = "ou=San Diego,dc=na,dc=example,dc=com";
my $base = "o=qualcomm";
my $filter = "(|(cn=$username))";
my $attrs = "cn email sn givenName";

my $result = $ldap->search (
    base    => "$base",
    scope   => "sub",
    filter  => "$filter",
    attrs   =>  $attrs
);

print qq(Net::LDAP query for user $username returned )
    . $result->count() . qq( results\n);

foreach my $record ( $result->entries() ) {
    #print qq(Attributes for this record are:\n);
    #print join(q(, ), $record->attributes()) . qq(\n);
    # dump the record out
    $record->dump();
} # foreach my $record ( $result->entries() )

$ldap->unbind;
