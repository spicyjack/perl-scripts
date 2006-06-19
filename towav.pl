#!/usr/bin/perl

# script to convert SHN/FLAC files to WAV files for burning to CD
# $Id$

use strict;
use warnings;
use Getopt::Long;
use File::Find;

my ($count, $result, $output_dir, @input_dirs, $create_output_dir);

$result = GetOptions("o|output|outputdir=s" => \$output_dir,
                    "i|dir|inputdir=s" => \@input_dirs,
                    "c|create|createoutdir" => \$create_output_dir);

# check to see if an out directory was specified
if ( defined $output_dir || ! defined $create_output_dir ) {
    if ( ! -w $output_dir ) {
        # output directory doesn't exist/is not writeable; complain and exit 
        warn qq(Output directory path does not exist, or output directory\n)
            . qq('$output_dir' is not writeable!\n);
    } # if ( ! -w $output_dir )
} else {
    # no output dir passed in; show the script usage
    &show_usage;
} # if ( defined $output_dir )

# add the current working directory if no input directories were specified
if ( scalar(@input_dirs) == 0 ) {
    push(@input_dirs, q(.));
} # if ( scalar(@input_dirs) == 0 )

# call find on each directory to search
find(\&found, @input_dirs);

exit 0;

sub found {
    # $_ is the current file
    # $File::Find::dir is the current directory
    # $File::Find::name is the full path to the current file

    # create the output directory if it doesn't exist
    if ( ! -d $main::output_dir ) { mkdir($main::output_dir); }
    my $cmd;
    SWITCH: {
        if ( $_ =~ /\.shn$/ ) {
            $cmd = q(/usr/bin/shnconv -o wav -d ) 
                . $main::output_dir . qq( "$_");
            last SWITCH;
        } # if ( $_ =~ /\.shn$/ )
        if ( $_ =~ /\.flac$/ ) {
            my $newfile = $_;
            $newfile =~ s/\.flac$/.wav/;
            $cmd = qq(/usr/bin/flac -d -c "$_" > ) 
                . $main::output_dir . q(/") . $newfile . q(");
            last SWITCH; 
        } # if ( $_ =~ /\.flac$/ )
    } # SWITCH
    print qq(Command: $cmd\n);
    #system($cmd);
} # sub found
