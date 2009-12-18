#!/usr/bin/env perl

# script to automatically build the Gtk2-Perl modules, so that the
# documentation can be extracted from them and then distributed

# Missing:
# Gtk2::SourceView (built using dh-make-perl)
# Gnome2::Wnck (installed from package)
# Gnome2::Vte (built using dh-make-perl)
# Gnome2::Print (installed from package)
# Gnome2::Rsvg (built using dh-make-perl)
# Gnome2::PanelApplet (built using dh-make-perl)
# Gnome2::GConf (installed from package)

# Pod::ProjectDocs Needs Syntax::Highlighting::Universal, which needs Colorer
# * http://search.cpan.org/perldoc?Pod::ProjectDocs
# * http://colorer.sourceforge.net/
# * http://search.cpan.org/perldoc?Syntax::Highlight::Universal

# create the Gtk2/Glib .deb using:
# time dh-make-perl --build --version 1:1.221-0
# not using this version string will cause the default version of libglib-perl
# to be installed, as Debian's package tools don't understand Perl version
# strings

# grab the list of git repos to sync with
#  lynx -dump http://git.gnome.org/cgit/ | grep "\/perl-" | grep  "\. http" |
#  awk '{ print $2}' | uniq

# get a list of currently installed Gtk2-Perl packages on a Debian
# machine; don't include package from the Gtk2::Ex package space
# dpkg -l | egrep "gtk2|glib|cairo|pango|gnome2|extutils" | grep perl
# | grep -v "-ex-" | sort | awk '{ printf "%12s %s\n", $3, $2}'

# once the packages are built, generate the docs;
# get a list of pod files to copy
# for PKG in $(dpkg -l \
# | egrep "gtk2|glib|cairo|pango|gnome2|extutils|gstreamer" \
# | grep perl | grep -v "-ex-" | awk '{print $2}'); 
# do dpkg -L $PKG | egrep "pm$|pod$"; 
# done > usrlibperl.txt

# cut out the full paths in the filelists so that you can cd to the
# directories with the docs in them and make tarballs with relative files

# package into a tarball so you can move them around/combine them into one
# directory
# cd /usr/lib/perl5
# tar -cvT /usr/local/src/gtk2-perl/usrlibperl.txt \
# > /usr/local/src/gtk2-perl/gtk2-perl.pods.tar

# do any locally installed files
# cd /usr/local/lib/perl/5.10.0/GStreamer
# find . | egrep "pm$|pod$" > usrlocallibperl.txt
# find GStreamer | egrep "pm$|pod$" \
# > /usr/local/src/gtk2-perl/usrlocallibperl.txt
# tar -rvT /usr/local/src/gtk2-perl/usrlocallibperl.txt \
# -f /usr/local/src/gtk2-perl/gtk2-perl.pods.tar

# generating pod docs:
# time mpod2html -dir Gtk2-Perl-MarekPodHTML/ -tocname index 
# -idxname "idx" -stylesheet "/doc/style.css" \
# -toctitle "Gtk2-Perl - Table of Contents" \
# -idxtitle "Gtk2-Perl - Index" -nowarnings -noverbose pods
# time pod2projdocs -out Gtk2-Perl-PodProjDocs/ -lib pods/ -title "Gtk2-Perl" \
# -desc "A set of Perl bindings for Gtk+ 2.0 and various related libraries" \
# -except "Install/Files\.pm"
