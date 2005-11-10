#!/usr/bin/perl

# test regular expressions

print "please input a test string: ";
$input = <STDIN>;
chomp($input);
$input =~ s/^(\d+).*\.mp3/$1/g;
print "substituted output is: >$input<\n";
print "Thanks for playing!!\n";

