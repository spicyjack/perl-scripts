#!/usr/bin/perl

use Date::Parse;

my $time = str2time(q(2007-10-13 19:45:00));
print qq(time is $time\n);
