#!/usr/bin/perl -w

# script to page me with an attacker's info

# are we debugging?
$DEBUG=0; # 1=true, 0=false
$PAGE_EMAIL="steve\@91x.com";
#$PAGE_EMAIL="brian\@sunset-cliffs.org";

#print "Paging $PAGE_EMAIL\n";

$message = "Hi Steve!  My name is Brian, and my phone number is 619-226-6003";

for ($x=0; $x <= 50; $x++) {
	system("echo $message | /usr/bin/mail -s \"DM\" $PAGE_EMAIL");
}

