#!/usr/bin/env perl

# external packages
use Getopt::Long;
use Log::Log4perl qw(get_logger :levels);
use LWP::Simple;
use Moo; # sets strict and warnings
#use XML::RSS::Parser::Lite;
use WWW::Search;

=head1 NAME

cl_scrape.pl - Grab and parse an RSS feed

=head1 VERSION

Version v0.0.1

=cut

use version; our $VERSION = qv('0.0.1');

=head1 SYNOPSIS

Parse the output of an RSS feed.

    perl cl_scrape.pl -u http://example.com/rss -s "search string"

=cut

    my %args;
    my $g = Getopt::Long::Parser->new();
    $g->getoptions(
        \%args,
        # script options
        q(debug|D|d),
        q(help|h),
        q(search|s=s),
    ); # $p->getoptions

    my $self->{_args} = \%args;
    # if --help was called, print help output via Pod::Usage
    if ( defined $args{help} ) {
        pod2usage( { -verbose => 1, -exitval => 0, -input => __FILE__ } );
    } # if ( defined $args{help} )

    my $logger_conf = qq(log4perl.rootLogger = INFO, Screen\n);
    $logger_conf .= qq(log4perl.appender.Screen = )
        . qq(Log::Log4perl::Appender::ScreenColoredLevels\n);

    my $search = WWW::Search->new(q(CraigsList));
    my $query =
        WWW::Search::escape_query(q/vw|volkswagen (1968|1969|1970|1971)/);
    $search->native_query($query);
    print qq(Found approximately ) . $search->approximate_hit_count()
        . qq( hits\n);
    foreach my $result ( $search->next_result() ) {
        print $result->url() . qq(\n);
    }

=head1 AUTHOR

Brian Manning, C<< <brian at portaboom dot com> >>

=head1 BUGS

Please report any bugs or feature requests to
C<mayhem-launcher@googlegroups.com>, or through the web interface at
L<http://code.google.com/p/mayhem-launcher/issues/list>.  I will be notified,
and then you'll automatically be notified of progress on your bug as I make
changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc App::Mayhem


You can also look for information at:

=over 4

=item * Mayhem Launcher project page

L<http://code.google.com/p/mayhem-launcher>

=item * Mayhem Launcher Google Groups page

L<http://groups.google.com/group/mayhem-launcher>

=back

=head1 ACKNOWLEDGEMENTS

Perl, Gtk2-Perl team, the Doom Wiki L<http://doom.wikia.com> for lots of the
documentation, all of the various Doom source porters, and id Software for
releasing the source code for the rest of us to make merry mayhem with.

=head1 COPYRIGHT & LICENSE

Copyright 2010 Brian Manning, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut

# vim: filetype=perl shiftwidth=4 tabstop=4:
# конец!
