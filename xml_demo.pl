#!/usr/bin/perl -w

# Copyright (c) 2013 by Brian Manning <brian at xaoc dot org>
# For help with script errors and feature requests, please file an issue
# on the GitHub issue tracker: https://github.com/spicyjack/perl-scripts/issues

=head1 NAME

B<xml_demo.pl> - A template file for quickly writing Perl scripts.

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';

=head1 SYNOPSIS

 perl xml_demo.pl [OPTIONS]

 Script options:
 -v|--verbose       Verbose script execution
 -h|--help          Shows this help text

 Example usage:

 xml_demo.pl

You can view the full C<POD> documentation of this file by calling C<perldoc
xml_demo.pl>.

=head1 DESCRIPTION

B<xml_demo.pl> -  A template file for quickly writing Perl scripts.

=head1 OBJECTS

=head2 XMLDemo::Config

An object used for storing configuration data.

=head3 Object Methods

=cut

######################
# XMLDemo::Config #
######################
package XMLDemo::Config;
use strict;
use warnings;
use Getopt::Long;
use Pod::Usage;
use POSIX qw(strftime);

=over

=item new( )

Creates the L<XMLDemo::Config> object, and parses out options using
L<Getopt::Long>.

=cut

sub new {
    my $class = shift;

    my $self = bless ({}, $class);

    # script arguments
    my %args;

    # parse the command line arguments (if any)
    my $parser = Getopt::Long::Parser->new();

    # pass in a reference to the args hash as the first argument
    $parser->getoptions(
        \%args,
        # script options
        q(verbose|v+),
        q(help|h),
        # other options
        q(file|f=s@),
        q(dump|d),
        q(list|l),
        q(keys|k),
        q(values|s),
    ); # $parser->getoptions

    # assign the args hash to this object so it can be reused later on
    $self->{_args} = \%args;

    # dump and bail if we get called with --help
    if ( $self->get(q(help)) ) { pod2usage(-exitstatus => 1); }

    # return this object to the caller
    return $self;
}

=item get($key)

Returns the scalar value of the key passed in as C<key>, or C<undef> if the
key does not exist in the L<XMLDemo::Config> object.

=cut

sub get {
    my $self = shift;
    my $key = shift;
    # turn the args reference back into a hash with a copy
    my %args = %{$self->{_args}};

    if ( exists $args{$key} ) { return $args{$key}; }
    return undef;
}

=item set( key => $value )

Sets in the L<XMLDemo::Config> object the key/value pair passed in as
arguments.  Returns the old value if the key already existed in the
L<XMLDemo::Config> object, or C<undef> otherwise.

=cut

sub set {
    my $self = shift;
    my $key = shift;
    my $value = shift;
    # turn the args reference back into a hash with a copy
    my %args = %{$self->{_args}};

    if ( exists $args{$key} ) {
        my $oldvalue = $args{$key};
        $args{$key} = $value;
        $self->{_args} = \%args;
        return $oldvalue;
    } else {
        $args{$key} = $value;
        $self->{_args} = \%args;
    }
    return undef;
}

=item defined($key)

Returns "true" (C<1>) if the value for the key passed in as C<key> is
C<defined>, and "false" (C<0>) if the value is undefined, or the key doesn't
exist.

=cut

sub defined {
    my $self = shift;
    my $key = shift;
    # turn the args reference back into a hash with a copy
    my %args = %{$self->{_args}};

    # Can't use logger object here, since it hasn't been set up yet
    if ( exists $args{$key} ) {
        #warn qq(exists: $key\n);
        if ( defined $args{$key} ) {
            #warn qq(defined: $key; ) . $args{$key} . qq(\n);
            return 1;
        }
    }
    return 0;
}

=item get_args( )

Returns a hash containing the parsed script arguments.

=cut

sub get_args {
    my $self = shift;
    # hash-ify the return arguments
    return %{$self->{_args}};
}

=back

=head2 XMLDemo::Logger

A simple logger module, for logging script output and errors.

=head3 Object Methods

=cut

######################
# XMLDemo::Logger #
######################
package XMLDemo::Logger;
use strict;
use warnings;
use POSIX qw(strftime);
use IO::File;
use IO::Handle;
use Time::HiRes qw(gettimeofday tv_interval);

use Data::Dumper;
$Data::Dumper::Indent = 1;
$Data::Dumper::Sortkeys = 1;
$Data::Dumper::Terse = 1;

=over

=item new($config)

Creates the L<XMLDemo::Logger> object, and sets up various filehandles
needed to log to files or C<STDOUT>.  Requires a L<XMLDemo::Config> object
as the argument, so that options having to deal with logging can be
parsed/acted upon.  Returns the logger object to the caller.

