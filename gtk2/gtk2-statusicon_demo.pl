#!/usr/bin/perl
use warnings;
use strict;
use Gtk2 '-init';
use MIME::Base64;

my %icon;
build_icons(); # r,g,y
my $icon_cur = $icon{ 'g' };

my %val;
while(<DATA>){
  chomp;
  my($key,$value) = split(/=/,$_);
  if( defined $key){
    $val{$key} = $value;
  }
}

# check data reloaded properly
#foreach my $key(sort keys %val){print $key.'='.$val{$key}."\n"}

# default global variables if not saved to __DATA__
$val{'dir'}  ||= './';
$val{'file'} ||= $0;
$val{'check1'} ||= 1;
$val{'check2'} ||= 0;
$val{'check3'} ||= 0;
$val{'var1'} ||= 'VAR1';
$val{'var2'} ||= 'VAR2';
$val{'var3'} ||= 'VAR3';
$val{'var4'} ||= 'VAR4';
$val{'var5'} ||= 'VAR5';
$val{'var6'} ||= 'VAR6';
$val{'var7'} ||= 'VAR7';
$val{'var8'} ||= 'VAR8';
$val{'var9'} ||= 'VAR9';
$val{'var10'} ||= 'VAR10';

my $statusicon = Gtk2::StatusIcon->new_from_pixbuf($icon_cur);
# will make a nice icon automagically from a file if desired
#my $statusicon = Gtk2::StatusIcon->new_from_file('12uni2.png');

$statusicon->set_tooltip("Info v1.0");
$statusicon->signal_connect( 'activate', \&pop_it );
$statusicon->signal_connect( 'popup-menu', \&config_it );

#show in tray
$statusicon->set_visible(1);

#end event loop
Gtk2->main;


sub pop_it{

   my $popup = Gtk2::Window->new( 'toplevel' );
   $popup->set_position( 'center' );

  my $vbox = Gtk2::VBox->new( 0, 6 );
  $popup->add($vbox);
  $vbox->set_border_width(2);

  my $hbox= Gtk2::HBox->new( 0, 6 );
  $vbox->pack_end($hbox,0,0,2);

  my $ebutton = Gtk2::Button->new_from_stock('gtk-close');
  $hbox->pack_end( $ebutton, 0, 0, 0 );
  $ebutton->signal_connect( clicked => sub{ $popup->hide_all  } );

  # Create a textbuffer to contain that string
  my $textbuffer = Gtk2::TextBuffer->new();
  my $tail = `tail -n 20 $val{'file'}`;
  $textbuffer->set_text($tail);

# Create a textview using that textbuffer
my $textview = Gtk2::TextView->new_with_buffer($textbuffer);

# Add the textview to a scrolledwindow 
my $scrolledwindow = Gtk2::ScrolledWindow->new( undef, undef );
$scrolledwindow->add($textview);
$scrolledwindow->set_size_request (300, 300);
$vbox->pack_start($scrolledwindow, 1, 1, 0 );
$popup->show_all;

}


#right click menu
sub config_it {

# change Mode or whatever.... a menu entry
   my $menu = Gtk2::Menu->new();

  my $menu_Z1 = Gtk2::ImageMenuItem->new_with_label( "Mode Z1" );
   $menu_Z1->signal_connect(
      activate => sub {
        #change the icon when Z1 is clicked in the menu
         $statusicon->set_from_pixbuf($icon{'y'});
         $statusicon->set_tooltip( "Mode Z1" );
      }
   );
   $menu_Z1->set_image( Gtk2::Image->new_from_stock( 'gtk-refresh', 'menu' ) );
   $menu->add( $menu_Z1);

# launch configure window
   my $menu_pref = Gtk2::ImageMenuItem->new_with_label( "Configure" );
   $menu_pref->signal_connect( activate => \&configure );
   $menu_pref->set_image(
      Gtk2::Image->new_from_stock( 'gtk-preferences', 'menu' ) );
   $menu->add( $menu_pref );

#separator
   my $menu_sep = Gtk2::SeparatorMenuItem->new();
   $menu->add( $menu_sep );

#Quit
   my $menu_quit = Gtk2::ImageMenuItem->new_with_label( "Quit" );
   $menu_quit->signal_connect( activate => \&exit_it );
   $menu_quit->set_image( Gtk2::Image->new_from_stock( 'gtk-quit', 'menu' ) );
   $menu->add( $menu_quit );
   $menu->show_all;

 #to position the menu under the icon, instead of at mouse position
 my ($x, $y, $push_in) = Gtk2::StatusIcon::position_menu($menu, $statusicon);
 # print "$x, $y, $push_in\n";
 $menu->popup( undef, undef, sub{return ($x,$y,0)} , undef, 0, 0 );

  return 1;
}


