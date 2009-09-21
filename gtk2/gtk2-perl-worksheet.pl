#!/usr/bin/perl -w

package Worksheet;


use strict;
use Glib qw(:constants);
use Gtk2;
use Gtk2::Gdk::Keysyms;

use Glib::Object::Subclass
    'Gtk2::TextView',
    signals => {
	key_press_event => sub {
		my ($self, $event) = @_;
		if ($event->keyval == $Gtk2::Gdk::Keysyms{KP_Enter}) {
			$self->eval_selection;
			return TRUE;
		} else {
			return $self->signal_chain_from_overridden ($event);
		}
	},
    },
    ;


sub eval_selection {
	my $self = shift;
	my $buffer = $self->get_buffer;
	my $insert;
	my ($start, $end) = $buffer->get_selection_bounds;
	if (not defined $end or $start == $end) {
		$insert = $buffer->get_iter_at_mark ($buffer->get_insert);
		$start = $insert;
		$end = $start->copy;
		$start->backward_line;
		$end->forward_line;
		$insert = $end->copy;
		$end->backward_char;
	} else {
		$insert = $end->copy;
		$insert->forward_line;
	}
	return $self->eval ($buffer->get_slice ($start, $end, TRUE),
	                    $insert);
}

sub eval {
	my ($self, $code, $iter) = @_;
	my $buffer = $self->get_buffer;

	{
	no strict;
	eval $code;
	if ($@) {
		$buffer->insert ($iter, $@."\n");
	}
	}
}


package WorksheetWindow;

# more like an app window.  this tracks instances.

use strict;
#use Glib qw(:constants);
use Gtk2;

my @windows = ();

use Glib::Object::Subclass
    'Gtk2::Window',
    properties => [
	Glib::ParamSpec->object ('worksheet', 'Worksheet',
				 'The Worksheet object for this window',
				 'Worksheet', 'readable'),
    ],
    signals => {
	destroy => sub {
		my $self = shift;
		warn "destroy, $self, @windows\n";
		for (my $i = 0 ; $i < @windows ; $i++) {
			if ($windows[$i] == $self) {
				splice @windows, $i, 1;
				last;
			}
		}
		warn "destroy, $self, @windows\n";
		Gtk2->main_quit if 0 == @windows;
		$self->signal_chain_from_overridden;
	},
    },
    ;

sub INIT_INSTANCE {
	my $self = shift;
	my $scroller = Gtk2::ScrolledWindow->new;
	$self->add ($scroller);
	$scroller->show;
	$self->{worksheet} = new Worksheet;
	$scroller->add ($self->{worksheet});
	$self->{worksheet}->show;

	# track instances
	push @windows, $self;
}


package main;

use strict;
use Gtk2 -init;

my $window = new WorksheetWindow;
$window->show;

Gtk2->main;
