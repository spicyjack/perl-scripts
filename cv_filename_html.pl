#!/usr/bin/perl -w
#
#(C) 1999 by Brian Manning <brian@sunset-cliffs.org>
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
# program to read the input of a cgi form, create and mount a novell share,
# then fire off drall for file management



# then open said entropy, and the regular file too
	open (OUT, ">$randomfile"); 
	open (IN, "/home/httpd/cgi-bin/template.drall.pl");
	
# loop till EOF, looking for teltale strings...
	while (<IN>) {	# read a line from the input file
		s/MOUNTDIR/$rnddirname/g;
		s/USER/$user/g;
		s/SERVER/$server/g;
		print OUT $_;
	}
	close (IN);
	close (OUT);

# and then get out of here, calling drall.pl, with the config file...

	print "Location: /cgi-bin/drall.pl?config=$rnddirname\n\n";
	

# possible error codes

# ipx is not up
#ncpmount: No primary IPX interface found when trying to find SDG410

# the password was wrong
#ncpmount: NCP Request returned error code in nds login
#NDS error code -669.
#Login denied.

# and the username does'nt exist
#ncpmount: NCP Request returned error code in nds login
#NDS error code -601.
#Login denied.

