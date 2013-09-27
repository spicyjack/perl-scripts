#!/usr/bin/env perl

# Copyright (c) 2013 by Brian Manning <brian at xaoc dot org>

# For support with this file, please file an issue on the GitHub issue tracker
# for this project: https://github.com/spicyjack/perl-scripts/issues

=head1 NAME

B<utf8_lint_demo.pl> - Demo working with C<UTF-8> encoded bytes

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';

=head1 SYNOPSIS

 perl utf8_lint_demo.pl [OPTIONS]

 Script options:
 -h|--help          Shows this help text
 -d|--debug         Debug script execution
 -v|--verbose       Verbose script execution
 -c|--colorize      Always colorize script output

 Other script options:
 -f|--file          External files to parse for UTF-8-encoded bytes

 Example usage:

 utf8_lint_demo.pl --file /path/to/a/file \

You can view the full C<POD> documentation of this file by calling C<perldoc
utf8_lint_demo.pl>.

=cut

our @options = (
    # script options
    q(debug|d),
    q(verbose|v),
    q(help|h),
    q(colorize|c), # always colorize output

    # other options
    q(file|f=s),
);

=head1 DESCRIPTION

B<utf8_lint_demo.pl> - Demo working with C<UTF-8> encoded bytes.  Parse bytes
looking for valid and invalid C<UTF-8> encoded bytes.

=head1 OBJECTS

=head2 UTF8Test::Config

An object used for storing configuration data.

=head3 Object Methods

=cut

#############################
# UTF8Test::Config #
#############################
package UTF8Test::Config;
use strict;
use warnings;
use Getopt::Long;
use Log::Log4perl;
use Pod::Usage;
use POSIX qw(strftime);

=over

=item new( )

Creates the L<UTF8Test::Config> object, and parses out options using
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
    $parser->getoptions( \%args, @options );

    # assign the args hash to this object so it can be reused later on
    $self->{_args} = \%args;

    # dump and bail if we get called with --help
    if ( $self->get(q(help)) ) { pod2usage(-exitstatus => 1); }

    # return this object to the caller
    return $self;
}

=item get($key)

Returns the scalar value of the key passed in as C<key>, or C<undef> if the
key does not exist in the L<UTF8Test::Config> object.

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

Sets in the L<UTF8Test::Config> object the key/value pair passed in as
arguments.  Returns the old value if the key already existed in the
L<UTF8Test::Config> object, or C<undef> otherwise.

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

    # Can't use Log4perl here, since it hasn't been set up yet
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

=back

=cut

sub get_args {
    my $self = shift;
    # hash-ify the return arguments
    return %{$self->{_args}};
}

