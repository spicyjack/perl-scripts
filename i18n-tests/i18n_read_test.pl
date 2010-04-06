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
        q(number|n=i) => \$num_of_words,
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
        my @words = split(q(,), $decoded_line);
        my ($imperfective, $perfective, $word, $definition);
        if ( scalar(@words) == 2 ) {
            # only two elements, assign it to word and definition
            ($word, $definition) = @words;
        } else {
            # first element is the imperfective word
            $imperfective = shift(@words);
            # second element is the perfective word
            $perfective = shift(@words);
            # combine the rest of the word chunks back up
            $definition = join(q(,), @words);
        } # if ( scalar(@words) == 2 )
        # run decode_utf8 on the word before we split it into characters
        #my $new_word = decode_utf8($word);
        # split on the null string, aka split on characters
        #my @word = split(//, $new_word);
        if ( defined $imperfective ) {
            $word = $imperfective;
        } # if ( defined $imperfective )
        my @word = split(//, $word);
        my $hexword = q();
        foreach my $letter ( @word ) {
            $hexword .= sprintf(q(0x%0x), ord($letter)) . q( );
        } # foreach my $letter ( @word )
        # trim any trailing spaces
        $hexword =~ s/\s+$//;
        if ( defined $perfective && length($perfective) > 0 ) {
            print qq|$word, $perfective : $definition ($hexword) \n|;
        } else {
            print qq|$word : $definition ($hexword) \n|;
        } # if ( defined $perfective )
    }

