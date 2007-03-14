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

root_device: /dev/sda2
# use the X's below as a placeholder for the key ID in your disk key filename
disk_encryption_key_file: user_disk_key-XXXXXXXX.gpg
max_user_keys: 40


--- 
- MTL/MSG Perl Testing Modules Survey
  percent_complete: 100
  task_duration: 8
  task_description: >
    Survey the MTL/MSG Perl modules, with an eye towards answering the
    following questions:
      - When the Perl framework acts as a client, what messages are being sent,
        how often are they being sent, and from which modules are they being
        sent
      - How does the Perl MTL framework keep track of connections from the
        binary components?
      - If the SourceIdentification message went away, would the Perl framework
        still function correctly?

 - 
 


=cut

__DATA__
#%YAML 1.1
---
3.0-xcast/3.L2 Perl Testing Framework Integration:
 - percent_complete: 100
   task_duration: 8
   task_description: >
     Integrate 3.0-xcast and 3.L2 testing/perl directories in Perforce
 - percent_complete: 100
   task_duration: 8
   task_description: >
     Integrate 3.0-xcast and 3.L2 DIST/OSS Perl testing frameworks directories
     in Perforce
 - percent_complete: 100
   task_duration: 8
   task_description: >
     Run DIST/OSS sample tests using either branch of the testing frameworks
     in Perforce
...