################
# package main #
################
package main;
use 5.010;
use strict;
use warnings;
use utf8;
use Carp;
use Log::Log4perl qw(get_logger :no_extra_logdie_message);
use Log::Log4perl::Level;

    binmode(STDOUT, ":utf8");
    #my $catalog_file = q(/srv/www/purl/html/Ural_Catalog/UralCatalog.xls);
    # create a logger object
    my $cfg = UTF8Test::Config->new();

    # Start setting up the Log::Log4perl object
    my $log4perl_conf = qq(log4perl.rootLogger = WARN, Screen\n);
    if ( $cfg->defined(q(verbose)) && $cfg->defined(q(debug)) ) {
        die(q(Script called with --debug and --verbose; choose one!));
    } elsif ( $cfg->defined(q(debug)) ) {
        $log4perl_conf = qq(log4perl.rootLogger = DEBUG, Screen\n);
    } elsif ( $cfg->defined(q(verbose)) ) {
        $log4perl_conf = qq(log4perl.rootLogger = INFO, Screen\n);
    }

    # Use color when outputting directly to a terminal, or when --colorize was
    # used
    if ( -t STDOUT || $cfg->get(q(colorize)) ) {
        $log4perl_conf .= q(log4perl.appender.Screen )
            . qq(= Log::Log4perl::Appender::ScreenColoredLevels\n);
    } else {
        $log4perl_conf .= q(log4perl.appender.Screen )
            . qq(= Log::Log4perl::Appender::Screen\n);
    }

    $log4perl_conf .= qq(log4perl.appender.Screen.stderr = 1\n)
        . qq(log4perl.appender.Screen.utf8 = 1\n)
        . qq(log4perl.appender.Screen.layout = PatternLayout\n)
        . q(log4perl.appender.Screen.layout.ConversionPattern )
        # %r: number of milliseconds elapsed since program start
        # %p{1}: first letter of event priority
        # %4L: line number where log statement was used, four numbers wide
        # %M{1}: Name of the method name where logging request was issued
        # %m: message
        # %n: newline
        . qq|= [%8r] %p{1} %4L (%M{1}) %m%n\n|;
        #. qq( = %d %p %m%n\n)
        #. qq(= %d{HH.mm.ss} %p -> %m%n\n);

    # create a logger object, and prime the logfile for this session
    Log::Log4perl::init( \$log4perl_conf );
    my $log = get_logger("");

    # print a nice banner
    $log->info(qq(Starting utf8_lint_demo.pl, version $VERSION));
    $log->info(qq(My PID is $$));

    use constant {
        # flags for checking for multi-byte UTF-8 characters
        UTF8_NO_CHECK_FLAG                => 0,
        UTF8_ONE_BYTE_FLAG                => 1,
        UTF8_TWO_BYTE_FLAG                => 2,
        UTF8_THREE_BYTE_FLAG              => 3,
        #UTF8_CHECK_TAIL_BYTE_FLAG => 2,
        # use an XOR with these?
        UTF8_ONE_BYTE_UPPER               => 0x7f,
        UTF8_TAIL_BYTE_LOWER              => 0x80,
        UTF8_TAIL_BYTE_UPPER              => 0xbf,
        UTF8_TWO_BYTE_LOWER               => 0xc0,
        UTF8_TWO_BYTE_UPPER               => 0xdf,
        UTF8_THREE_BYTE_LOWER             => 0xe0,
        UTF8_THREE_BYTE_UPPER             => 0xef,

        UTF8_FOUR_BYTE_LOWER              => 0xf0,
        UTF8_FOUR_BYTE_UPPER              => 0xf4,
    };
    # 0x10ffff is the last code point in UTF-8, but it's not a valid code
    # point
    # http://www.unicode.org/charts/PDF/U10FF80.pdf
    # http://www.fileformat.info/info/unicode/char/10ffff/index.htm

=begin COMMENT

http://en.wikipedia.org/wiki/Unicode
Code points in the range U+D800..U+DBFF (1,024 code points) are known as
high-surrogate code points, and code points in the range U+DC00..U+DFFF (1,024
code points) are known as low-surrogate code points. A high-surrogate code
point (also known as a leading surrogate) followed by a low-surrogate code
point (also known as a trailing surrogate) together form a surrogate pair used
in UTF-16 to represent 1,048,576 code points outside BMP. High and low
surrogate code points are not valid by themselves. Thus the range of code
points that are available for use as characters is U+0000..U+D7FF and
U+E000..U+10FFFF (1,112,064 code points). The value of these code points (i.e.
excluding surrogates) is sometimes referred to as the character's scalar value.

=end COMMENT

