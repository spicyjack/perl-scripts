#!/usr/bin/perl

# script to test math dealing with polar and cartesian coordinates

use strict;
use warnings;
use Math::Trig;

my $start_x = 200;
my $start_y = 0;

#my $rho = sqrt( ($start_x^2) + ($start_y^2) );
my $rho = $start_x;
print qq(rho is $rho\n);
my @angles = ( 0, 5, 10, 15, 20, 25, 30, 35, 40, 45 );

print qq(starting X and Y are $start_x, $start_y\n);
foreach my $theta ( @angles ) {
    my $new_x = $rho * cos(deg2rad($theta));
    my $new_y = $rho * sin(deg2rad($theta));
    print qq( for theta $theta, the new X and Y values are: $new_x, $new_y\n);
}
