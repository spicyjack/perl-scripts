#!/usr/bin/perl -w

# created 3/30/99 for network file access scripts
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
#
# Program takes a directory of .htm files and corrects them to .html


@htmlfiledir= <./*>;

foreach $oldname (@htmlfiledir) {
	$newname =~ s/.htm\b/.html/;			# the token file
	print "The filename will be changed from $oldname to $newname\n";
} 

