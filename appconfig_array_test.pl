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
&printit($Config);

# this doesn't work either, each successive set() method call adds the value to
# the array, no matter what; there's no way as far as I know to 'unset' a
# variable
$Config->set(q(libpath), undef);
&printit($Config);

# this works however...
$Config->_default(q(libpath));

&printit($Config);

sub printit {
    my $Config = shift;
    print qq(The joined libpath is:\n) 
        . join(q(:), @{$Config->get(q(libpath))} ) . qq(\n);
} # sub printit