#configuration dialog window
sub configure {

#Create the new window
   my $config_window = Gtk2::Window->new( 'toplevel' );
   $config_window->set_title( "Configuration" );
   $config_window->set_position( 'center' );

#VBox container
   my $table_config = Gtk2::Table->new( 3, 5, 0 );

#Create Notebook
   my $config_notebook = Gtk2::Notebook->new;
   $config_notebook->set_tab_pos( 'top' );

#the First Page; Config file select
   my $vbox_p1 = Gtk2::VBox->new( 0, 1 );
   my $hbox_1_p1   = Gtk2::HBox->new( 0, 1 );
   my $label_1_p1 = Gtk2::Label->new( 'Directory' );
   my $entry_1_p1  = Gtk2::Entry->new;
   $entry_1_p1->set_width_chars (60);
   $entry_1_p1->set_position(60);
   my $button_1_p1 = Gtk2::Button->new_with_mnemonic( "_Browse" );
   $button_1_p1->set_size_request( 80, 32 );
   my $align_button_1_p1 = Gtk2::Alignment->new( 0.5, 0.5, 0, 0 );
   $align_button_1_p1->add( $button_1_p1 );
   $entry_1_p1->set_text( $val{'dir'} );
   $hbox_1_p1->pack_start( $label_1_p1, 0, 0, 1 );
   $hbox_1_p1->pack_start( $entry_1_p1, 1, 1, 1 );
   $hbox_1_p1->pack_start( $align_button_1_p1, 0, 0, 1 );

   my $hbox_2_p1   = Gtk2::HBox->new( 0, 1 );
   my $label_2_p1 = Gtk2::Label->new( 'Tail File' );
   my $entry_2_p1  = Gtk2::Entry->new;
   $entry_2_p1->set_width_chars (60);
   $entry_2_p1->set_position(60);
   my $button_2_p1 = Gtk2::Button->new_with_mnemonic( "_Browse" );
   $button_2_p1->set_size_request( 80, 32 );
   my $align_button_2_p1 = Gtk2::Alignment->new( 0.5, 0.5, 0, 0 );
   $align_button_2_p1->add( $button_2_p1 );
   $entry_2_p1->set_text( $val{'file'} );
   $hbox_2_p1->pack_start( $label_2_p1, 0, 0, 1 );
   $hbox_2_p1->pack_start( $entry_2_p1, 1, 1, 1 );
   $hbox_2_p1->pack_start( $align_button_2_p1, 0, 0, 1 );

   $vbox_p1->pack_start( $hbox_1_p1, 0, 0, 1 );
   $vbox_p1->pack_start( $hbox_2_p1, 0, 0, 1 );

   $button_1_p1->signal_connect(
      'clicked' => sub {

    my $fs = Gtk2::FileChooserDialog->new(
        'Choose a Directory',
     $config_window, 'select-folder',
        'gtk-cancel' => 'cancel',
        'gtk-ok' => 'accept'
    );

    my $response = $fs->run();
    if ( "accept" eq $response ) {
        my $dir =  $fs->get_filename();
        $entry_1_p1->set_text( $dir );
    }
    $fs->destroy;
}
 );

   $button_2_p1->signal_connect(
      'clicked' => sub {

    my $fs = Gtk2::FileChooserDialog->new(
        "FS", $config_window, 'open',
        "Cancel" => "cancel",
        "OK"     => "accept",
    );
    my $response = $fs->run();
    if ( "accept" eq $response ) {
        my $file =  $fs->get_filename();
        $entry_2_p1->set_text( $file );
    }
    $fs->destroy;
}
 );


my $checkbutton1 = Gtk2::CheckButton->new('Some Feature1');
$checkbutton1->set_active( $val{'check1'} );
$vbox_p1->pack_start( $checkbutton1, 0, 0, 1 );
$checkbutton1->signal_connect( clicked => \&check_button_callback1 );

my $checkbutton2 = Gtk2::CheckButton->new_with_label('Flashing Warning');
$checkbutton2->set_active( $val{'check2'} );
$vbox_p1->pack_start( $checkbutton2, 0, 0, 1 );
$checkbutton2->signal_connect( clicked => \&check_button_callback2 );

my $checkbutton3 = Gtk2::CheckButton->new_with_mnemonic('Red Icon');
$checkbutton3->set_active( $val{'check3'} );
$vbox_p1->pack_start( $checkbutton3, 0, 0, 1 );
$checkbutton3->signal_connect( clicked => \&check_button_callback3 );



#the Second Page;
   my $vbox_p2 = Gtk2::VBox->new( 0, 1 );
   my $label_1_p2   = Gtk2::Label->new( 'Label 1' );
   my $entry_1_p2   = Gtk2::Entry->new;
   my $label_2_p2 = Gtk2::Label->new( 'Label2' );
   my $entry_2_p2 = Gtk2::Entry->new;
   $entry_1_p2->set_text( $val{'var1'} );
   $entry_2_p2->set_text( $val{'var2'} );
   $vbox_p2->pack_start( $label_1_p2,   0, 0, 1 );
   $vbox_p2->pack_start( $entry_1_p2,   0, 0, 1 );
   $vbox_p2->pack_start( $label_2_p2, 0, 0, 1 );
   $vbox_p2->pack_start( $entry_2_p2, 0, 0, 1 );


#the Third Page;
   my $table_p3        = Gtk2::Table->new( 4, 2, 0 );
   my $label_1_p3      = Gtk2::Label->new( 'First Label' );
   my $entry_1_p3      = Gtk2::Entry->new;
   my $label_2_p3      = Gtk2::Label->new( 'Second label' );
   my $entry_2_p3      = Gtk2::Entry->new;
   my $label_3_p3      = Gtk2::Label->new( 'Third Label' );
   my $entry_3_p3      = Gtk2::Entry->new;
   my $label_4_p3      = Gtk2::Label->new( 'Fourth Label' );
   my $entry_4_p3      = Gtk2::Entry->new;
   $entry_1_p3->set_text( $val{'var3'} );
   $entry_2_p3->set_text( $val{'var4'} );
   $entry_3_p3->set_text( $val{'var5'} );
   $entry_4_p3->set_text( $val{'var6'} );
#   $entry_3_p3->set_editable( 0 );  # if no edit desired
   $table_p3->attach_defaults( $label_1_p3, 0, 1, 0, 1 );
   $table_p3->attach_defaults( $entry_1_p3, 1, 2, 0, 1 );
   $table_p3->attach_defaults( $label_2_p3, 0, 1, 1, 2 );
   $table_p3->attach_defaults( $entry_2_p3, 1, 2, 1, 2 );
   $table_p3->attach_defaults( $label_3_p3, 0, 1, 2, 3 );
   $table_p3->attach_defaults( $entry_3_p3, 1, 2, 2, 3 );
   $table_p3->attach_defaults( $label_4_p3, 0, 1, 3, 4 );
   $table_p3->attach_defaults( $entry_4_p3, 1, 2, 3, 4 );

#the Fourth Page;
   my $vbox_p4 = Gtk2::VBox->new( 0, 1 );
   my $table_1_p4 = Gtk2::Table->new( 4, 2, 0 );
   my $frame_1_p4  = Gtk2::Frame->new( 'Some Cool Title' );
   my $label_1_p4  = Gtk2::Label->new( 'First Label' );
   my $entry_1_p4  = Gtk2::Entry->new;
   my $label_2_p4 = Gtk2::Label->new( 'Second Label' );
   my $entry_2_p4 = Gtk2::Entry->new;
   $entry_1_p4->set_text( $val{'var7'} );
   $entry_2_p4->set_text( $val{'var8'} );

   $table_1_p4->attach_defaults( $label_1_p4, 0, 1, 0, 1 );
   $table_1_p4->attach_defaults( $entry_1_p4, 1, 2, 0, 1 );
   $table_1_p4->attach_defaults( $label_2_p4, 0, 1, 1, 2 );
   $table_1_p4->attach_defaults( $entry_2_p4, 1, 2, 1, 2 );
   $frame_1_p4->add( $table_1_p4 );

   my $table_2_p4       = Gtk2::Table->new( 4, 2, 0 );
   my $frame_2_p4       = Gtk2::Frame->new( 'Another Cool Title' );
   my $label_3_p4       = Gtk2::Label->new( 'Third Label' );
   my $entry_3_p4       = Gtk2::Entry->new;
   my $label_4_p4       = Gtk2::Label->new( 'Fourth Label' );
   my $entry_4_p4       = Gtk2::Entry->new;
   $entry_3_p4->set_text( $val{'var9'} );
   $entry_4_p4->set_text( $val{'var10'});
   $table_2_p4->attach_defaults( $label_3_p4, 0, 1, 0, 1 );
   $table_2_p4->attach_defaults( $entry_3_p4, 1, 2, 0, 1 );
   $table_2_p4->attach_defaults( $label_4_p4, 0, 1, 1, 2 );
   $table_2_p4->attach_defaults( $entry_4_p4, 1, 2, 1, 2 );
   $frame_2_p4->add( $table_2_p4 );

   $vbox_p4->pack_start( $frame_1_p4, 0, 0, 1 );
   $vbox_p4->pack_start( $frame_2_p4, 0, 0, 1 );

#append pages
   $config_notebook->append_page( $vbox_p1,   "File Stuff" );
   $config_notebook->append_page( $vbox_p2,   "More Items" );
   $config_notebook->append_page( $table_p3, "More in a Table" );
   $config_notebook->append_page( $vbox_p4,  "Another Table Set" );

#add button to the main window
   my $button_accept = Gtk2::Button->new_with_mnemonic( "_Accept" );
   my $button_cancel = Gtk2::Button->new_with_mnemonic( "_Cancel" );

#pack them into the dialog window
   $table_config->attach_defaults( $config_notebook, 0, 5, 0, 1 );
   $table_config->attach_defaults( $button_accept,   1, 2, 2, 3 );
   $table_config->attach_defaults( $button_cancel,   3, 4, 2, 3 );
   $config_window->add( $table_config );

   $config_window->show_all;

#Button Functions
   $button_cancel->signal_connect(
    'clicked' => sub { $config_window->destroy }
   );

   $button_accept->signal_connect(
      'clicked' => sub {
         my @settings = (
            ( $val{'dir'}      = $entry_1_p1->get_text ),
            ( $val{'file'}     = $entry_2_p1->get_text ),
            ( $val{'check1'}   = $checkbutton1->get_active() || 0 ),
            ( $val{'check2'}   = $checkbutton2->get_active() || 0 ),
            ( $val{'check3'}   = $checkbutton3->get_active() || 0 ),
            ( $val{'var1'}     = $entry_1_p2->get_text ),
            ( $val{'var2'}     = $entry_2_p2->get_text ),
            ( $val{'var3'}     = $entry_1_p3->get_text ),
            ( $val{'var4'}     = $entry_2_p3->get_text ),
            ( $val{'var5'}     = $entry_3_p3->get_text ),
            ( $val{'var6'}     = $entry_4_p3->get_text ),
            ( $val{'var7'}     = $entry_1_p4->get_text ),
            ( $val{'var8'}     = $entry_2_p4->get_text ),
            ( $val{'var9'}     = $entry_3_p4->get_text ),
            ( $val{'var10'}    = $entry_4_p4->get_text ),
         );
         save_default();
         $config_window->destroy;
      }
   );

   return 1;
}