=cut

    my $utf8_check_flag = UTF8_NO_CHECK_FLAG;
    my $utf8_byte_counter = 0;
    my @check_numbers = (
        0xf3,             # illegal one byte seq., ISO-8859-1
        0xe1,             # illegal one byte seq., ISO-8859-1
        0x66,             # legal one byte seq., ASCII 'f'
        0xc3, 0xa1,       # legal two byte seq., 'a with agrave'
        0xe2, 0x99, 0xa8, # legal three byte seq., 'buntu/hot springs (U+2668)
        0xc0, 0x80,       # illegal as per RFC3629
        0xed, 0xa1, 0x8c, 0xed, 0xbe, 0xb4, # illegal surrogate pairs
    );
    foreach my $number ( @check_numbers ) {
        #say sprintf(q(Testing number: 0x%0.2x/0b%0.8b), $number, $number);
        if ( $number < UTF8_ONE_BYTE_UPPER ) {
            if ( $utf8_byte_counter > 0 ) {
                $log->error("Expecting multi-byte number, found new character");
                $utf8_byte_counter = 0;
            }
            say(sprintf(q(%u/%u: 0x%0.2x/0b%0.8b),
                $utf8_byte_counter, UTF8_ONE_BYTE_FLAG, $number, $number));
            $utf8_byte_counter = 0;
            $utf8_check_flag = UTF8_NO_CHECK_FLAG;
        } elsif ( $number > UTF8_TAIL_BYTE_LOWER
            && $number < UTF8_TAIL_BYTE_UPPER  ) {
            $utf8_byte_counter++;
            say(sprintf(q(%u/%u: 0x%0.2x/0b%0.8b),
                $utf8_byte_counter, $utf8_check_flag, $number, $number));
            if ( $utf8_byte_counter > $utf8_check_flag ) {
                $log->error(q(Recieved too many bytes )
                    . q(for this UTF-8 character));
                $utf8_byte_counter = 0;
                $utf8_check_flag = UTF8_NO_CHECK_FLAG;
            } elsif ( $utf8_byte_counter == $utf8_check_flag ) {
                # found the correct amount of bytes, reset counters/flags
                $utf8_byte_counter = 0;
                $utf8_check_flag = 0;
            }
        } elsif ( $number > UTF8_TWO_BYTE_LOWER
            && $number < UTF8_TWO_BYTE_UPPER  ) {
            # set a flag with the number 2 for two bytes
            $utf8_check_flag = UTF8_TWO_BYTE_FLAG;
            # FIXME move this to the top of the block with the check for the
            # continuation byte, so we know if when we get a continuation
            # byte, it's a valid continuation byte?
            if ( $utf8_byte_counter > 0 ) {
                $log->error(
                    q(Found new leading character in a multi-byte sequence));
                $log->error(sprintf(q(Sequence counter: %u/%u),
                    $utf8_byte_counter, $utf8_check_flag));
                $log->error(sprintf(q(Offending byte: 0x%0.2x), $number));
            }
            $utf8_byte_counter++;
            say(sprintf(q(%u/%u: 0x%0.2x/0b%0.8b),
                $utf8_byte_counter, $utf8_check_flag, $number, $number));
        } elsif ( $number > UTF8_THREE_BYTE_LOWER
            && $number < UTF8_THREE_BYTE_UPPER  ) {
            # set a flag with the number 2 for two bytes
            $utf8_check_flag = UTF8_THREE_BYTE_FLAG;
            # FIXME move this to the top of the block with the check for the
            # continuation byte, so we know if when we get a continuation
            # byte, it's a valid continuation byte?
            if ( $utf8_byte_counter > 0 ) {
                $log->error(
                    q(Found new leading character in a multi-byte sequence));
                $log->error(sprintf(q(Sequence counter: %u/%u),
                    $utf8_byte_counter, $utf8_check_flag));
                $log->error(sprintf(q(Offending byte: 0x%0.2x), $number));
            }
            $utf8_byte_counter++;
            say(sprintf(q(%u/%u: 0x%0.2x/0b%0.8b),
                $utf8_byte_counter, $utf8_check_flag, $number, $number));
        } else {
            $log->error(
                q(Found illegal character));
            $log->error(sprintf(q(Sequence counter: %u/%u),
                $utf8_byte_counter, $utf8_check_flag));
            $log->error(sprintf(q(Offending byte: 0x%0.2x), $number));
        }
    }

=head1 AUTHOR

Brian Manning, C<< <brian at xaoc dot org> >>

=head1 BUGS

Please report any bugs or feature requests to the GitHub issue tracker for
this project:

C<< <https://github.com/spicyjack/perl-scripts/issues> >>.

=head1 SUPPORT

You can find documentation for this script with the perldoc command.

    perldoc utf8_lint_demo.pl

=head1 COPYRIGHT & LICENSE

Copyright (c) 2013 Brian Manning, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut

# fin!
# vim: set shiftwidth=4 tabstop=4
