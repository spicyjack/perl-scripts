#!perl -T

=head1 TEST: Exercise the C<Lotto.pm> db_init() method

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
log4perl.rootLogger = DEBUG, Screen
log4perl.appender.Screen = Log::Log4perl::Appender::ScreenColoredLevels
log4perl.appender.Screen.stderr = 1
log4perl.appender.Screen.layout = PatternLayout
log4perl.appender.Screen.layout.ConversionPattern = [%6r] %p %m%n
L4PCFG

Log::Log4perl->init_once($log4perl_cfg);
my $log = Log::Log4perl->get_logger();

# :memory: is a special parameter to the DBD::SQLite driver
# https://metacpan.org/module/DBD::SQLite#Database-Name-Is-A-File-Name
my $dbh = DBI->connect(qq(dbi:SQLite:dbname=:memory:), q(), q());
isa_ok($dbh, q(DBI::db));

=item * Test script can create a database handle to an in-memory test database

=cut

my $db_init_sql = <<'DB_INIT';
DROP TABLE IF EXISTS draws;

CREATE TABLE draws (
    draw_num        INTEGER,
    draw_date       VARCHAR(15)
);
DB_INIT

$log->debug(qq(Creating database tables));
my $result = $dbh->do($db_init_sql);
ok($result, q(Initialziation of database returned 'true' value));

my $info = $dbh->table_info('%', '', '');

my $info_ref = $info->fetchall_arrayref();
use Data::Dumper;
print Dumper $info_ref;
exit 0;
#print $dbh->do(q(.schema));
=item * db_init() returns success value, meaning DBI reports table creation
was successful; note that running this test with DEBUG turned on will produce
debug output from the L<Lotto> module.

=cut

# sample data to be insertedinto the database
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
is(scalar(@old_draws), 5,
    q(Returned the same number of rows that was inserted into database));

=item * sample data inserted into database is returned correctly when
get_draw_rows is called

=back

=cut

done_testing();
