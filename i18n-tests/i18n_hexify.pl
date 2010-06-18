#!/usr/bin/perl -w

# random_words.pl

# read a text file full of words and their definitions, separated by a comma,
# then choose a random number of words based on the user's input

# notes:
# http://ahinea.com/en/tech/perl-unicode-struggle.html

use strict;
use warnings;
use utf8;
use Encode;
use Getopt::Long;
use IO::File;

    my ($input_file, $num_of_words);
    my $parser = Getopt::Long::Parser->new();
    $parser->getoptions(
        q(inputfile|filename|f=s) => \$input_file,
    ); # $parser->getoptions
    
    my $INFD;
    # set UTF-8 on STDOUT to keep perl from bitching
    binmode STDOUT, ":utf8";
    if ( defined $input_file ) {
        $INFD = IO::File->new(qq( < $input_file));
    } else {
        $INFD = IO::Handle->new_from_fd(fileno(STDIN), q(<));
    } # if ( length($parsed{input}) > 0 )
    my @lines=<$INFD>;
    my $counter = 0;

    foreach my $line (@lines) {
        # skip commented lines
        next if ( $line =~ /^#/ );
        chomp($line);
        #print $line . qq(\n);
        my $decoded_line = decode_utf8($line);
        my @word = split(//, $decoded_line);
        my $hexword = q();
        foreach my $letter ( @word ) {
            $hexword .= sprintf(q(0x%0x), ord($letter)) . q( );
        } # foreach my $letter ( @word )
        # trim any trailing spaces
        $hexword =~ s/\s+$//;
        print qq|$decoded_line ($hexword)\n|;
    } # foreach my $line (@lines)

