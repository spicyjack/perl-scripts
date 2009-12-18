#!perl -T

use Test::More tests => 1;

BEGIN {
	use_ok( 'Gtk2::Ex::Pod::Syntax::Highlighter' );
}

diag( "Testing Gtk2::Ex::Pod::Syntax::Highlighter $Gtk2::Ex::Pod::Syntax::Highlighter::VERSION, Perl $], $^X" );
