#!/usr/bin/perl

=pod

=head1 NAME

B<last_parse.pl> - parse the output of C<last -a -d>

=head1 DESCRIPTION

This should print out some text when called with C<pod2usage> from
L<Pod::Usage>.

=cut

use strict;
use warnings;
use Parse::RecDescent;

my $parser = Parse::RecDescent->new(<<'EOG' 
    wtmp : wtmp_line(s)

    wtmp_line : login_name pty whitespace day_of_week month

    login_name : /^\w+/
        { print 'login name was ', $item[1] . "\n"; }

    #pty : /^\w+\/\d/ | /system boot/
    pty : /^\w+\/\d/ 
        { print 'pty was ', $item[1] . "\n"; }

    day_of_week: "Sun" | "Mon" | "Tue" | "Wed" | "Thu" | "Fri" | "Sat"
        { print 'day of week was ', $item[1] . "\n"; }

    month:  "Jan" | "Feb" | "Mar" | "Apr" | "May" | "Jun" | 
            "Jul" | "Aug" | "Sep" | "Oct" | "Nov" | "Dec" 
        { print 'month was ', $item[1] . "\n"; }

    #whitespace: /\W+/
    whitespace: /         /
EOG
) or die q(ERROR: bad Parse::RecDescent grammar);

#my $text = do { local $/; <> };

#$parser->wtmp($text) or print qq(No wtmp records found\n);
foreach my $line ( <STDIN> ) {
    $parser->wtmp($text) or print qq(No wtmp records found\n);
}

