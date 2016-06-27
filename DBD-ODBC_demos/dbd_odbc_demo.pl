#!/usr/bin/env perl

use strict;
use warnings;
use 5.010;

use Data::Dumper;
$Data::Dumper::Indent = 1;
$Data::Dumper::Sortkeys = 1;
$Data::Dumper::Terse = 1;
use DBI;
use Try::Tiny;

  my $dbh;
  my $db_dsn = q(dbi:ODBC:Service);

     $dbh = DBI->connect(
      $db_dsn,
      undef,
      undef,
      { RaiseError => 1, PrintError => 1} )
      || die qq|Can't connect to 'Service' table: $_ (DSN: $db_dsn)|;

  my $sql = <<'EOSQL';
        SELECT RONumber, TransactionStatus
          FROM ROHeader
          WHERE TransactionStatus = 'R'
          ORDER BY RONumber DESC
EOSQL


  my @row;
  try {
    @row = $dbh->selectrow_array($sql);
  } catch {
    warn(qq(Database query failed; $_));
  };

  # get the first element from the returned array, the RONumber
  if ( ! defined($row[0]) ) { $row[0] = 0; }
  say q( Last repair order number: ) . $row[0];

  my $header_sql;
    $header_sql = <<"EOHEADER_SQLITE";
    SELECT ROHeaderID, RONumber, CustomerID, CustomerName, InDate, InTime,
        TransactionStatus
      FROM ROHeader
      WHERE TransactionStatus = 'R'
      ORDER BY RONumber DESC LIMIT 10
EOHEADER_SQLITE

  #$log->debug(q(Header SQL query is:));
  my $no_nl_sql = $header_sql;
  $no_nl_sql =~ s/\n/ /g;
  $no_nl_sql =~ s/\s+/ /g;
  say $no_nl_sql;

  my $sth = $dbh->prepare($sql);
  my @db_rows;
  try {
    $sth->execute();
    while (my $row_ref = $sth->fetchrow_hashref ) {
      push(@db_rows, $row_ref);
    }
  } catch {
    warn(qq(- Database query failed; $_));
  };

  print Dumper @db_rows;
  print qq(\n);
  exit 0;

  my @return_rows;
  foreach my $header_row ( @db_rows ) {
    my $units_sql = <<'EOUNITS_BASE';
     SELECT ROHeaderID, Year, Make, Model, Color
        FROM ROUnits
        WHERE ROHeaderID =
EOUNITS_BASE

    $units_sql .= $header_row->{ROHeaderID};
    $no_nl_sql = $units_sql;
    $no_nl_sql =~ s/\n/ /g;
    $no_nl_sql =~ s/\s+/ /g;
    say q(Units query: ) . $no_nl_sql;

    try {
      $sth->execute();
      while (my $row_ref = $sth->fetchrow_hashref ) {
        push(@db_rows, $row_ref);
      }
    } catch {
      warn(qq(- Database query failed; $_));
    };
  }


  # vim: tabstop=2 shiftwidth=2
