#!/usr/bin/perl -w

# $Id$
# created 05Nov2005 for disabling all of the ports on a machine
# Copyright (C) 2005 by Brian Manning <brian at antlinux dot com>
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

# Generate a list of active ports with:
# port installed | grep -v "The following ports are currently installed" 
# | grep "(active)" | sed 's/ (active)$//' | sed 's/^  *//' 
# | sed 's/\(.*\)/"\1"/' > active_ports.txt 

# read in the ports from a filelist
open(PORT, "<$ARGV[0]");
# read the actual file
@ports= <PORT>;
# remove traling newlines
chomp(@ports);

foreach $port (@ports) {
	print "Port $port will now be disabled\n";
    system "sudo port deactivate $port";
} 