#Exit
sub exit_it {
   Gtk2->main_quit;
   return 0;
}

#save to DATA when apply is clicked
sub save_default {

open(SELF,"+<$0")||die $!;
while(<SELF>){last if /^__DATA__/}
  truncate(SELF,tell SELF);

 foreach my $key(sort keys %val ) {
      print SELF $key.'='.$val{$key}."\n"; #default line ending
   }

 truncate(SELF,tell SELF);
 close SELF;

}

sub check_button_callback1 {
  my ($button) = @_;
     if ($button->get_active) {
       # if control reaches here, the check button is on
       # do something here

     } else {
    # if control reaches here, the check button is off
      # undo something here

      }
}

sub check_button_callback2 {
  my ($button) = @_;
     if ($button->get_active) {
       # if control reaches here, the check button is on
         $statusicon->set_from_pixbuf($icon{'y'});
         $statusicon->set_tooltip( "Mode Yellow Warning" );
         $statusicon->set_blinking (1);
     } else {
    # if control reaches here, the check button is off
         $statusicon->set_from_pixbuf($icon_cur);
         $statusicon->set_tooltip( "Mode Normal" );
         $statusicon->set_blinking (0);
      }
}

sub check_button_callback3 {
  my ($button) = @_;
     if ($button->get_active) {
       # if control reaches here, the check button is on
         $statusicon->set_from_pixbuf($icon{'r'});
         $statusicon->set_tooltip( "Mode Red" );
     } else {
    # if control reaches here, the check button is off
         $statusicon->set_from_pixbuf($icon_cur);
         $statusicon->set_tooltip( "Mode Normal" );
      }
}


