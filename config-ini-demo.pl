#!/usr/bin/env perl

# script to demo round-tripping using Config::INI
use strict;
use warnings;
use 5.010;

use Data::Dumper;
use Config::INI::Reader;
use Config::INI::Writer;

say q(Reading demo file 'config-ini-demo.ini');
my $data = Config::INI::Reader->read_file(q(config-ini-demo.ini));
say q(Data::Dumper contents of INI file:);
print Dumper $data;
print qq(\n);
my $to_ini = Config::INI::Writer->write_string($data);
say q(INI text of Perl data structure);
say $to_ini;
