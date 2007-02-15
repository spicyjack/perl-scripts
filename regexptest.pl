#!/usr/bin/perl

# test regular expressions

print "please input a test string: ";
$input = <STDIN>;
chomp($input);
$input =~ s/[^(\d{1,2})]/$1/g;
print "substituted input is: >$input<\n";
print "first variable is >$1<\n";
print "Thanks for playing!!\n";

