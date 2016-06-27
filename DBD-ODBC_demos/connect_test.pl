use strict;
use Data::Dumper;
use DBI;

my $dbh = DBI-> connect('dbi:ODBC:Service', undef, undef,
   {PrintError => 0, RaiseError =>0});

if (!$dbh)
{
  print "$DBI::err\n$DBI::errstr\n$DBI::state";
}
else
{
  print join(q( ), $dbh->data_sources()) . qq(\n);
  my $sth = $dbh->table_info();
  my $ref = $sth->fetchrow_hashref();
  print Dumper $ref;
  $sth->finish;
  $dbh->disconnect if ($dbh);
}
