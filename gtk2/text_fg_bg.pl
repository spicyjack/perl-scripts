#! /usr/bin/perl -w

# taken from the Gtk2-Perl Study Guide section on Pango Markup
# http://forgeftp.novell.com/gtk2-perl-study/documentation/html/a5990.html
# Dirk van der Walt, CSIR <dvdwalt@csir.co.za>

use strict;

use Gtk2 '-init';

#standard window creation, placement, and signal connecting
my $window = Gtk2::Window->new('toplevel');
$window->signal_connect('delete_event' => sub { Gtk2->main_quit; });
$window->set_border_width(5);
$window->set_position('center_always');

#this vbox will geturn the bulk of the gui
my $vbox = &ret_vbox();

#add and show the vbox
$window->add($vbox);
$window->show();

#our main event-loop
Gtk2->main();

sub ret_vbox {

my $cmbo_fg = Gtk2::ComboBox->new_text; 
my $cmbo_bg = Gtk2::ComboBox->new_text;

open COLORS, "./rgb.txt"
	or die "Could not find the rgb.txt file under /usr/X11R6/lib/X11/ ($!)";
	
	foreach my $color (<COLORS>){
	chomp $color;
	if (!($color =~ m/^!/)){
		$color =~ s/.+\t\t//;
		#print $color."\n";

		$cmbo_fg->append_text ($color);
		$cmbo_bg->append_text ($color);
	}
	

	}
	
	$cmbo_fg->set_active(39);
	$cmbo_bg->set_active(40);
	
my $lbl_show = Gtk2::Label->new();

$lbl_show->set_markup("<span foreground=\"white\" background=\"black\" size=\"30000\"><b>Test Text</b></span>");


my $vbox = Gtk2::VBox->new(0,5);
$vbox->pack_start(Gtk2::Label->new('Custom Colors using Pango Markup'),0,0,5);

	my $table = Gtk2::Table->new (2, 2, 0);
		my $lbl_fg = Gtk2::Label->new_with_mnemonic("Foreground: ");
		$lbl_fg->set_alignment (1, 1);
		
	$table->attach_defaults ($lbl_fg, 0, 1, 0, 1);
		$cmbo_fg->signal_connect('changed'=>sub {
		my $fg = $cmbo_fg->get_active_text();
		my $bg = $cmbo_bg->get_active_text();
		$lbl_show->set_markup("<span foreground=\"$fg\" background=\"$bg\" size=\"30000\"><b>Test Text</b></span>");
		
		});
	$table->attach_defaults ($cmbo_fg, 1, 2, 0, 1);
	
		my $lbl_bg = Gtk2::Label->new_with_mnemonic("Background: ");
		$lbl_bg->set_alignment (1, 1);
	$table->attach_defaults ($lbl_bg, 0, 1, 1, 2);
		$cmbo_bg->signal_connect('changed'=>sub {
		my $bg = $cmbo_bg->get_active_text();
		my $fg = $cmbo_fg->get_active_text();
		$lbl_show->set_markup("<span foreground=\"$fg\" background=\"$bg\" size=\"30000\"><b>Test Text</b></span>");
		
		});
	
	$table->attach_defaults ($cmbo_bg, 1, 2, 1, 2);
	

$vbox->pack_start($table,0,0,5);
$vbox->pack_end($lbl_show,0,0,5);


$vbox->show_all();
return $vbox;

}
