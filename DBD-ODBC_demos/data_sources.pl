use strict;
use DBI;
my @dsns = DBI->data_sources('ODBC');
foreach my $d (@dsns)
{
  print "$d\n";
}
