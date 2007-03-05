#!/usr/bin/perl

# script to be used for testing when figuring out how bitwise math works in
# Perl

use strict;
use warnings;

use constant {
    NONE        => 0b0000,
    PARENTS     => 0b0001,
    CHILDREN    => 0b0010,
    FILENAME    => 0b0100,
}; # use constant

my $test = NONE;
print qq(setting to Zero\n);
printtest($test);

$test = NONE & PARENTS;
print qq(and'ing NONE and PARENTS\n);
printtest($test);

$test = CHILDREN & PARENTS;
print qq(and'ing CHILDREN and PARENTS\n);
printtest($test);

$test = CHILDREN | PARENTS;
print qq(or'ing CHILDREN and PARENTS\n);
printtest($test);

$test = FILENAME | PARENTS;
print qq(or'ing FILENAME and PARENTS\n);
printtest($test);
andcheck($test, FILENAME);

sub printtest {
    my $string = shift;
    print(q(test is: ) . sprintf("0b%04b", $string) . qq(\n));
} # sub printtest

sub andcheck {
    my $string = shift;
    my $checkval = shift;

    if ( $string | $checkval ) {
        print q(checkval ') . sprintf("0b%04b", $checkval)
            . q(' is in test string ') . sprintf("0b%04b", $string) . qq('\n);
    } # if ( $string | $checkval )
}  # sub andcheck
