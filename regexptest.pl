#!/usr/bin/perl

# test regular expressions

print "please input a test string: ";
$input = <STDIN>;
chomp($input);
$input =~ s/.*\.(\w+)$/$1/;
print "substituted output is: >$input<\n";
print "first variable is >$1<\n";
print "Thanks for playing!!\n";

