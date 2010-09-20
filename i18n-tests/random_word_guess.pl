#!/usr/bin/perl -w

# random_words.pl

# read a text file full of words and their definitions, separated by a comma,
# then choose a random number of words based on the user's input

# notes:
# http://ahinea.com/en/tech/perl-unicode-struggle.html

package Random::Word;
use strict;
use warnings;
use utf8;

sub new {
    my $class = shift;
    my @words = @_;
   
    my $self;

    if ( scalar(@words) == 2 ) {
        # only two elements, assign it to word and definition
        my ($word, $definition) = @words;
        $self = bless({
            _word => $words[0],
            _definition => $words[1]
        }); # $self = bless
    } else {
        $self = bless({
            _imperfective => $words[0],
            _word => $words[0],
            _perfective => $words[1],
            _definition =>  join(q(,), @words),
        }); # $self = bless
    } # if ( scalar(@words) == 2 )
    return $self;
} # sub new

sub get_word {
    my $self = shift;
    return $self->{_word};
} # sub get_word 

sub get_definition {
    my $self = shift;
    return $self->{_definition};
} # sub get_word 

package main;

use strict;
use warnings;
use utf8;
use Encode;
use Getopt::Long;
use IO::File;

sub ShowHelp {
    print <<EOH;
    $0 [options]

    -f|--filename   Name of the wordlist file
    -n|--number     Number of words to loop through
    -s|--swap       Guess the definition instead of the word (for numbers)
    -h|--help       Show this help output
EOH
    exit 0;
} # sub ShowHelp

    my $input_file;
    my $num_of_words = 1;
    my $swap_words = 0;
    my $parser = Getopt::Long::Parser->new();
    $parser->getoptions(
        q(inputfile|filename|f=s) => \$input_file,
        q(number|n=i) => \$num_of_words,
        q(swap|s) => \$swap_words,
        q(help|h) => \&ShowHelp,
    ); # $parser->getoptions
    
    my $INFD;
    # set UTF-8 on STDOUT to keep perl from bitching
    binmode STDOUT, ":utf8";
    if ( defined $input_file ) {
        $INFD = IO::File->new(qq( < $input_file));
    } else {
        die qq(ERROR: no input file; run $0 --help for script options\n);
        #$INFD = IO::Handle->new_from_fd(fileno(STDIN), q(<));
    } # if ( length($parsed{input}) > 0 )
    my @lines=<$INFD>;
    my $counter = 0;

    # a list of word objects
    my @word_objs;
    foreach my $line (@lines) {
        # skip commented lines
        next if ( $line =~ /^#/ );
        chomp($line);
        #print $line . qq(\n);
        my $decoded_line = decode_utf8($line);
        my @words = split(q(,), $decoded_line);
        push(@word_objs, Random::Word->new(@words));
    } # foreach my $line (@lines)

    # loop as many times as was requested
    for ( my $x = 1; $x == $num_of_words; $x++ ) {
        # grab a random word object out of the word_objs array
        my $random_word = $word_objs[int(rand(scalar(@word_objs)))];
        if ( $swap_words ) {
            print qq(Guess the definition based on the word....\n);
            print $random_word->get_word() . q(: );
        } else {
            print qq(Guess the word based on the definition....\n);
            print $random_word->get_definition() . q(: );
        } # if ( $swap_words )
        # use the diamond operator to read in user input
        my $answer = <>;
        chomp($answer);
        if ( $swap_words ) {
            if ( $answer eq $random_word->get_definition() ) {
                print qq(Correct! $answer = ) . $random_word->get_definition() 
                    . qq(\n);
            } else {
                print qq(Incorrect! ) . $random_word->get_definition() . q( = ) 
                    . $random_word->get_word() . qq(\n);
            } # if ( $answer eq $word )
        } else {
            if ( $answer eq $random_word->get_definition() ) {
                print qq(Correct! $answer = ) . $random_word->get_definition() 
                    . qq(\n);
            } else {
                print qq(Incorrect! ) . $random_word->get_word() . q( = ) 
                    . $random_word->get_definition() . qq(\n);
            } # if ( $answer eq $word )
        } # if ( $swap_words )
    } # for ( my $x = 1; $x == $num_of_words; $x++ )

# fin!
