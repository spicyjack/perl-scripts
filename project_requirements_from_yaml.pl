#!/usr/bin/env perl

# Copyright (c)2014 by Brian Manning

use strict;
use warnings;
use 5.010;

use YAML::XS qw(LoadFile);
use Data::Dumper;

# create a YAML object using the DATA filehandle
my $struct = LoadFile(q(project_requirements.yaml));

#say Dumper $struct;
my $counter = 0;
foreach my $block (@{$struct}) {
    $counter++;
    say sprintf(q(ID: %04u: ), $counter) . $block->{title};
    say "  Desc:    " . $block->{desc};
    say "  Section: " . $block->{section};
    say "  Type:    " . $block->{type};
    say "  Time:    " . $block->{half_days} . q| (eѕtimate, in half-days)| ;
    my $actual_time;
    if ( $block->{type} == 1 ) {
        $actual_time = q|  (Type 1 tasks don't receive any time adjustments)|;
    }
    if ( $block->{type} == 2 ) {
        $actual_time = q|  (Type 2 task: |
            . $block->{half_days}
            . q( half-days * 1.5 = )
            . $block->{half_days} * 1.5
            . q| half-days)|;
    }
    if ( $block->{type} == 3 ) {
        $actual_time = q|  (Type 3 task: |
            . $block->{half_days}
            . q( half-days * 3 = )
            . $block->{half_days} * 3
            . q| half-days)|;
    }
    say $actual_time;
    print qq(\n);
}
