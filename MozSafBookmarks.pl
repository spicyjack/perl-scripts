#!/usr/bin/perl

#####################################################################
#
# MozSafBookmarks.pl - version 0.0.2
#
# Changelog:
#
#		Jan 20, 2003 - Non-plain characters are translated to UTF-8
#					   encoding.
#					 - Added 'usage' output if you don't give the
#					   script enough arguments.
#
# This is a simple script to copy bookmarks from Mozilla to Safari.
#
# Originally tossed together by one guy at Borrowed Time, Inc.
# (http://www.bti.net).  The code is as pretty as an airport
# (to paraphrase Douglas Adams).  While remaining ugly, it is
# completely and totally free.  Do with it what you will.  We won't
# be held responsible for Bad Things happening to your system,
# though.
#
# Usage:
#
#	cd <Whatever directory has the script>
#	perl MozSafBookmarks.pl <Moz_bookmarks.html> <Saf_Bookmarks.plist>
#
# Each argument is a path to the respective bookmark file.  The
# files must already exist.
#
# All Mozilla folders, subfolders and bookmarks are imported.  They
# are all placed within a single folder named "Mozilla Bookmarks"
# in Safari, and it should be the last item in the bookmark folder
# list.  You will probably have to edit them once they're imported;
# this thing ain't perfect.
#
# This script directly modifies the Safari bookmark file.  So you
# should have write permissions on the file, obviously.  Also, I would
# highly recommend that you backup the Safari bookmark file beforehand.
# Just to be safe....
#
# The typical location for the Mozilla bookmark file is buried in
# Library/Mozilla/ (starting from your home directory).  Subdirectory
# names can change, but on my system it turned out to be:
#
#	Library/Mozilla/Profiles/default/15jbitmt.slt/bookmarks.html
#
# Safari's bookmark file is a little easier to find.  Again, assuming
# you're starting from your home directory, it should be:
#
#	Library/Safari/Bookmarks.plist
#
#####################################################################

#####################################################################
# Constants and Globals
#####################################################################

$kMozillaBookmarkFolderName		=	'Mozilla Bookmarks';

$kChildTag						=	'<!-- Children -->';

#####################################################################
# TextFixer (text)
#####################################################################
sub TextFixer
{
	use utf8;
	
	my	$text = @_[0];
	
	$text =~ s/&amp;/&/gi;
	$text =~ s/&/&amp;/gi;
	
	return $text;
}

#####################################################################
# CreateSafariBookmarkLeaf (title,url)
#####################################################################
sub CreateSafariBookmarkLeaf
{
	my ($title,$url) = @_;
	my	$entry = '';
	
	$title = &TextFixer($title);
	$url = &TextFixer($url);
	
	$entry .= "<dict>\n";
	$entry .= "	<key>URIDictionary</key>\n";
	$entry .= "	<dict>\n";
	$entry .= "		<key></key>\n";
	$entry .= "		<string>$url</string>\n";
	$entry .= "		<key>lastVisitedDate</key>\n";
	$entry .= "		<string></string>\n";
	$entry .= "		<key>title</key>\n";
	$entry .= "		<string>$title</string>\n";
	$entry .= "	</dict>\n";
	$entry .= "	<key>URLString</key>\n";
	$entry .= "	<string>$url</string>\n";
	$entry .= "	<key>WebBookmarkType</key>\n";
	$entry .= "	<string>WebBookmarkTypeLeaf</string>\n";
	$entry .= "</dict>\n";
	
	return $entry;
}

#####################################################################
# CreateSafariBookmarkFolder (title)
#####################################################################
sub CreateSafariBookmarkFolder
{
	my	$title = @_[0];
	my	$entry = '';
	
	$entry .= "<dict>\n";
	$entry .= "	<key>Children</key>\n";
	$entry .= "	<array>\n";
	$entry .= "		$kChildTag\n";
	$entry .= "	</array>\n";
	$entry .= "	<key>Title</key>\n";
	$entry .= "	<string>$title</string>\n";
	$entry .= "	<key>WebBookmarkType</key>\n";
	$entry .= "	<string>WebBookmarkTypeList</string>\n";
	$entry .= "</dict>\n";
	
	return $entry;
}

#####################################################################
# ExtractMozillaBookmark (text)
#####################################################################
sub ExtractMozillaBookmark
{
	my	$text = @_[0];
	my ($title,$url);
	
	$text =~ /<A HREF="([^"]+)"/i;
	$url = $1;
	
	$text =~ /">(.*?)<\/A>/i;
	$title = $1;
	
	return ($title,$url);
}

#####################################################################
# ExtractMozillaBookmarkFolderName (text)
#####################################################################
sub ExtractMozillaBookmarkFolderName
{
	my	$text = @_[0];
	my ($folderName);
	
	$text =~ /">(.*?)<\/H3>/i;
	$folderName = $1;
	
	return $folderName;
}

