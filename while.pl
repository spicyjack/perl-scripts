#!/usr/local/bin/perl

# script to display the filesize, mtime, and filename of a user's mail spool
# kinda like a really lame biff program

# define the colors
&DefineColors;

$spool = "/var/mail/manningb";
#$grep = "/usr/bin/grep";
$grep = "/bin/grep";
$wc = "/usr/bin/wc";
$datecmd = "/bin/date";
#$date = "/usr/bin/date";
$lscmd = "/bin/ls";

# start the endless loop
while (1) {
	#$ls_out = `$lscmd -la $spool`;
	#chomp($ls_out);
	#@ls = split(/\s+/, $ls_out);
	$date = `$datecmd +\"\%T \%Z\"`;
	chomp($date);
	$wc_out = `$grep From: $spool | $wc -l`;	
	chomp($wc_out);
	$wc_out =~ s/\s//g;
	# $ls[4] is filesize
	# $ls[5] is month
	# $ls[6] is date
	# $ls[7] is time
	# $ls[8] is filename
	if ( $wc_out == 0 ) { 
		print $color{reverse} . $color{normal} . $date . $color{normal} . ":" .
			$color{b_green} .  "You have no mail messages" .  
			$color{normal} . "\n";
	} else {
		print $color{reverse} . $color{normal} . $date . $color{normal} . ":" .
		$color{cyan} . " You have " .  $color{b_yellow} .  $wc_out . 
		$color{cyan} . " messages " .  $color{normal} . "\n";
	} # if ( $wc_out == 0 )
	sleep 5;
} # while (1)

sub DefineColors {
# color definitions

%color = ( 	b_black => "\033[1;30;40m",
			black => "\033[00;30;40m", 
			b_red => "\033[1;31;40m",
			red => "\033[00;31m",
			b_green => "\033[1;32;40m",
			green => "\033[00;32m",
			b_yellow => "\033[1;33;40m",
			yellow => "\033[00;33m",
			b_blue => "\033[1;34;40m",
			blue => "\033[00;34m",
			b_magenta => "\033[1;35;40m",
			magenta => "\033[00;35m",
			b_cyan => "\033[1;36;40m",
			cyan => "\033[00;36m",
			white => "\033[1;37;40m",
			reverse => "\033[07m",
			normal => "\033[00m"
);
} # sub DefineColors {

#	Background Colors
#	40	Black
#	41	Red
#	42	Green
#	43	Yellow
#	44	Blue
#	45	Magenta
#	46	Cyan
#	47	White
 
# end of line
