#!/usr/bin/perl

use strict;
use warnings;
# $Id$
# Copyright (c)$Date$ by Brian Manning
#
# perl script that does something

#   This program is free software; you can redistribute it and/or modify
#   it under the terms of the GNU General Public License as published by
#   the Free Software Foundation; version 2 dated June, 1991.
#
#   This program is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU General Public License for more details.
#
#   You should have received a copy of the GNU General Public License
#   along with this program;  if not, write to the Free Software
#   Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111, USA.

use AppConfig;

my $config = AppConfig->new({	CREATE => 1,
								GLOBAL => { ARGCOUNT => q(ARGCOUNT_LIST) }
							});
$config->define(q(package_name=s));
$config->define(q(package_type=s));
$config->define(q(package_author=s));
$config->define(q(package_author_email=s));
$config->file(q(./appconfig_test/antbuild.conf));
use Data::Dumper;
my $dump = Data::Dumper->new([$config]);
print $dump->Dump;

$config->define(lc($config->get(q(package_name))) . q(_file=s@) );
$config->file(q(./appconfig_test/antbuild.conf));
my $newdump = Data::Dumper->new([$config]);

print $newdump->Dump;
# load different config files (array, hash)
# dump the config object so that you can see how the different values are
# structured inside of that object as opposed to how the config file is
# structured

# vi: set ft=perl sw=4 ts=4 cin:
# end of line

