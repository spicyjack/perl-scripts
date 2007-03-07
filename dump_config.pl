#!/usr/bin/perl

# script to dump the contents of Config.pm
use Config qw(config_re);
#print myconfig();
print join(":", config_re(q(archlib))) . qq(\n);
