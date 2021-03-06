#!/usr/bin/perl -w

# created 07/21/01 for resizing images
# (C) 2003 by Brian Manning <brian {at} antlinux.com>
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307 USA 

# TODO's 
# - add a switch that allows you to create 'thumbnails' of other file types,
# i.e. ASF files.  This would let you apply comments to the movie files,
# detailing what the movie file contains
# - instead of adding a switch for thumbnails of other file types, build a
# plugin system; as new filetypes are found, new plugins can be written or
# existing plugins tied to the new file type
# - the plugin for the Canon CRW format will need the 'dcraw' program, as well
# as the 'netpbm' package for PPM->JPG conversion

# - add a switch that specifies two columns of thumbnails or three; the Canon
# thumbnails are good for two columns, the Kodak is good for 3; or maybe change
# the size of the pictures somehow; the canon movie thumbnails are 160x120,
# make the regular thumbnails that size as well, so that all of the thumbnails
# from either camera look the same
# - add switches to specify the size of the thumbnails; this goes along with
# the above todo in that if you specify smaller thumbnails, you can make more
# columns of thumbnails

# - add the original pixel size of the image to the file size of the image
# links
# - add the file name to the orignal date line in the HTML output
# - detect the canon movie thumbnails, rename/symlink them and add a movie icon
# in the description for the file
# - lowercase filenames
# - split conversion from writing the web page, so that all of the files are
# converted first and stored in an array/hash, then written to a web page

# shell one-liner file extension renamer:
# for x in *.THM; do y=$(ls ${x} | sed 's/THM$/JPG/'); mv $x $y; done
#
# shell one-liner for using dcraw to create jpegs
# dcraw -c -w -2 CRW_2634.CRW | pnmtojpeg --progressive > crw_2634.23x17.jpg
#
# shell one-liner to convert to a smaller size image
# time convert -resize 800x600 oldfile newfile
#
# for x in *.crw; do  y=$(ls ${x} | sed 's/crw$/26x19.jpg/'); dcraw -c -w -2 $x
# | pnmtojpeg --progressive > 26x19/$y ; done
#
# for x in *.jpg; do  y=$(ls ${x} | sed 's/26x19/8x6/'); convert -resize 800x600
# $x ../8x6/$y ; done

# time convert -resize 25% indian_hill-panoramic-1.jpg
# indian_hill-panoramic-1-25pct.jpg

# for x in *.crw; do  y=$(ls ${x} | sed 's/crw$/26x19.jpg/'); dcraw -c -w -2 $x|
# convert pnm:- jpg:26x19/$y ; done

# for FILE in *.tiff; do NEW=$(ls ${FILE} | sed 's/tiff/jpg/'); echo -e
# "Converting $FILE\nto $NEW"; convert $FILE $NEW; done
# use directives
use Getopt::Std;

# begin
my (%opts, %captions);
&getopts("dhnp:c:", \%opts);
@filedir= <*>;
$start = time;
$counter = 1;
$column = 1;
$row = 1;
# if the user called -p, then set BASEPATH to whatever the user input
if ( exists $opts{p} ) { $BASEPATH=$opts{p}; } else { $BASEPATH="/usr/bin";}
$DJPEG = "$BASEPATH/djpeg";
$CJPEG = "$BASEPATH/cjpeg";
$WRJPGCOM = "$BASEPATH/wrjpgcom";
$RDJPGCOM = "$BASEPATH/rdjpgcom";

