#!/usr/bin/perl

# $Id$
# Copyright (c)2007 by Brian Manning <elspicyjack at gmail dot com>

# script to parse lottery winning numbers files in order to show the numbers
# with the highest frequency

# winning lottery numbers:
# http://tinyurl.com/27gnzm (MegaMillions)
# http://tinyurl.com/yv3xd8 (SuperLotto)
#
# CNN/Money article on a lottery winner's investments
# http://tinyurl.com/337nyj

use strict;
use warnings;

# external modules
use LWP::UserAgent;
use HTTP::Response; # $lwp->get() returns a HTTP::Response
use HTTP::Status; # the $response has a HTTP::Status code
use Text::CSV;

# space as a separator, eol is a newline
my $csv = Text::CSV->new( {
        sep_char        => ' ',
        eol             => qq(\n)
});

my $ua = LWP::UserAgent->new();
#my $response = $ua->get(q(http://tinyurl.com/yv3xd8));
#my $response = $ua->get(q(http://files.antlinux.com/docs/mm.html));
my $response = $ua->get(q(http://devilduck.qualcomm.com/mm.html));
if ( $response->is_success() ) {
    my $counter = 0;
    foreach my $line ( split(/\n/, $response->content()) ) {
        # remove the ^M, it's a DOS text file
        $line =~ s/\x0d//g;
        print qq(Raw line is: >$line<\n);
        # munge out extra spaces
        $line =~ s/\s+/ /g; 
        next if ( $line =~ /^-----/ );
        next if ( length($line) == 0 );
        my $status = $csv->parse($line);
        print qq(Columns are: ) . join(q(:), $csv->fields() ) . qq(\n);
        $counter++;
        if ( $counter == 10 ) { exit 0; }
    } # foreach my $line (<CSV>)
} else {
    warn(qq(HTTP request returned an error;\n) 
        . $response->status_line() .  qq(\n));
} # if ( $response->is_success() )
