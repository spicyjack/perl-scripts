#!/usr/bin/env perl

# script to automatically build the Gtk2-Perl modules, so that the
# documentation can be extracted from them and then distributed

# Missing:
# Gtk2::SourceView
# Gnome2::Wnck
# Gnome2::Vte
# Gnome2::Print
# Gnome2::Rsvg
# Gnome2::PanelApplet
# Gnome2::GConf

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

# cut out the full paths in the filelists so that you can cd to the
# directories with the docs in them and make tarballs with relative files

# package into a tarball so you can move them around/combine them into one
# directory
# cd /usr/lib/perl5
# tar -cvT /usr/local/src/gtk2-perl/gtk2-perl.podfiles.txt > /usr/local/src
# /gtk2-perl/gtk2-perl.pods.tar

# generating pod docs:
# mpod2html -dir mpod2html-out/ pods/
# pod2projdocs -out podprojectdocs/ -l pods/
