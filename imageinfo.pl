#!/usr/bin/perl -w
use Image::ExifTool 'ImageInfo';
my $file = shift or die "Please specify filename";
my $info = ImageInfo($file);
foreach (keys %$info) {
    print "$_ : $info->{$_}\n";
}
