#!/usr/bin/perl

# script to test math dealing with polar and cartesian coordinates

use strict;
use warnings;
use Math::Trig;

my %polar = (
    # theta/angle           rho/radius
    45                  =>  12,
    30                  =>  16,
    60                  =>  96
);

foreach my $theta ( sort(keys(%polar)) ) {
    # sin/cos take arguments in radians; must convert from decimal first
    my $new_x = (cos( deg2rad($theta) ) * $polar{$theta});
    my $new_y = (sin( deg2rad($theta) ) * $polar{$theta});
    print qq( for theta $theta, and 'r' ) . $polar{$theta}
        . qq(, the new X and Y values are: $new_x, $new_y\n);
    print qq|cos(theta) is | . (cos(deg2rad($theta) )) . qq(\n);
    print qq|sin(theta) is | . (sin(deg2rad($theta) )) . qq(\n);
}
