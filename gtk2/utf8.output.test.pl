#!/opt/local/bin/perl

use Gtk2 '-init';
my $window = Gtk2::Window->new();
my $button = new Gtk2::Button( "print" );
my $entry  = new Gtk2::Entry;
my $vbox = Gtk2::VBox->new (FALSE, 8);
$window->add($vbox);
$vbox->add($button);
$vbox->add($entry);
binmode STDOUT, ":utf8";
$button->signal_connect( "clicked",sub {
    my $word = $entry->get_text();
    my @word = split(//, $word);
    my $hexword = q();
    foreach my $letter ( @word ) {
        $hexword .= sprintf(q(0x%0x), ord($letter)) . q( );
    } # foreach my $letter ( @word )
    print qq|$word ( $hexword )\n|;
} );
$window->show_all();
Gtk2->main;
