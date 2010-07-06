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

    binmode STDOUT, ":utf8";

    # - get a count of how many members each structure has
    # - get a random number between 0 and the number of members in the
    # structure
    # - grab the string that matches the random number
    # - print it out
