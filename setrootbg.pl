#/usr/bin/perl -w

# sets a picture on the root window
# uses xv, and reads from $ROOTS_DIR

# set the HUP handler to the changeroot sub
# the TERM exits the program
$SIG{HUP} = \&changeroot(&getrandomfile);
$SIG{TERM} = exit 0;

# path to backrounds, no trailing slashes please
ROOTS_DIR="/usr/share/root_bgs";

# load the filename stack
load_stack();

while (1) {
    &changeroot(&getrandomfile);
    sleep 900; # 900 seconds = 15 minutes
} # while

# subroutines

# load the picture file stack
sub load_stack {
    # open a list of files in $ROOTS_DIR
    # then push them all into a stack structure
    # return the stack array
}

sub changeroot {
    $FILE = $_[0];
    system("/usr/bin/X11/xv -root -quit -max $ROOTS_DIR/$FILE");
} # sub changeroot

sub getrandomfile {
# get the total number of the array
# pick a number between 1 and total for the filename
# pop that file off of the stack
# return the filename
}
