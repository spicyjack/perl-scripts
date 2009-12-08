#!/usr/bin/env perl

# script to automatically build the Gtk2-Perl modules, so that the
# documentation can be extracted from them and then distributed

#  lynx -dump http://git.gnome.org/cgit/ | grep "\/perl-" | grep  "\. http" |
#  awk '{ print $2}' | uniq
