#!/usr/bin/perl

# test regular expressions

print "Please input a string to test against: ";
$input = <STDIN>;
chomp($input);
# .1.3.6.1.2.1.25.2
# period, one or more digits, repeated one or more times
# $input =~ s/^([.\d+]+)$/$1/g;
# print "substituted text is >$1<\n";

# HH:MM ???
#my $regex = '\d\d:\d\d \(\d+?\+?\d+:\d+\)';
# phone number
#my $regex = '\d{3}-\d{3}-\d{4}';
# MS-DOS path/filename
# ^([c-zC-Z]:/[a-zA-Z0-9_.-]+)
# a file path: >./deathmatch/deathtag:<
#my $regex = q(^\.[\/\w]*:$);
#if ( $input =~ m#^([c-zC-Z]:/[a-zA-Z0-9_.-]+)# ) {
#if ( $regex =~ s/^\s([a-zA-Z0-9\.,]+)\s+$/$1/g ) {
#my $regex = q(^[a-zA-Z]+$);

# regex for finding Rex tasks/batch tasks
# - multiline because of the '\x' modifier
my $regex = qr/
    ^task[ \t]* "([a-zA-Z0-9_]+)"\s{0,},
    |^task[ \t]*q{1,2}\(([a-zA-Z0-9_-]+)\)\s{0,},
    |^batch[ \t]*"([a-zA-Z0-9_-]+)"\s{0,},
    |^batch[ \t]*q{1,2}\(([a-zA-Z0-9_-]+)\)\s{0,},
    /x;
#my $regex = qr/^task[ \t]*q{1,2}\(([a-zA-Z0-9_-])\),/;
if ( $input =~ $regex ) {
    print qq(Worked!\n);
} else {
    print qq(Did not work!\n);
} # if ( $input =~
print "regex: '$regex' input: '$input'\n";