#####################################################################
# ProcessMozillaBookmarkFile (mozillaBookmarkPath,currentFolderName)
#####################################################################
sub ProcessMozillaBookmarkFile
{
	my ($mozillaBookmarkPath,$currentFolderName) = @_;
	my ($bookmarkFolderInsert,@folderStack,$safariBookmarks);
	
	if (-e $mozillaBookmarkPath)
	{
		if (open(MOZ,"$mozillaBookmarkPath"))
		{
			while (<MOZ>)
			{
				my	$oneLine = $_;
				
				if ($oneLine =~ /<DL>/i)
				{
					# Beginning of a new bookmark folder
					
					if ($bookmarkFolderInsert ne '')
					{
						if ($safariBookmarks ne '')
						{
							chomp($safariBookmarks);
							$safariBookmarks .= $kChildTag;
							$bookmarkFolderInsert =~ s/$kChildTag/$safariBookmarks/;
						}
						push(@folderStack,$bookmarkFolderInsert);
					}
					
					$bookmarkFolderInsert = &CreateSafariBookmarkFolder($currentFolderName);
					$safariBookmarks = '';
				}
				elsif ($oneLine =~ /<\/DL>/i)
				{
					# End of bookmark folder
					
					chomp($safariBookmarks);
					$safariBookmarks .= $kChildTag;
					$bookmarkFolderInsert =~ s/$kChildTag/$safariBookmarks/;
					$safariBookmarks = '';
					
					if (scalar(@folderStack) > 0)
					{
						$safariBookmarks = $bookmarkFolderInsert;
						$safariBookmarks =~ s/$kChildTag//og;
						$bookmarkFolderInsert = pop(@folderStack);
					}
				}
				elsif ($oneLine =~ /<DT><H3/i)
				{
					# Bookmark folder name
					
					$currentFolderName = &ExtractMozillaBookmarkFolderName($oneLine);
				}
				elsif ($oneLine =~ /<DT><A/i)
				{
					# Bookmark entry
					
					my ($title,$url) = &ExtractMozillaBookmark($oneLine);
					
					if ($title ne '' && $url ne '' && $url =~ /^http/i)
					{
						$safariBookmarks .= &CreateSafariBookmarkLeaf($title,$url);
					}
				}
			}
			
			close(MOZ);
		}
		else
		{
			print STDERR "Error while opening '$mozillaBookmarkPath' for reading: $!\n";
			exit;
		}
	}
	else
	{
		print STDERR "Can't find Mozilla bookmark file '$mozillaBookmarkPath'\n";
		exit;
	}
	
	# Cleanup stray tags
	$bookmarkFolderInsert =~ s/$kChildTag//og;
	
	return $bookmarkFolderInsert;
}

#####################################################################
# InsertNewPlistIntoSafari (safariBookmarkPath,newPlistSection)
#####################################################################
sub InsertNewPlistIntoSafari
{
	my ($safariBookmarkPath,$newPlistSection) = @_;
	my ($safariBookmarkContents);
	
	if (-e $safariBookmarkPath)
	{
		# Read the bookmark file
		
		if (open(SAF,"$safariBookmarkPath"))
		{
			while (<SAF>)
			{
				$safariBookmarkContents .= $_;
			}
			close(SAF);
		}
		else
		{
			print STDERR "Error while opening '$safariBookmarkPath' for reading: $!\n";
			exit;
		}
		
		# Insert new plist section just before the end of the last plist array
		$safariBookmarkContents =~ s/(.*)<\/array>/$1\n$newPlistSection<\/array>/s;
		
		# Write the file back to disk
		if (open(SAF,">$safariBookmarkPath"))
		{
			print SAF $safariBookmarkContents;
			close(SAF);
		}
		else
		{
			print STDERR "Error while opening '$safariBookmarkPath' for writing: $!\n";
			exit;
		}
	}
	else
	{
		print STDERR "Can't find Safari bookmark file '$safariBookmarkPath'\n";
		exit;
	}
}

#####################################################################
# main
#####################################################################
{
	my ($mozillaBookmarkPath,$safariBookmarkPath) = @ARGV;
	
	if ($mozillaBookmarkPath eq '' || $safariBookmarkPath eq '')
	{
		my	@progPath = split('/',$0);
		
		print STDOUT "\n\nUsage: ".pop(@progPath)." <Mozilla bookmark path> <Safari bookmark path>\n";
		print STDOUT "\n";
		print STDOUT "Possible Mozilla bookmark files:\n";
		print STDOUT "--------------------------------\n";
		print STDOUT `find ~ -name bookmarks.html`;
		print STDOUT "\n\n";
		print STDOUT "Possible Safari bookmark files:\n";
		print STDOUT "-------------------------------\n";
		print STDOUT `find ~ -name Bookmarks.plist`;
	}
	else
	{
		my	$newPlistSection = &ProcessMozillaBookmarkFile($mozillaBookmarkPath,$kMozillaBookmarkFolderName);
		
		if ($newPlistSection ne '')
		{
			&InsertNewPlistIntoSafari($safariBookmarkPath,$newPlistSection);
			print STDOUT "Completed.\n";
		}
	}
	
	exit;
}