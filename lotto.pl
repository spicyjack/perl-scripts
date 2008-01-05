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
use Text::CSV;

my $csv = Text::CSV->new( {
        sep_char        => ' ',
        eol             => qq(\n)
});

open(CSV,"<DownloadAllNumbers.htm");
my $counter = 0;
foreach my $line (<CSV>) {
    # munge out extra spaces
    chomp($line);
    $line =~ s/\s+/ /g; 
    my $status = $csv->parse($line);
    print qq(Columns are: ) . join(q(:), $csv->fields() ) . qq(\n);
    $counter++;
    if ( $counter == 10 ) { exit 0; }
} # foreach my $line (<CSV>)
