#!/usr/bin/perl -w

# Gets all the artists from my MP3 database

# Uses DBI
	use DBI;

# Database variables
$outdb = 'mp3db';           #Database to check
$sqlserver = 'localhost';   #SQL server to use
$sqluser = 'nobody';  		#SQL username
$sqlpass = 'password';	    #SQL password

	# open the database connection
	$dbh = DBI->connect("DBI:mysql:$outdb:$sqlserver", $sqluser, $sqlpass)
    	|| die("Connect error: $DBI::errstr");


	$total_lines = 0; # set a line counter 

	# the SQL select statement
	$selectsql = "SELECT distinct artist from mp3main order by artist";

	# run the select query
	$sthselect = $dbh->prepare($selectsql);
	$sthselect->execute();

	# now go get the song_id, use while for fetching the return values,
	# there may be more than one file entry into the database

	while (@row = $sthselect->fetchrow_array ) {
		$outstring .= $row[0] . ", ";
		$total_lines++
	}

	# we're done, disconnect
	$dbh->disconnect;

	# tell'em how we did...
	print $outstring . "\n";
	print "\nFound $total_lines total artists\n";

exit 0;
