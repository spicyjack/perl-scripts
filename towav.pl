#!/usr/bin/perl

# script to convert SHN/FLAC files to WAV files for burning to CD
# $Id$

# to do a whole directory of shows...
# for DIR in $(find . -type d -maxdepth 1| grep [a-zA-Z]); do CLEAN=$(echo
# ${DIR} | sed 's/^\.\///'); perl ~/cvs/perl_scripts/towav.pl -i $CLEAN/ -o
# /home/brian/out/$CLEAN/ -c; done

use strict;
use warnings;
use Getopt::Long;
use File::Find;

my ($count, $result, $output_dir, @input_dirs,
    $create_output_dir, $help, $debug);

$result = GetOptions( q(h|help) => \$help,
                    q(d|debug) => \$debug,
                    q(o|output|outdir|outputdir=s) => \$output_dir,
                    q(i|dir|indir|inputdir=s) => \@input_dirs,
                    q(c|create|createoutdir) => \$create_output_dir);

# show the usage instructions¿
if ( defined $help ) {
    &show_usage( exit_status => 0 );
}

# check to see if an out directory was specified
if ( defined $output_dir ) {
    # create the output directory if it doesn't exist
    if ( ! -d $output_dir ) { mkdir($output_dir); }
    if ( ! -w $output_dir ) {
        # output directory doesn't exist/is not writeable; complain and exit 
        die qq(ERROR: path '$output_dir'\n)
            . qq(does not exist, or is not writeable!\n);
    } # if ( ! -w $output_dir )
} else {
    # no output dir passed in; show the script usage
    warn qq(ERROR: no output directory specified (use '--outdir')\n);
    &show_usage( exit_status => 1 );
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

    my $cmd;
    if ( defined $debug ) { warn qq(found: current file is '$_'\n); }
    # remove trailing slash (if present)
    $output_dir =~ s#/$##;
    # massage the input filename 
    my $newfile = $_;
    $newfile =~ s/ -/-/g;  # space dash -> dash
    $newfile =~ s/- /-/g;  # space dash -> dash
    $newfile =~ s/  *\(/\(/g; # multiple spaces left parens -> left parens
    $newfile =~ s/\((.*)\)/-$1/g; # left/right parens -> dash
    $newfile =~ s/  */ /g; # multiple spaces -> one space
    $newfile =~ s/ \././g; # space dot -> dot
    $newfile =~ s/\. //g; # dot space -> (nothing)
    $newfile =~ s/ /_/g; # space -> underscore
    SWITCH: {
        if ( $_ =~ /\.shn$/ ) {
            $cmd = qq(if [ ! -e $newfile ]; then cp "$_" $newfile; fi; )
                . q(/usr/bin/shnconv -o wav -d ) 
                . $output_dir . q( ) . $File::Find::dir . q(/) . $newfile
                . qq(;rm $newfile);
            last SWITCH;
        } # if ( $_ =~ /\.shn$/ )
        if ( $_ =~ /\.flac$/ ) {
            $newfile =~ s/\.flac$/.wav/;
            $cmd = qq(/usr/bin/flac -d -c "$_" > ) 
                . $output_dir . q(/) . $newfile;
            last SWITCH; 
        } # if ( $_ =~ /\.flac$/ )
    } # SWITCH

    # if $cmd is undefined, the current file didn't match any of the searches
    # above
    if ( defined $cmd ) {
        if ( defined $debug ) {
            print qq(Command: $cmd\n);
        } else {
            system($cmd);
        } # if ( defined $debug )
    } # if ( defined $cmd )

} # sub found

sub show_usage {
    my %args = @_;

    my $exit_status = $args{exit_status} || 1;
    warn qq(Usage: towav.pl [options]\n);
    warn qq(  [options] may consist of:\n);
    warn qq(  -h|--help\t\tShow this help menu\n);
    warn qq(  -o|--outdir\t\tDirectory to write output .wav files to\n);
    warn qq(  -c|--createoutputdir\tCreate output directory )
        . qq(if it doesn't exist\n);
    warn qq(  -i|--indir\t\tDirectories to read input files from\n);
    warn qq(    '--indir' can be used multiple times\n);
    exit $exit_status;
} # sub show_usage