$TAG="Brian Manning, All Rights Reserved.  Use with permission only.";

    # check for command line options
	if ( exists $opts{h} ) { &ShowHelp(); } # if ( exists $opts{h} )

    if ( exists $opts{c} ) { &read_captions; }
    if ( exists $opts{d} ) { $DEBUG = 1; }

    # check for existence of cjpeg and djpeg, and wrjpegcom
    if ( ! -x $DJPEG || ! -x $CJPEG || ! -x $WRJPGCOM || ! -x $RDJPGCOM) {
        warn "Sorry, you are missing the following files that this script\n"
                . "needs to run:\n";
        if ( ! -x $DJPEG ) { warn "missing $DJPEG"; }
        if ( ! -x $CJPEG ) { warn "missing $CJPEG"; }
        if ( ! -x $WRJPGCOM ) { warn "missing $WRJPGCOM"; }
        if ( ! -x $RDJPGCOM ) { warn "missing $RDJPGCOM"; }
        die "Please install the missing files, and re-run this script.\n";
    } # if ( ! -x $DJPEG || ! -x $CJPEG || ! -x $WRJPGCOM )
    
    # open the output HTML page
    open (OUT, "> index.html") || die "Can't open 'index.html for writing";

    # add the required HTML code
    print OUT "<HTML>\n<HEAD>\n";
    print OUT "<TITLE>Thumbnail Page</TITLE>\n";
    print OUT "<style><!--\n";
    print OUT "BODY { font-family: Verdana, Helvetica, Lucida, Tahoma;\n";
    print OUT "         background: white;}\n";
    print OUT "SPAN.pixnum,TD.pixnum { background: #d4d3ff; }\n";
    print OUT "SPAN.pixlinks,TD.pixlinks { background: #daffdd; }\n";
    print OUT "SPAN.pixcap,TD.pixcap { background: #fffcd2; }\n";
    print OUT "--></style>\n";
    print OUT "</HEAD>\n";
    print OUT "<BODY>\n\n";

    print OUT   "<h3>Thumbnail Page - Click on any of below links to get a " .
                "larger image.</h3>\n\n";

    # add table borders if we are debugging
    if ( $DEBUG ) {
        print OUT "<center><table border=1 cols=3 width=\"95%\" >\n";
    } else {
        print OUT "<center><table border=0 cols=3 width=\"95%\" >\n";
    } # if ( $DEBUG )
    
    print OUT "<tr align=\"center\" valign=\"center\">\n";

    # loop the directory, converting all the files found
    foreach $oldname (@filedir) {
        # rename/retag all of the JPEGs first
        # FIXME separate the HTML writing from the JPEG mangling.  This is so
        # we can also do movie files in the output HTML as well as JPEGs
        # Maybe parse the files in the directory by the image number (s/\D//),
        # so that the pictures/movies show up in the order they were taken in
		if ( $oldname =~ /.*jpg$/i &&
			($oldname !~ /.*half.jpg$/i && $oldname !~ /.*8th.jpg$/i) ) {
            warn "\n==================================================\n";
            warn "oldname is $oldname; converting\n";
			$renamecheck = lc($oldname);
			if ($renamecheck ne $oldname) {
				warn "lowercasing $oldname to $renamecheck\n";
				rename ($oldname, $renamecheck);
				$oldname = $renamecheck;
			} # if ($renamecheck != $oldname)
    	    $halfname = $eigthname = $oldname;
        	$halfname =~ s/\.jpg\b/.half.jpg/i;			# the token file
            $eigthname =~ s/\.jpg\b/.8th.jpg/i;
            # don't do the thumbnail loop if the halfname or 8thname files exist
            # or if we are just rebuilding the index page
            if ( ! exists $opts{n} ) {
                if ( ! -e $halfname ) {
                    warn "$halfname does not exist, converting" if $DEBUG;
                    $command = qq($DJPEG -scale 1/2 "$oldname")
                        . qq(| $CJPEG >"$halfname");
	                system($command);
                } # if ( ! -e $halfname )
                if ( ! -e $eigthname ) {
                    warn "$eigthname does not exist, converting" if $DEBUG;
                    $command = qq($DJPEG -scale 1/8 "$oldname")
                        . qq(| $CJPEG >"$eigthname");
	                system($command);
                } # if ( ! -e $eigthname )
            } # if ( ! -e $halfname || ! -e $eigthname )

            # tag the files unless we're just rebuilding the index page
            if ( ! defined $opts{n} ) {
                &jpegtag($oldname);
                &jpegtag($halfname);
                &jpegtag($eigthname);
            } # if ( ! defined $opts{h} )

            warn "adding $oldname -> $halfname -> $eigthname\n" .
                 "to html file in row $row, column $column";

            # a table cell that holds the thumbnail and the 2nd table
            print OUT "<td>\n";
            print OUT "<a href=\"$oldname\" target=\"_new\">\n";
            print OUT "<img src=\"$eigthname\" ";
            print OUT  &imagesizes($eigthname);
            if ( defined $captions{$oldname} ) {
                print OUT "alt=\"" . $captions{$oldname} . "\">";
            } else {
                print OUT ">";
            } # if ( defined $captions{$oldname} )
            print OUT "\n</a>\n";
            # second table with the text and links about the thumbnail
			$textrow .= "<!-- begin text table --><td valign=top>\n";
			$textrow .= "<table width=\"100%\">\n<tr><td class=\"pixnum\">";
            # the image number and mtime
            $textrow .= "#$counter - " . &filedate($oldname, "fulldate");
            $textrow .= "\n</td></tr>\n";
            # the links 
            $textrow .= "<tr><td class=\"pixlinks\">\n";
            $textrow .= "<a href=\"$oldname\" target=\"_new\">";
            $textrow .= "Link to full size image</a> (";
            $textrow .= &filesize($oldname) . "kB) <br>\n";
            $textrow .= "<a href=\"$halfname\" target=\"_new\">";
            $textrow .= "Link to half size image</a> (";
            $textrow .= &filesize($halfname) . "kB) ";
            $textrow .= "\n</td></tr>\n";
            # and the caption, if one exists
            if ( exists $captions{$oldname} ) {
                $textrow .= "<tr><td class=\"pixcap\">" . $captions{$oldname};
                $textrow .= "</td></tr>\n";
            } # if ( exists $captions{$oldname} )
            # close the 2nd table
            $textrow .= "</table>\n";
			$textrow .= "</td><!-- end of text table -->\n";
            # close this cell
            print OUT "</td>\n";
            $column++;
            $counter++;
            # see if this is the end of a row of cells (3 cells to a row)
            if ($column == 3) {
				# close out the current row
                print OUT "</tr>\n";
				# print out the text row
				print OUT "<!-- this is the text row for row #$row-->\n";
				print OUT "<tr>\n$textrow\n</tr>\n\n";
				print OUT "<tr><td colspan=\"3\">&nbsp;</td></tr>\n";
				# reset the textrow string
				$textrow = "";
				# start a new row
                print OUT "<!-- this is row #$row-->\n";
    			print OUT "<tr align=\"center\" valign=\"center\">\n";
                $column = 1;
                $row++; 
            } # if $column == 4
        # if ( $oldname !~ /half.jpg$/ || $oldname !~ /8th.jpg$/ )
        } elsif ( $oldname =~ /.*thm$/i || $oldname =~ /.*avi$/i ) {

        } # if ( $oldname !~ /half.jpg$/ || $oldname !~ /8th.jpg$/ )
    } # foreach $oldname

    # end the table and HTML document
	print OUT "<!-- this is the text row for row #$row-->\n";
	print OUT "<tr>\n$textrow\n\n";
    print OUT "</tr>\n</table></center>\n";
    print OUT "</body>\n</html>";

    $end = time - $start;
    warn "Converted " . ($counter - 1) . " jpegs in $end seconds";

