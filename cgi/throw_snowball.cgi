#!/usr/bin/perl -w

# Script to Throw a snowball at Joann
#
# Brian Manning
# 1999/12/09
#
# Stolen from Learning Perl
# If you don't have that book, you are a luser

use 5.004;
use strict;
use CGI qw(:standard);
use Fcntl qw(:flock);

sub bail {
	my $error = "@_";
	print h1("Unexpected Error"), p($error), end_html;
	die $error;
}

my(
        $NAMESFILE, # file with the names in it
		$MAXSAVE,       # number of names to keep
		$TITLE,         # page title and header
		$SNOWBALL,		# name of the snowball file
		$OUTFILE,		# holder for the e-mail body
		$current,       # current entry in the names list
		@entries,      # all of the current entries
		$entry,         # one particular entry
		$tmptext,		# place to hold the email addy
		$tmpwish,		# place to  hold the wish
);

$TITLE =  "Throw Joann A Snowball";
$NAMESFILE = "/home/nobody/snowball.dat";
$SNOWBALL = "/home/nobody/snowball.txt";
$OUTFILE = "/home/nobody/outfile.txt";
$MAXSAVE = 1000;

# CGI stuff, dig it
 
print header, start_html($TITLE), h1($TITLE);


# Start a here document
print <<END_BODY_TEXT;

<P>Now all of you can see how smug Joann is now that she has peppered us with
snowballs, right??  
<P>When I was in 6th Grade Crossing Guard camp, the Police officers who ran it
promised us kiddies pizza.  Of course, the nearest pizza place was about 50
miles away.  So on the inside of the "delivery vehicle" (a police van), instead
of there being piles of pizza pies, there was nothing but a big sign
that said, "Don't get mad, get even".  And that is what I am offering you, a
chance to get even.
<P>Here is the deal.  I set up an automatic snowball thrower CGI script.  All
you have to do to use it is fill in your e-mail address as it appeared in the
original snowball message from Joann.  And let my computer do the rest.  Feel
free to send as many snowballs as you want, but let's not get poor Joan into
trouble with her IS people.

END_BODY_TEXT

$current = CGI->new();							# current request
if ($current->param("email")) {				# we have live data
			$current->param("date",scalar localtime);	# set to current time
			@entries = ($current);  # add the message to the back end
			$tmptext = $current->param("email");
			$tmpwish = $current->param("wish");
			system ("rm -f $OUTFILE");
			system ("echo \"Here's a snowball from $tmptext\" >> $OUTFILE");
			system ("cat $SNOWBALL >> $OUTFILE");
			system ("echo Special Message is: $tmpwish >> $OUTFILE");
			system ("cat $OUTFILE | /bin/mail -s \"SPLAT!  Another Snowball for
			you, Joann!\" joannc\@hotdogonastick.com");
} # if

# open the message file for read/write, appending to current file
open (DATFILE, "+< $NAMESFILE") || bail ("could not open $NAMESFILE: $!");

# exclusive lock the names file
flock(DATFILE, LOCK_EX) || bail ("could not lock $NAMESFILE: $!");

# grab the old entries up to $MAXSAVE, newest first
while (!eof(DATFILE) && @entries < $MAXSAVE) {
	$entry = CGI->new(\*DATFILE); # pass filehandle by reference
	push @entries, $entry;
} # while

seek(DATFILE, 0, 0) || bail ("could not rewind $NAMESFILE: $!");

foreach $entry (@entries) {
	$entry->save(\*DATFILE); # pass filehandle by reference
} # foreach

truncate(DATFILE, tell(DATFILE)) || bail ("could not truncate $NAMESFILE: $!");
close(DATFILE) || bail ("could not close $NAMESFILE: $!");

print hr, start_form;
print p("Your E-Mail address:", $current->textfield(	-NAME => "email",
												-SIZE => 30,
												-DEFAULT => '',
												-MAXLENGTH => 50,
												-OVERRIDE => 1));
print p("Special Snowball wishes for Joann:", 
		$current->textfield( -NAME => "wish",
							-DEFAULT => '',
							-SIZE => 60,
							-MAXLENGTH => 150,
							-OVERRIDE => 1));

print p( submit("Throw this Snowball!"), reset("Ugh! Clear this Form Now!"));
print end_form, hr;

# print out past submissions

print h2("Prior Snowballs for Joann");
foreach $entry (@entries) {
	printf("%s [%s]: %s",
		$entry->param("date"),
		$entry->param("email"),
		$entry->param("wish"));
	print br();
} # foreach

print end_html;
