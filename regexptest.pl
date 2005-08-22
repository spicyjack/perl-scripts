#!/usr/bin/perl

# test regular expressions

print "please input a test string: ";
$input = <STDIN>;
$input =~ s/\\/\//g;
$input =~ s/[^A-Za-z0-9._\/-]//g;
print "substituted output is $input\n";
print "Thanks for playing!!\n";