### end of main script ###

sub ShowHelp { 
		warn "Usage: thubmnails.pl [options]\n";
		warn "[options] may consist of\n";
		warn " -h show this help\n";
		warn " -d run in debug mode (extra noisy output)\n";
		warn " -n don't re-do thumbnails, just re-generate index.html page\n";
        warn " -p path to libjpeg binaries\n";
        warn " (djpeg, cjpeg, wrjpgcom, rdjpgcom)\n";
		warn " -c comments file; you can put comments into a file, and\n" . 
			 "    this script will read from that file and match filenames\n" .
			 "    with comments, and output the comments in the correct\n" .
			 "    place in the HTML.  The file format goes like this:\n\n" .
			 "# this is a comment line\n".
			 "filename.jpg==this is the comment that will be applied to " .
			 "the picture to the left of the double-equals to the left\n\n" .
			 "    NOTE: comments must be all one line, so you must use a\n" .
			 "    a text editor that does not wrap words for thie comments\n" .
			 "    file to work correctly\n\n";
		exit 0;
} # sub ShowHelp

sub filesize {
    @filestat = stat ($_[0]);
    $filesize = substr($filestat[7], 0, -3);
    return $filesize;
} # sub filesize
    
sub filedate {
# pulls file's mtime using stat()
    @filestat = stat($_[0]);
    if ( $_[1] eq "year") {
        $filedate = (localtime($filestat[9]))[5] + 1900;
    } elsif ( $_[1] eq "mtime" ) {
        $filedate = $filestat[9];
    } else { 
        $filedate = localtime($filestat[9]);
    } # if ( $_[1] eq "year")
    return $filedate;
} # sub filedate

sub jpegtag {
    $JPEGTAG = "Copyright (c)" . &filedate($_[0], "year") . " " . $TAG;
    $origdate = &filedate($_[0], "mtime");
    warn  "tag will be $JPEGTAG" if $DEBUG;
    warn  "renaming $_[0] to tmp$_[0]";
    rename($_[0], "tmp$_[0]");
    warn  "adding JPEG tag";
    system("$WRJPGCOM -replace -comment \"$JPEGTAG\" tmp$_[0] > $_[0]");
    warn "deleting tmp$_[0]";
    unlink("tmp$_[0]");
    utime($origdate, $origdate, $_[0]);
} # sub jpegtag

sub read_captions {
# reads captions from an external file
# format is 
# filename==caption
    
    # set some variables
    my ($line, $capkey);

    # open the caption file
    open(CAPS, "<$opts{c}");

    # loop thru the file, splitting and adding keys/values to the captions hash
    foreach $line (<CAPS>) {
        if ( $line !~ /^#/ ) {
            $capkey = (split(/==/, $line))[0];
            warn "capkey is $capkey" if $DEBUG;
            $captions{$capkey} = (split(/==/, $line))[1];
            chomp($captions{$capkey});
        } # if ( $line !~ /^#/ )
    } # foreach $line (<CAPS>)

    # close the caption file
    close(CAPS);
} # sub read_captions

sub imagesizes {
# calls system(rdjpgcom -verbose) on a thumbnail to get width and height

    # some variables
    my ($line, @splitvar, $width, $height, @output);

    # capture the output of rdjpgcom, so we can get the width and height
    @output = `$RDJPGCOM -verbose $_[0]`;
    foreach $line ( @output ) {
        if ( $line =~ /^JPEG image/ ) {
            @splitvar = split(/ /, $line);
            $splitvar[3] =~ s/w$//;
            $splitvar[5] =~ s/h,$//;
            warn "$_[0]: width is $splitvar[3], height is $splitvar[5]" 
                if $DEBUG;
            # leave an extra space at the end of the string for other text that
            # may follow this text
            return "width=\"" . $splitvar[3] . 
                    "\" height=\"" . $splitvar[5] . "\" ";
        } # if ( $line =~ /^JPEG image/ )
    } # foreach $line ( @output )
} # sub imagesizes

# end of line
