#!/usr/bin/perl -w

# Get a list of MP3's out of top10s, then output the filenames to a file,
# while counting the number of files, and the filesize of
# each file, so you know if you go over the limit of your 6G drive

# check to make sure a filename to write was passed in
if ( $ARGV[0] =~ /d/ && ! $ARGV[1] ) {
	print "You must enter a filename to write.  Exiting...\n";
	exit 1;
} # if $ARGV[0]

if ( $ARGV[0] =~ /d/ ) {$DEBUG = 1;}

# we're cool, start the show
use DBI;

# variables
$dbserver = 'localhost'; 
$dbport = '3306';
$dbuser = 'nobody';	
$dbpass = 'efilnikcufecin';
$mp3db = 'mp3db';
$sum = 0;
$filesize = 0;

# open the database
my $dbh = DBI->connect("DBI:mysql:$mp3db:$dbserver:$dbport",
        $dbuser, $dbpass) || die("Connect error: $DBI::errstr");
# set the SQL statement
$sql = "select song_id from top10s order by count desc";

# prep the statement
$sth = $dbh->prepare( $sql );
$sth->execute;

if ($DEBUG) {open (COPYLIST, ">$ARGV[1]") || 
		die "Can\'t write to $ARGV[1]\n$!";}

# loop thru the top 10 list, and pull the filename and write to a file
while ( @top10row = $sth->fetchrow() ) {
	$filename = &sql_get_filename($top10row[0]);
	$sum++;	
	# get the size of the MP3
	@filestat = stat ($filename);
	$filesize += $filestat[7]; 
	# write it to a file if ($DEBUG)
	if ($DEBUG) {
		print COPYLIST "$filename \n";
	} else {
		print "$sum: $filename \n";
	}
	if ($filesize > 6000000000) {next;}
} #while

$dbh->disconnect();

if ($DEBUG) {close (COPYLIST);}

print "Total filesize is $filesize bytes\n";
# fin.

sub sql_get_filename {

# returns the MP3 array for the song_id argument
  
# mp3main -> 0:id, 1:filename, 2:filedir, 3:insertdate  4:songname, 5:artist,
# 6:album, 7:albumdate, 8:comment, 9:genre
# 10:MP3 version, 11:min, 12:sec, 13:stereo, 14:layer, 15:bitrate, 16:mode,
# 17:copyright, 18:frequency
  
    my $dbh = DBI->connect("DBI:mysql:$mp3db:$dbserver:$dbport",
        $dbuser, $dbpass) || die("Connect error: $DBI::errstr");
    my $sql  = "SELECT * FROM mp3main m ";
    $sql .= "WHERE m.song_id = '$_[0]'";
    print STDERR "sql_getinfo: sql is $sql \n" if $DEBUG;
    my $sth = $dbh->prepare($sql) || die $dbh->errstr;
    $sth->execute;
    my @sqlcall = $sth->fetchrow_array;
    $sth->finish;
    $dbh->disconnect;
    return $sqlcall[2] . "/" . $sqlcall[1];
} # sub sql_getinfo

