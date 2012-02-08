#!/usr/bin/perl -w

# Script to generate the webpage to ask users to name my cat
#
# Brian Manning
# 1999/12/03
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
	$MAXSAVE,	# number of names to keep
	$TITLE,		# page title and header
	$current,	# current entry in the names list
	@entries,	# all of the current entries
	$entry,		# one particular entry
);

$TITLE =  "Name This Pussy";
$NAMESFILE = "/home/nobody/names.dat";
$MAXSAVE = 100;

# CGI stuff, dig it
 
print header, start_html($TITLE), h1($TITLE);

print "<IMG SRC=\"/pix/name_this_cat_face.jpg\" ALT=\"[ MEOW! ]\"><BR>";

# Start a here document
print <<END_BODY_TEXT;

<P>This is my new cat.  It has no name.  Please give my pussy a name.
Please??<BR>
<IMG SRC="/pix/name_this_cat.jpg" ALT="[ Hanging out ]"><BR>
<P>As you can see, she is pretty mellow.  She is a little louder than the other
two cats that I have.  She is very loving, but not loved by my other two cats,
especially the other female that I have (Girls!). So defintly not a spaz cat,
nor a psycho kitty.  The bald area on her stomach is where they shaved her
when she was fixed.  Now she is an it.

END_BODY_TEXT

$current = CGI->new();							# current request
if ($current->param("name")) {				# we have live data
	$current->param("date",scalar localtime);	# set to the current time
	@entries = ($current);					# add the message to the back end
											# of the array 
}

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
print p("E-Mail address:", $current->textfield(	-NAME => "email",
												-SIZE => 30,
												-DEFAULT => '',
												-MAXLENGTH => 50,
												-OVERRIDE => 1));
print p("This Pussy Should be Called:", 
		$current->textfield( -NAME => "name",
							-DEFAULT => '',
							-SIZE => 60,
							-MAXLENGTH => 150,
							-OVERRIDE => 1));

print p( submit("Name this Pussy Now!"), reset("Ugh! Clear this Form Now!"));
print end_form, hr;

# print out past submissions

print h2("Prior Suggestions for this Pussy");
foreach $entry (@entries) {
	printf("%s [%s]: %s",
		$entry->param("date"),
		$entry->param("email"),
		$entry->param("name"));
	print br();
} # foreach

print end_html;
