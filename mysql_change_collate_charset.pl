#!/usr/bin/perl

use strict;
use warnings;
use DBI;
use 5.010;

# Grab a handle to the database
# - We won't use "statement handles" here, what we're doing here is pretty
# simple stuff as far as the database is concerned
my $dbh = DBI->connect("DBI:mysql:database=foo_db;"
                        . "host=somehost.example.com",
                        "username",
                        "password",
                        {'RaiseError' => 1});

# get a list of all tables with 'SHOW TABLES'
foreach my $array_r ( $dbh->selectall_array(q(SHOW TABLES)) ) {
   my $table = $$array_r[0];
   say "Altering table: $table";
   # ALTER TABLE to change charset/collation
   my $sql = qq(ALTER TABLE `$table` )
            . q(CONVERT TO CHARACTER SET utf8 )
            . q(COLLATE utf8_general_ci);
   $dbh->do($sql);
   # sleep a bit so as to not hammer the server
   sleep 2;
}

# Disconnect from the database.
$dbh->disconnect();
