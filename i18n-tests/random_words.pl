#!/usr/bin/perl -w

# random_words.pl

# read a text file full of words and their definitions, separated by a comma,
# then choose a random number of words based on the user's input

use strict;
use warnings;
use utf8;
use Getopt::Long;
use IO::File;

    my ($input_file, $num_of_words);
    my $parser = Getopt::Long::Parser->new();
    $parser->getoptions(
        q(inputfile|filename|f=s) => \$input_file,
        q(number|n=i) => \$num_of_words,
    ); # $parser->getoptions
    
    my $INFD;
    if ( defined $input_file ) {
        $INFD = IO::File->new(qq( < $input_file));
    } else {
        $INFD = IO::Handle->new_from_fd(fileno(STDIN), q(<));
    } # if ( length($parsed{input}) > 0 )
    my @lines=<$INFD>;
    my $counter = 0;

    foreach my $line (@lines) {
        chomp($line);
        #print $line . qq(\n);
        my ( $word, $definition ) = split(q(,), $line);
        #print $line . q( ) . sprintf(q(%0x), $line) . qq(\n);
        print qq($word : $definition\n);
    }