sub build_icons {
   my %data;

   $data{ 'r' } = decode_base64(
'iVBORw0KGgoAAAANSUhEUgAAACAAAAAgCAYAAABzenr0AAAABmJLR0QA/wD/AP+gvaeTAAAACXBI
WXMAAAsTAAALEwEAmpwYAAAB00lEQVRYw+3WP2gUURAG8N++iwoRxRSilSiiHN4iWJhe7MTCQiJW
IqiFtUIQQWyENNpZxkYxjVgKNnb24hUGQe0s0gj+PcztWtw7WC63d2TJbQrvwbK8x2Pmm2++mXlJ
nue2cwXbvKYApgBmqsFON55l7f8rBQv4gm/xv1AVQLLpRtSjfx2NwmkXM1XSUJWBxpj9tAwnDuDj
mP2E+wDH+yKun4Ge0pPCB3ndjegXslh+GfK6NfBjYF8jgJDux+7trIIz2DXYUesB0It+eajDkC7X
wcBpzJbk/KKQvhbSxiQBPB8hug5O4s5kAIT0K/ZE54NRZtiLOdwU0qtbByCkTSH9hANDor+BD9FO
wM4IYinqZUsYeIHDBbX3o7+NFVwvtPXv8c4+fBbSZrUHSQ/9I5yLxgZVfx6vYjkmuILHQ5pTNw6q
a7L223IAPYfHcBZHo+MyCluR9h2R8k68O4unmB82QbCKl3iHN3GurCV50rqEyziCZjQ6bD2JrKwi
kbU7Bcbm8BMHcRcXSgLo072O93iQ5ElrXB/v4iEWo+PuiLdiP1UnYsOaH2P7zygAv7Eka9+vMC8S
HMJf3IvVUiLCjQDWcAvPSqPdPKAGTsXULBYqKf8H7mhziLP34moAAAAASUVORK5CYII='
   );


   $data{ 'g' } = decode_base64(
'iVBORw0KGgoAAAANSUhEUgAAACAAAAAgCAYAAABzenr0AAAABmJLR0QA/wD/AP+gvaeTAAAACXBI
WXMAAAsTAAALEwEAmpwYAAABwUlEQVRYw+2VvS8EURTFf8/4CKJQTKOgEIlEqFCIRnSUhE6iUOhV
Go3Kf0ChkiipNWqFQuErEtFJSEREfO7O0dyNid2Z3X3sbmHfy82bdzPv3TPnnnvHSaKWo4EajzqA
OoBGn0MOl+cT+l8pmANugEdb53wBuHIbkdGfAYKYOws0+qTBl4GgyL5ehhUHcFVkX3ERfm9jraAq
IrQgLmbewX+TghcgsvKLAFVbA895xFQLgMOFQHstq2ACaMnD5TsklWyIEPGMiFDe3C7nrpyVy8AI
0JaQ81mHO3C4oJIp2E0R3TswBKxWJAWIW6M+W4D+LOLd7BaxWPq9xQP3I64teITIxAIvIc7t+dPW
N8QdIvwrAKex4PG5guhAjMd8T8bCh4m13wuAqX0H8ZCg+GlEA6IV0YZYLvBOZKycIcaSADhJuebS
B0wCvcAUECbIZgC4AJqAZhNfaNWxA4wWOBMBl8AecAIc2n/lHsQ8Yh9xYvQlzW3EIKIZ0fKDsU7z
dyO2TANKYCWyFB0jZkgJmJsZxIZRHqRoBYQzG0AclXD3axqAF8SaT3czED2ILsRmKoQCrjvEQtrX
egAKEMOI9R9lHH0BkYPO/OE8jeIAAAAASUVORK5CYII='
   );


   $data{ 'y' } = decode_base64(
'iVBORw0KGgoAAAANSUhEUgAAACAAAAAgCAYAAABzenr0AAAABmJLR0QA/wD/AP+gvaeTAAAACXBI
WXMAAAsTAAALEwEAmpwYAAAB2UlEQVRYw+3WP2gUQRQG8N/mokJEMRyi2UIUUQ4FwcL0YicWFhKx
EkEtrBWCCGIjpNHOMjaKNmIp2NjZi41BUKuzSBYE/x7mbi12DpbL7R1ZcnuFN7AsM8y8973vvffN
RGmaGueYMuYxATABMF3qVBJvXKs3/68ULOALvoX/QlkA0aaFKKN/HbXcahvTZdJQloHakPmkDUcO
4OOQ+Yh1gKPdIq6egazSo9wHadVC9Aud0H4dpFXXwI+eeYUAkngvdo6zC05jR6+iVgMgi365r8Mk
Xq6CgVOYKcj5BUn8WhLXRgng2YCia+EEbo8GQBJ/xa7gvDfKDnZjFjck8ZWtA5DEDUn8Cfv6RH8d
H4KdKWwPIJZCvWwJAy9wMFft3ehv4Tmu5WT9e9izB58lcaPcgyRD/xBng7Heqj+HV6EdI1zGoz7i
1A4X1VX15ttiAJnDIziDw8FxEYXHA+3bAuWtsHcGTzDf50wHK3iJd3gT7pXVKF2bu4hLOIRGMNpv
PA6srCBSb7ZyjM3iJ/bjDs4XBNClex3vcT9K1+aG6XgbD7AYHLcHvBW7qToWBGt+iO0/gwD8xpJ6
816J+yLCAfzF3dAtBUW4EcAqbuJpYbSbB1TDyZCaxVwnpf8AkwJ+jVuvoFMAAAAASUVORK5CYII='
   );


# this properly renders them to pixbuf
   foreach my $key ( keys %data ) {
      $icon{ $key } = do {
         my $loader = Gtk2::Gdk::PixbufLoader->new();
         $loader->write( $data{ $key } );
         $loader->close();
         $loader->get_pixbuf();
      };
   }


}
__DATA__
check1=1
check2=1
check3=0
dir=./
file=./zzz-statusicon
var1=VAR1
var10=VAR10
var2=VAR2
var3=VAR3
var4=VAR4
var5=VAR5
var6=VAR6
var7=VAR7
var8=VAR8
var9=VAR9
