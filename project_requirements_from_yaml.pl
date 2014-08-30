#!/usr/bin/env perl

# For support with this file, please file an issue on the GitHub issue tracker
# for this project: https://github.com/spicyjack/perl-scripts/issues

=head1 NAME

B<project_requirements_from_yaml.pl> - Display on STDOUT, or create a
database, all of the project requirements given to the script via a YAML file.

=cut

our $copyright = q|Copyright (c)2014 Brian Manning|;

=head1 SYNOPSIS

 project_requirements_from_yaml [options]

 Script options:
 -y|--yaml      YAML file to read from
 -o|--output    Filename of the database to write to
                Default is to write plaintext to STDOUT

You can view the full C<POD> documentation of this file by calling
C<perldoc project_requirements_from_yaml>.

=cut

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
