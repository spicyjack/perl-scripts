#!/usr/bin/perl -w

use warnings;
use strict;

# created 11/22/00 for makeing web pages out of directories of pictures
# (C) 1999 by Brian Manning <brian@sunset-cliffs.org>
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

my @filedir= <*.jpg>;
my $start = time;
my $counter = 0;
my $row = 1;
my $column = 1;
my %captions;
my $captions_fh;
my $default_caption_text = q(Click outside the image or the X );
$default_caption_text .= q(to the upper right to close);

# read in photo captions, if the file exists
if ( -e q(./captions.txt) ) {
   open($captions_fh, q|<:encoding(UTF-8)|, q(./captions.txt));
   foreach my $caption_line ( <$captions_fh> ) {
      chomp $caption_line;
      my ($key, $value) = split(/\|/, $caption_line);

      # check for 'undef' $value
      $value = $default_caption_text
         unless ( defined $value );

      $captions{$key} = $value;
   }
}

my $header_text;
if ( exists($captions{header}) ) {
   $header_text = $captions{header};
} else {
   $header_text = "This is the default header text"
}

# open the output file 'index.html'
open (OUT, "> index.html");

my $head = <<EOHEAD;
<html>
<head>
<title>Thumbnail Page</title>
  <link rel="stylesheet" href="css/lightbox.min.css">
  <style>
   body {
      background-color: #332200;
      color: white;
   }
   h1 {
      color: white;
   }
   </style>
</head>
<body>

<section>
   <h3>$header_text</h3>

   <p>Click on any of the images below to view the images in a lightbox.</p>
   <p>Once the lightbox has been opened, click anywhere outside the image, or
   click on the "X" symbol in the upper right corner of the lightbox to
   close.</p>

   <div>
EOHEAD

print OUT $head;

foreach my $filename (@filedir) {
   next if ( $filename =~ /\.sm\.jpg/g );
   print "File: $filename - ";
   my $caption_text;
   if ( exists $captions{$filename} ) {
      print qq(Using ѕupplied caption; );
      $caption_text = $captions{$filename};
   } else {
      print qq(Applying default caption; );
      if ( exists $captions{default} ) {
         $caption_text = $captions{default};
      } else {
         $caption_text = $default_caption_text;
      }
   }

   my $sm_name = $filename;
   $sm_name =~ s/\.jpg$/.sm.jpg/;
   print "Resizing $filename to $sm_name\n";
   qx(convert -resize 300 $filename $sm_name);
   my $img_link = <<EOIMG;
      <a href="$filename" data-lightbox="pix" data-title="$caption_text">
         <img src="$sm_name" alt="" /></a>
EOIMG
   print OUT $img_link;
}
my $tail = <<EOTAIL;
   </div>
</section>

   <script src="js/lightbox-plus-jquery.min.js"></script>

</body>
</html>
EOTAIL

   print OUT $tail;
