#!/usr/bin/env perl

# script to demo round-tripping in TOML
use strict;
use warnings;
use 5.010;

use Data::Dumper;
use File::Slurp::Tiny qw(read_file);
use TOML qw(from_toml to_toml);

say q(Reading demo file 'toml_demo.toml');
my $toml = read_file(q(toml_demo.toml));
my $data = from_toml($toml);
say q(Data::Dumper contents of TOML file:);
print Dumper $data;
print qq(\n);
my $to_toml = to_toml($data);
say q(TOML-ified contents of Perl data structure);
say $to_toml;
