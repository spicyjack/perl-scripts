#!/usr/bin/env perl

# script to automatically build the Gtk2-Perl modules, so that the
# documentation can be extracted from them and then distributed

# grab the list of git repos to sync with
#  lynx -dump http://git.gnome.org/cgit/ | grep "\/perl-" | grep  "\. http" |
#  awk '{ print $2}' | uniq

# get a list of currently installed Gtk2-Perl packages on a Debian machine
#  dpkg -l | egrep "gtk2|glib|cairo|pango|gnome2|extutils" | grep perl | sort
#  | awk '{ printf "%10s %s\n", $3, $2}'

# once the packages are built, generate the docs
# get a list of pod files to copy
# for PKG in $(dpkg -l \
# | egrep "gtk2|glib|cairo|pango|gnome2|extutils|gstreamer" \
# | grep perl | awk '{print $2}'); do dpkg -L $PKG | grep "pod$"; done >
# gtk2-perl.podfiles.txt

# generating pod docs:
# mpod2html -dir pod2html-out/ pods/
# pod2projdocs -out podprojectdocs/ -l pods/
