#!/usr/bin/perl -w

# sets a picture on the root window
# uses xv, and reads from $ROOTS_DIR

# set the HUP handler to the changeroot sub
# the TERM exits the program
$SIG{HUP} = \&changenow;
$SIG{TERM} = sub { exit 0 };

# path to backrounds, no trailing slashes please
$ROOTS_DIR="/usr/share/root_bgs";
#$sleep = 900; # sleep 900 seconds, or 15 minutes
$sleep = 5; # sleep 900 seconds, or 15 minutes
$DEBUG = 1;
@bigname = split("/", $0);
$myname = $bigname[-1];

# start the random number generator
srand time;

# load the filename stack
@filelist = &load_stack();

while (1) {
    &changeroot;
    # I think if sleep 900 were used here, the program would not handle signals
    for ($sleepcount=1; $sleepcount<=$sleep; $sleepcount++) {
        sleep 1;
    } # for
} # while

# subroutines

# load the picture file names onto stack
sub load_stack {
    # open a list of files in $ROOTS_DIR
    @bgfiles = </usr/share/root_bgs/*.jpg>;
    # then push them all into a stack structure
    foreach $bgfile (@bgfiles) {
        push (@filelist, $bgfile);
    } # foreach $bgfile
    # return the file list
    if ($DEBUG) {
        $filelist = @filelist;
        print "$myname: pushed $filelist files onto the stack\n";
    } # if $DEBUG
    return @filelist;
} # sub load_stack

sub changeroot {
    $FILE = &getrandomfile;
    if ($DEBUG) {print "$myname: file to make root is $FILE\n";}
    #system("/usr/bin/X11/xv -root -quit -max $ROOTS_DIR/$FILE");
} # sub changeroot

sub getrandomfile {
    # get the total number of the array
    $totalfiles = @filelist;
    # pick a number between 0 and total for the filename
    # we don't need 1-total because arrays are zero-referenced
    $filenumber = int (rand ($totalfiles));
    if ($DEBUG) {print "$myname: total files = $totalfiles\n";}
    if ($DEBUG) {print "$myname: random file number is $filenumber\n";}
    # pop that file off of the stack
    for ($filecount=0; $filecount<=$totalfiles; $filecount++) {
        #if ($DEBUG) {print "$myname: filecount = $filecount\n";}
        if ($filecount != $filenumber) { # not the file we're looking for  
            push (@tmpfiles, shift(@filelist));
            #if ($DEBUG) {print "f:@filelist\nt:@tmpfiles\n";}
        } else { # this is the file we're looking for 
            $returnfile = shift(@filelist);
            if ($DEBUG) {print "$myname: set returnfile to $returnfile\n";}
            push (@tmpfiles, shift(@filelist));
            if ($DEBUG) {&printarrays;}
        } # if $filecount
    } # for $filecount
    if ($DEBUG) {print "$myname: returning $returnfile\n";}
    @filelist = @tmpfiles;
    @tmpfiles = ();
    return $returnfile;
# return the filename
} # sub getrandomfile

sub changenow {
    # run changeroot and print to STDERR that we got HUP'ed
    print STDERR "$myname: received SIGHUP, changing root window now\n";
    &changeroot;
} # sub changeroot

sub printarrays {
    # print the contents of both arrays
            $numfiles = @filelist;
            print "f $numfiles: ";
            foreach $file (@filelist) {
                @filename = split ("/", $file);
                print $filename[-1] . " ";
            } # foreach $file
            $numfiles = @tmpfiles;
            print "\nt $numfiles:";
            foreach $file (@tmpfiles) {
                @filename = split ("/", $file);
                print $filename[-1] . " ";
            } # foreach $file
            print "\n";
} # sub printarrays
