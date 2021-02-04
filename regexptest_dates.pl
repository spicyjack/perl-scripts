#!/usr/bin/perl

use 5.010;
use List::MoreUtils qw(firstidx);
# test regular expressions

my $months_re = qr/January|February|March|April|May|June
                  |July|August|September|October|November|December/x;
my @months_list = qw(January February March April May June
                   July August September October November December);

my $input = q(December 31st, 2020);
#my $regex = qr/([A-Z][a-z]*) (\d+)(st|nd|rd|th)(,)* (\d\{,4\})/;
my $regex = qr/($months_re) (\d+)(st|nd|rd|th)(,)* (\d{4})/;

# for matching text...
if ( $input =~ $regex ) {
   my $month_str = $1;
   my $date = $2;
   my $year = $5;
   my $month = firstidx { $_ eq $month_str } @months_list;
   $month++;
   say qq(Regex matched input!);
   say qq(Month: $month, date: $date, year: $year);
} else {
   say qq(Regex did not match input!);
}

# for substituting text...
#my $regex = qr/.*#(\d+);.*/;
#if ( $input =~ s/$regex/$1/ ) {
#    print qq(Worked! \$input is now '$input' \n);
#} else {
#    print qq(Did not work! \$input is still $input\n);
#} # if ( $input =~

print "regex: '$regex'\n";
print "input: '$input'\n";
