#!/usr/bin/perl -w

# 

# output a set of words from an array of choices.

use strict;
use warnings;
use utf8;
use Encode;

    my @person = <<END_PERSON =~ m/(\S.*\S)/g;
        я
        ты
        твой брат
        твоя сестра
        мы
        вы
        она
        твои родители
        американские студенты
END_PERSON

    my @verb = <<END_VERB =~ m/(\S.*\S)/g;
        нравится
        нравятся
        понравился
        понравилась
        понравилось
        понравились
END_VERB
    my 
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

