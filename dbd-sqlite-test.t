#!perl -T

=head1 TEST: Test using different SQLite functions via DBD::SQLite

=over

=cut

# useѕ the 'done_testing()' function below to denote that all tests have been
# run; if you need to update the number of tests, update done_testing below
use Test::More;
use Test::File;

BEGIN {
    use_ok(q(DBI));
    use_ok(q(Log::Log4perl), qw(:no_extra_logdie_message));
}

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

=item * Test script can create a database handle to an in-memory test database

=cut

my $db_init_sql = <<'DB_INIT';
CREATE TABLE draws (
    draw_num        INTEGER,
    draw_date       VARCHAR(15)
);
DB_INIT

$log->debug(qq(Creating database tables));
$log->debug($db_init_sql);
my $result = $dbh->do($db_init_sql);
is($result, q(0E0), q(Initialziation of database returned '0E0' value));

# get information about the table(s)
#my $info = $dbh->table_info('', '', '', '%');
my @tables = $dbh->tables();
is(scalar(grep(/"main"\."draws"/, @tables)), 1,
    q(main.draws table exists in database));

=item * db_init() returns success value, meaning DBI reports table creation
was successful; note that running this test with DEBUG turned on will produce

=cut

# sample data to be inserted into the database
my %example = (
    2533 => q(07-13-2011),
    2534 => q(07-23-2011),
    2539 => q(08-03-2011),
    2574 => q(12-03-2011),
    2575 => q(12-07-2011),
);

my $sth = $dbh->prepare( q|INSERT INTO draws VALUES (?, ?)| );
foreach my $draw ( keys(%example) ) {
    $sth->execute($draw, $example{$draw});
}

my $draws_ref = $dbh->selectall_arrayref(
    q(SELECT d.draw_num, d.draw_date )
    . q(FROM draws AS d )
    # draw number ASCENDING makes the oldest draw show up first in the
    # returned list
    . q(ORDER BY d.draw_num ASC )
) or die $dbh->errstr;
# execute the statement
$log->debug(qq(Getting number of rows));

my @db_draws = @{$draws_ref};
is(scalar(@db_draws), 5,
    q(Returned the same number of rows that was inserted into database));

use Data::Dumper;
print Dumper @db_draws;
print qq(\n);
=item * sample data inserted into database is returned correctly when
get_draw_rows is called

=back

=cut

done_testing();
