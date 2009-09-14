#!/usr/bin/perl

# script to test math dealing with polar and cartesian coordinates

use strict;
use warnings;
use Math::Trig;

my $start_x = 234;
my $start_y = -178;

my $rho = sqrt( ($start_x**2) + ($start_y**2) );
print qq( x squared = ) . ($start_x**2) . qq(\n);
print qq( y squared = ) . ($start_y**2) . qq(\n);
#my $rho = $start_x;
print qq(starting rho is $rho\n);
my $current_theta = 360 + rad2deg(atan2($start_y, $start_x));
print qq(starting theta is $current_theta\n);
my @angles = ( 320, 322, 323, 325, 330, 335, 340, 345, 350, 355, 360 );

print qq(starting X and Y are $start_x, $start_y\n);
foreach my $theta ( @angles ) {
    my $new_x = $rho * cos(deg2rad($theta));
    my $new_y = $rho * sin(deg2rad($theta));
    print qq( for theta $theta, the new X and Y values are: $new_x, $new_y\n);
}
