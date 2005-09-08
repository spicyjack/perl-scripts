#!/usr/bin/perl

# test regular expressions

print "please input a test string: ";
$input = <STDIN>;
$input =~ s/(\w+\.)//g;
print "substituted output is: >$input<\n";
print "Thanks for playing!!\n";

