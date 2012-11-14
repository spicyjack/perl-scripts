#!/usr/bin/perl

# script to dump the netflow top-talkers
# monitor user: username    pass: s3kr3t
use strict;
use warnings;
use Expect;

my $ssh_cmd = q(ssh -l username some_ip_address);
my $cmd = q(show ip flow top-talkers);
my $hostprompt = q(vpn1);

my $ssh = new Expect;
$ssh->raw_pty(1);
$ssh->spawn($ssh_cmd) or die qq(Cannot spawn $ssh_cmd : $!\n);

$ssh->expect(10, '-re', 'assword: ');
$ssh->send($cmd);
$ssh->expect(10, '-re', '^.*$');

#print qq(Top talkers are:\n);
#print $top_talkers;

exit 0;
