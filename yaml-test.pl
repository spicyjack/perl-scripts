#!/usr/bin/perl -T

# $Id$
# Copyright (c)2007 by Brian Manning
#
# Demo for IO::YAML, YAML Ain't Markup Language

use strict;
use warnings;

use IO::YAML;
use Data::Dumper;


# create a YAML object using the DATA filehandle
my $yaml = IO::YAML->new(\*DATA);
#my $yaml = IO::YAML->new(q(yaml.txt));

# set the autoloader to 'on'
$yaml->auto_load(1);

my $hash;
# read the data stream
while ( not $yaml->eof() ) {
    $hash = <$yaml>;
} # while ( not $yaml->eof() )

# create a Data::Dumper object
my $dd = Data::Dumper->new([$hash]);

print qq(The data is:\n);
print Dumper $hash;

# end of the script
1;

=pod

# old YAML data
root_device: /dev/sda2
# use the X's below as a placeholder for the key ID in your disk key filename
disk_encryption_key_file: user_disk_key-XXXXXXXX.gpg
max_user_keys: 40

=cut

__DATA__
#%YAML 1.1
---
- level1
-
 - item1
 - item2
 - item3
- level2
-
 - item4
 - item5
 - item6
