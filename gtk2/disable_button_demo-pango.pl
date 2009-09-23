#!/usr/bin/env perl

# $Id: perl_gtk2.pl,v 1.1 2009-09-19 07:47:00 brian Exp $
# Copyright (c)2001 by Brian Manning
#
# perl script that does something


=head1 NAME

SomeScript

=head1 DESCRIPTION

B<SomeScript> does I<Something>

=head1 FUNCTIONS 

=head2 SomeFunction()

SomeFunction() is a function that does something.  

=cut

################
# SomeFunction #
################
#sub SomeFunction {
#} # sub SomeFunction
				
package main;
# slice up the CVS Keyword to get the revision number
$main::VERSION = (q$Revision: 1.1 $ =~ /(\d+)/g)[0];
use strict;
use warnings;
# import the TRUE/FALSE constants from Glib prior to loading Gtk2
use Glib qw(TRUE FALSE);
# Gtk2->init; works if you don't use -init on use
use Gtk2 -init;

my $quit_status = q(Enabled);
# create the window
my $window = Gtk2::Window->new (q(toplevel));
# create a VBox to hold a label and a button
my $vbox = Gtk2::VBox->new(FALSE, 5);
# create a status label
my $label = Gtk2::Label->new(q(Quit status: ) . $quit_status);
# pack the label, expand == true, fill == true, 5 pixels padding
$vbox->pack_start($label, TRUE, TRUE, 2);
# create the button
my $quit_lock = Gtk2::Button->new (q(Quit _Lock));
$vbox->pack_start($quit_lock, TRUE, TRUE, 2);

# create a label that will hold pango markup
my $l_quit_button = Gtk2::Label->new();
# set the markup on the label
$l_quit_button->set_markup_with_mnemonic(q(<span color="Black">_Quit</span>));
# create the button
my $b_quit = Gtk2::Button->new();
# add the label with pango markup
$b_quit->add($l_quit_button);

# connect the button's 'click' signal to an action
$b_quit->signal_connect (clicked => sub { Gtk2->main_quit });
# add the button to the window
$vbox->pack_start($b_quit, TRUE, TRUE, 2);

# set up the signal on the quit_lock button
$quit_lock->signal_connect(clicked => sub { 
        if ( $quit_status eq q(Enabled) ) {
            $quit_status = q(Disabled);
            $b_quit->sensitive(FALSE);
            $l_quit_button->set_markup_with_mnemonic(q(<span color="DimGrey">_Quit</span>));
            #$b_quit->set_relief(q(none));
        } else { 
            $quit_status = q(Enabled);
            $l_quit_button->set_markup_with_mnemonic(q(<span color="Black">_Quit</span>));
            $b_quit->sensitive(TRUE);
            #$b_quit->set_relief(q(normal));
        } # if ( $quit_status eq q(Enabled) )
        $label->set_text($quit_status);
    });

# pack the vbox into the window
$window->add($vbox);
# show the window
$window->show_all;
# yield to Gtk2 and wait for user input
Gtk2->main;

=pod

=head1 CONTROLS

=over 5

=item B<Description of Controls>

=over 5

=item B<A Control Here>

This is a description about A Control.

=item B<Another Control>

This is a description of Another Control

=back 

=back

=head1 VERSION

The CVS version of this file is $Revision: 1.1 $. See the top of this file for the
author's version number.

=head1 AUTHOR

Brian Manning E<lt>elspicyjack at gmail dot comE<gt>

=cut

### begin license blurb
#   This program is free software; you can redistribute it and/or modify
#   it under the terms of the GNU General Public License as published by
#   the Free Software Foundation; version 2 dated June, 1991.
#
#   This program is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU General Public License for more details.
#
#   You should have received a copy of the GNU General Public License
#   along with this program;  if not, write to the Free Software
#   Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111, USA.

=pod

# vi: set ft=perl sw=4 ts=4:
# EOF
1;
