#!/usr/bin/perl

use strict;
use warnings;

use Net::LDAP;
use Term::ReadKey;

#my $username = q(bogususer);
my $username = q(bmanning);
#my $ldap = Net::LDAP->new ( "na.qualcomm.com", debug => 3 ) or die "$@";
my $ldap = Net::LDAP->new ( "na.qualcomm.com" ) or die "$@";
#my $ldap = Net::LDAP->new ( "directory.qualcomm.com" ) or die "$@";
ReadMode("noecho");
print "Enter the LDAP password: ";
my $passwd = ReadLine(0);
ReadMode("restore");
chomp $passwd;
print qq(\n);

my $mesg = $ldap->bind (
    "cn=$username,ou=Users,ou=San Diego,dc=na,dc=qualcomm,dc=com",
    password => "$passwd",
    version => 3
); # use version 3 for changes/edits

if ( defined $mesg ) { print $mesg . qq(\n); }

my $base = "ou=San Diego,dc=na,dc=qualcomm,dc=com";
my $filter = "(|(cn=$username))";
my $attrs = "cn";

my $result = $ldap->search (
    base    => "$base",
    scope   => "sub",
    filter  => "$filter",
    attrs   =>  $attrs
);

print qq(Net::LDAP query for user $username returned )
    . $result->count() . qq( results\n);

foreach my $record ( $result->entries() ) {
    print qq(Attributes for this record are:\n);
    print join(q(, ), $record->attributes()) . qq(\n);
    # dump the record out
    #$record->dump();
}

$ldap->unbind;
