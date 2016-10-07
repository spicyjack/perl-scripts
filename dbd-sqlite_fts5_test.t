#!perl -T

use strict;
use warnings;
use 5.010;

use Test::More;

BEGIN {
   use_ok(q(DBI));
   use_ok(q(DBD::SQLite));
   use_ok(q(Log::Log4perl), qw(:no_extra_logdie_message));
}

my $default_table_count = 2;
# FTS version 4
# my $expected_fts_tables = 7;
# my $expected_fts_return = q(0E0);

# FTS version 5
# NOTE to enable Full-Text Search version 5 in DBD::SQLite, it needs to have
# the flag '­DSQLITE_ENABLE_FTS5' to `@CC_DEFINE` in `Makefile.PL`
my $expected_fts_tables = 6;
my $expected_fts_return = 1;

diag(qq|Testing DBD::SQLite version $DBD::SQLite::VERSION|);
diag(qq(Perl $], $^X" ));

my $log4perl_cfg = <<L4PCFG;
# simple Log::Log4perl configuration for running tests
log4perl.rootLogger = INFO, Screen
log4perl.appender.Screen = Log::Log4perl::Appender::ScreenColoredLevels
log4perl.appender.Screen.stderr = 1
log4perl.appender.Screen.layout = PatternLayout
log4perl.appender.Screen.layout.ConversionPattern = [%6r] %p %m%n
L4PCFG

Log::Log4perl->init(\$log4perl_cfg);
my $log = Log::Log4perl->get_logger();

# :memory: is a special parameter to the DBD::SQLite driver
# https://metacpan.org/module/DBD::SQLite#Database-Name-Is-A-File-Name
# AutoCommit is set to ON to make the database driver create the table
# immediately, so it can be tested later on
my $dbh = DBI->connect(qq(dbi:SQLite:dbname=:memory:), q(), q(),
   {AutoCommit => 1} );
isa_ok($dbh, q(DBI::db));

my @tables = $dbh->tables();
is(scalar(@tables), $default_table_count,
   sprintf(q(Newly created test database has %d default tables),
      $default_table_count)
);
note "Default tables: ";
foreach my $table (@tables) {
   note qq(- $table);
}

my $db_init_sql = <<'DB_INIT';
CREATE VIRTUAL TABLE f USING fts5(x);
-- CREATE VIRTUAL TABLE f USING fts4(x);
INSERT INTO f(rowid, x) VALUES (1, 'A B C D x x x E F x');
DB_INIT

$log->debug(qq(Creating Full-Text search database virtual table));
$log->debug($db_init_sql);
my $result = $dbh->do($db_init_sql);
is($result, $expected_fts_return,
   qq(Initialziation of database returned '$expected_fts_return' value));

# get information about the table(s) after adding FTS virtual table
@tables = $dbh->tables();
# full-text search tables are prepended with an 'f_'
is(scalar(grep(/"f/, @tables)), $expected_fts_tables,
   sprintf(q(A total of %d FTS virtual tables were created in database),
      $expected_fts_tables)
);

note "FTS tables: ";
foreach my $table (sort(@tables)) {
   # skip non-fts tables
   next unless ( $table =~ /"f/ );
   note qq(- $table);
}

done_testing();
