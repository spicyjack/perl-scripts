#!/usr/bin/perl

use strict;
use warnings;

use AppConfig;
my $Config = AppConfig->new();
$Config->define(q(libpath|path|p=s@));
# seed the libpath with some defaults
$Config->set(q(libpath), q(/usr/lib/perl));
$Config->set(q(libpath), q(/usr/lib/perl5));

# yep, it turns out that the set() method only accepts one argument, even for
# array AppConfig objects.  Poopy.

$Config->args(\@ARGV);

print qq(The joined libpath is:\n) 
    . join(q(:), @{$Config->get(q(libpath))} ) . qq(\n);
