#!/usr/bin/perl -w

# script to read in a directory of *.gz files, view the contents, then
# untar/ungzip the contents, and delete the original tarball

# locations of binaries
$TAR = "/bin/tar";

@tarballs = <*.tar.gz>;

foreach $tarball (@tarballs) {
	$contents = `$TAR -tzvf $tarball`;
	print "\n==== Contents of $tarball ====\n";
	print $contents . "\n";
	if (&yorn("Unzip and delete this file?")) {
		#print "$tarball would have been untarred and deleted\n";
		system("$TAR -zxvf $tarball");
		unlink($tarball);
	} # if &yorn
} # foreach

sub yorn {
	print $_[0] . "\n";
	$answer = <STDIN>;
	if ("y" || "Y"){
		$returnval = 1;
	} else {
		$returnval = 0;
	}	
    return $returnval;
} # sub yorn

