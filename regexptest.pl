#!/usr/bin/perl

# test regular expressions

print "please input a test string: ";
$input = <STDIN>;
chomp($input);
# .1.3.6.1.2.1.25.2
# period, one or more digits, repeated one or more times
# $input =~ s/^([.\d+]+)$/$1/g;
# print "substituted text is >$1<\n";

#if ( $input =~ /^([c-zC-Z]:[a-zA-Z0-9_.-]+)$/ ) {
if ( $input =~ m#^([c-zC-Z]:/[a-zA-Z0-9_.-]+)# ) {
    print "matched pattern : >$input<\n";
    print "Thanks for playing!!\n";
} else {
    print "Does not match pattern \n";
} # if ( $input =~