=cut

sub new {
    my $class = shift;
    my $config = shift;

    my $logfd;
    if ( $config->defined(q(logfile)) ) {
        # append to the existing logfile, if any
        $logfd = IO::File->new(q( >> ) . $config->get(q(logfile)));
        die q( ERR: Can't open logfile ) . $config->get(q(logfile)) . qq(: $!)
            unless ( defined $logfd );
        # apply UTF-8-ness to the filehandle
        $logfd->binmode(qq|:encoding(utf8)|);
    } else {
        # set :utf8 on STDOUT before wrapping it in IO::Handle
        binmode(STDOUT, qq|:encoding(utf8)|);
        $logfd = IO::Handle->new_from_fd(fileno(STDOUT), q(w));
        die qq( ERR: could not wrap STDOUT in IO::Handle object: $!)
            unless ( defined $logfd );
    }
    $logfd->autoflush(1);

    my $self = bless ({
        _OUTFH => $logfd,
    }, $class);

    # return this object to the caller
    return $self;
}

=item log($message)

Log C<$message> to the logfile, or I<STDOUT> if the B<--logfile> option was
not used.

=cut

sub log {
    my $self = shift;
    my $msg = shift;

    my $FH = $self->{_OUTFH};
    print $FH $msg . qq(\n);
}

=item timelog($message)

Log C<$message> with a timestamp to the logfile, or I<STDOUT> if the
B<--logfile> option was not used.

=cut

sub timelog {
    my $self = shift;
    my $msg = shift;
    my $timestamp = POSIX::strftime( q(%c), localtime() );

    my $FH = $self->{_OUTFH};
    print $FH $timestamp . q(: ) . $msg . qq(\n);
}

=item header_dump(header => $header, document => $document)

Dump C<$document> with a nice header and footer.

=cut

sub header_dump {
    my $self = shift;
    my %args = @_;

    die q(header_dump: Missing 'document' argument)
        unless (exists $args{document});
    die q(header_dump: Missing 'header' argument)
        unless (exists $args{header});
    die q(header_dump: Missing 'elapsed_time' argument)
        unless (exists $args{elapsed_time});

    my $document = $args{document};
    my $header = $args{header};
    my $elapsed_time = $args{elapsed_time};
    $self->timelog(qq(=== Begin $header ===\n) . Dumper($document));
    $self->timelog(qq(=== End $header ===));
    $self->timelog(qq(--> Elapsed time: $elapsed_time));
}

=item start_timer()

Starts a L<Time::HiRes> timer object, returns an array reference that
represents the seconds and milliseconds that the timer object was created.
This will be used with C<stop_timer()> below.

=back

=cut

sub start_timer {
    # explicitly use scalar context for floating epoch seconds
    my $time = [gettimeofday];
    return $time;
}

=item stop_timer(start => $start_ref)

Compares two L<Time::HiRes> timer objects, the array reference that is passed
in to the method, and an object that the method creates when it is called.
Returns the floating point value that represents the difference between the
two time values.

=back

=cut

sub stop_timer {
    my $self = shift;
    my %args = @_;

    die q(stop_timer: Missing 'start' argument)
        unless ( exists $args{start} );

    my $start_time = $args{start};
    my $time_diff = tv_interval($start_time);
    return $time_diff;
}

################
# package main #
################
package main;

# pragmas
use strict;
use warnings;

# system modules
use XML::Fast;
use XML::LibXML;
use XML::Parser;
use XML::Parser::EasyTree;
use XML::Tiny;
use XML::TreePP;
use XML::Twig;
use XML::XML2JSON;

use Data::Dumper;
$Data::Dumper::Indent = 1;
$Data::Dumper::Sortkeys = 1;
$Data::Dumper::Terse = 1;

    my %elapsed_times;
    my $data = <<'DATA';
<?xml version="1.0" encoding="UTF-8"?>
<idgames-response version="1.0"><content><id>1243</id><title></title><dir>utils/level_edit/</dir><filename>doomed42.zip</filename><size>201047</size><age>791452800</age><date>1995-01-30</date><author></author><email></email><description></description><credits></credits><base></base><buildtime></buildtime><editors></editors><bugs></bugs><textfile><![CDATA[Yes, the LONG awaited release of DoomEd, 4.2.

Written by Geoff Allan, requires Windows 3.1 or above.

Very solid editor, works with Doom 1 or Doom 2. Allows you to view 
Heretic maps, but the Heretic lists aren't in here yet. Look for it soon.
]]></textfile><rating>2.0000</rating><votes>7</votes><url>http://www.doomworld.com/idgames/?id=1243</url><idgamesurl>idgames://1243</idgamesurl><reviews><review><text>How would this be a "LONG awaited" release? Its a buggy peice of shit!</text><vote>0</vote></review><review><text>The automatic bug generator. -Giest118</text><vote>0</vote></review><review><text>+1</text><vote>5</vote></review></reviews></content></idgames-response>
DATA

    # create a config object
    my $cfg = XMLDemo::Config->new();

    # create a logger object, and prime the logfile for this session
    my $log = XMLDemo::Logger->new($cfg);
    $log->timelog(qq(INFO: Starting xml_demo.pl, version $VERSION));
    $log->timelog(qq(INFO: my PID is $$));

    my $data_length = length($data);
    $log->timelog(qq|INFO: data length is $data_length byte(s)|);
    my ($xml, $document, $module, $start_timer, $elapsed_time);

    # XML::Twig
    $module = q(XML::Twig);
    $xml = $module->new();
    $start_timer = $log->start_timer();
    $document = $xml->parse($data);
    $elapsed_time = $log->stop_timer(start => $start_timer);
    $log->header_dump(
        header       => $module,
        document     => $document,
        elapsed_time => $elapsed_time,
    );
    $elapsed_times{$module} = $elapsed_time;

    # XML::LibXML
    $module = q(XML::LibXML);
    #$xml = $module->new();
    $start_timer = $log->start_timer();
    $xml = $module->load_xml(string => \$data);
    my $document = $xml->documentElement();
    #$xml->load_xml(string => \$data);
    #$document = $xml->findnodes( '/idgames-response/content' );
    $elapsed_time = $log->stop_timer(start => $start_timer);
    $log->header_dump(
        header       => $module,
        document     => $document,
        elapsed_time => $elapsed_time,
    );
    $elapsed_times{$module} = $elapsed_time;

    # XML::Parser - Tree mode
    $module = q(XML::Parser);
    $start_timer = $log->start_timer();
    $xml = $module->new( Style => q(Tree) );
    $document = $xml->parse($data);
    $elapsed_time = $log->stop_timer(start => $start_timer);
    $log->header_dump(
        header       => $module . q( - Tree mode),
        document     => $document,
        elapsed_time => $elapsed_time,
    );
    $elapsed_times{$module . q(::Tree)} = $elapsed_time;

    # XML::Parser - Object mode
    $module = q(XML::Parser);
    $start_timer = $log->start_timer();
    $xml = $module->new( Style => q(Objects) );
    $document = $xml->parse($data);
    $elapsed_time = $log->stop_timer(start => $start_timer);
    $log->header_dump(
        header       => $module . q( - Objects mode),
        document     => $document,
        elapsed_time => $elapsed_time,
    );
    $elapsed_times{$module . q(::Objects)} = $elapsed_time;

    #XML::Fast
    $module = q(XML::Fast);
    $start_timer = $log->start_timer();
    my $hashed_xml = xml2hash($data),
    $elapsed_time = $log->stop_timer(start => $start_timer);
    $log->header_dump(
        header => $module,
        document => $hashed_xml,
        elapsed_time => $elapsed_time,
    );
    $elapsed_times{$module} = $elapsed_time;

    #XML::Parser::EasyTree;
    $module = q(XML::Parser);
    $start_timer = $log->start_timer();
    $xml = $module->new( Style => q(EasyTree) );
    $document = $xml->parse($data);
    $elapsed_time = $log->stop_timer(start => $start_timer);
    $log->header_dump(
        header       => $module . q( - EasyTree mode),
        document     => $document,
        elapsed_time => $elapsed_time,
    );
    $elapsed_times{$module . q(::EasyTree)} = $elapsed_time;

    #XML::Tiny;
    #XML::TreePP;
    #XML::XML2JSON;

    $log->log(qq(\nElapsed times table:));
    foreach my $key ( sort(keys(%elapsed_times)) ) {
format STDOUT =
- @<<<<<<<<<<<<<<<<<<<<< -> @<<<<<<<<<<<<<<<<<<<
$key, $elapsed_times{$key}
.
        write();
    }
=head1 AUTHOR

Brian Manning, C<< <brian at xaoc dot org> >>

=head1 BUGS

Please report any issues/bugs or feature requests to
C<< <https://github.com/spicyjack/perl-scripts/issues> >>.

=head1 SUPPORT

You can find documentation for this script with the perldoc command.

    perldoc xml_demo.pl

=head1 COPYRIGHT & LICENSE

Copyright (c) 2013 Brian Manning, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut

# fin!
# vim: set shiftwidth=4 tabstop=4
