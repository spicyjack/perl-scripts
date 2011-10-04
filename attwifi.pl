#!/usr/bin/perl -w
use strict;
use warnings;
use WWW::Mechanize;
use File::Basename;

# very simple logging
use constant DEBUG => 1;
sub debug;
our $Debug_Handle;
our $Program_Name = basename $0;
BEGIN {
    if ( DEBUG ) {
        # passing undefined var to open only works in newer perl
        open $Debug_Handle, ">", "/var/log/attwifi.log";
        select $Debug_Handle; $| = 1;
    }
}


our( $SSID, $IF, $STATUS );
chomp( $SSID = `/sbin/iwgetid --raw` );
$IF = shift // '';
$STATUS = shift // '';

debug "SSID: $SSID; IF: $IF; STATUS: $STATUS";

sub main {
    return unless $STATUS eq 'up';
    return unless $IF eq 'wlan0';
    return unless $SSID eq 'attwifi';

    my $mech = new WWW::Mechanize;
    $mech->get( 'http://www.google.com/' );
    unless ( $mech->success ) {
        debug "Failed to get google.com";
        return;
    }
    if ( $mech->form_with_fields( 'aupAgree' ) ) {
        debug "Found form with field aupAgree";
        $mech->submit(
            button => 'connect',
            fields => { aupAgree => 1 }
        );
         if ( $mech->success ) {
            debug "Submitted form success";
        }
        else {
            debug $mech->res->as_string;
        }
    }
    else {
        debug "Form not found";
    }
}


END {
    debug "Finished";
    close $Debug_Handle;
}

sub debug {
    return unless DEBUG;
    print $Debug_Handle "[" . localtime()
        . "] $Program_Name". "[$$] ", @_, "\n";
}

main();

