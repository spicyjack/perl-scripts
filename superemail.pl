#!/usr/bin/perl -w


$EMAIL="user\@host.com";

$message = "This is where your message should go";

for ($x=0; $x <= 50; $x++) {
	system("echo $message | /usr/bin/mail -s \"subject\" $EMAIL");
}

