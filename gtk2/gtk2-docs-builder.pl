#!/usr/bin/env perl

# script to automatically build the Gtk2-Perl modules, so that the
# documentation can be extracted from them and then distributed

# grab the list of git repos to sync with
#  lynx -dump http://git.gnome.org/cgit/ | grep "\/perl-" | grep  "\. http" |
#  awk '{ print $2}' | uniq

# get a list of currently installed Gtk2-Perl packages on a Debian machine
# dpkg -l | egrep "gtk2|glib|pango|cairo|gnome2" | grep perl | awk '{print $3,
# $2}'
