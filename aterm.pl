#!/usr/bin/perl -w

# script to start aterm with a random transparency setting

#use strict

$numcolors = 6;
%colors = (  1 => "blue",
                2 => "green",
                3 => "red",
                4 => "yellow",
                5 => "magenta",
                6 => "cyan");

$numtypes = "11";
%types = (   1 => "and",
                2 => "andReverse",
                3 => "andInverted",
                4 => "xor",
                5 => "or",
                6 => "nor",
                7 => "invert",
                8 => "equiv",
                9 => "orReverse",
                10 => "orInverted",
                11 => "nand");

srand time;
my $colorkey = int ( rand ($numcolors) +1);
my $typekey = int (rand ($numtypes) +1);
my $tint = $colors{$colorkey};
my $type = $types{$typekey};
if (scalar(@ARGV) > 0) { 
    exec("aterm -tr -tinttype $type -tint $tint &");
    } else {
    exec("aterm -tr -tinttype and -tint $tint & ");
}

