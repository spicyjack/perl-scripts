#!/usr/bin/perl -w

#
# Object Browser - a Gtk2-Perl developer's object and class browser
# (C) 2004, 2008 by muppet <scott at asofyet.org>
#
# POD and license at end of file.
#

use Carp;
use strict;
use warnings;
use Gtk2 -init;
use Gtk2::SimpleList;
our $have_podviewer = eval "use Gtk2::Ex::PodViewer; 1";
use Data::Dumper;

# Let's be lenient, and allow versions before 1.040.  That means we can't
# rely on Glib's TRUE and FALSE to be present.
use constant TRUE => 1;
use constant FALSE => !TRUE;

our @VERSION = 0.009;

our @namespaces = qw(Gtk2 Gtk2::Gdk Gtk2::Gdk::Event);
our %typemap = (
	'Glib::Boolean' => 'boolean',
	'Glib::String'  => 'string',
	'Glib::Int'     => 'integer',
	'Glib::Uint'    => 'unsigned',
	'Glib::Float'   => 'float',
	'Glib::Double'  => 'double',
);

misc_init ();

my @actions = (
  [ 'gtk-quit', "Get Out!", sub {Gtk2->main_quit} ],
  [ 'namespaces', "Edit the list of object namespaces", \&namespaces ],
  [ 'gtk-help', "Help!", \&manual ],
  [ 'gtk-dialog-info', "About this program", \&about ],
);


my $window = Gtk2::Window->new;
$window->signal_connect (delete_event => sub {Gtk2->main_quit});
$window->set_title ('Object Browser');

my $vbox = Gtk2::VBox->new (FALSE, 0);
$window->add ($vbox);

my $toolbar = Gtk2::Toolbar->new;
$vbox->pack_start ($toolbar, FALSE, FALSE, 0);

for (my $a = 0 ; $a < @actions ; $a++) {
	$toolbar->insert_stock ($actions[$a][0], $actions[$a][1], '',
	                        $actions[$a][2], undef, $a);
}

$toolbar->append_widget (Gtk2::VSeparator->new, '', '');
my $search_entry = Gtk2::Entry->new;
$toolbar->append_widget ($search_entry, 'Jump to a specific object by name', '');
my $find = Gtk2::Button->new ('_Find');
$toolbar->append_widget ($find, 'Jump to a specific object by name', '');
$search_entry->signal_connect (activate => sub {$find->clicked});
$find->signal_connect (clicked => \&do_search);
$find->set_sensitive (FALSE);
# don't let the user type spaces in this entry.
$search_entry->signal_connect (insert_text => sub {
	my (undef, $string, undef, $position) = @_;
	$string =~ s/^\s*//;
	$string =~ s/\s*//;
	($string, $position)
});
# the button's sensitivity depends on the contents of the search entry.
$search_entry->signal_connect (changed => sub {
	$find->set_sensitive ($search_entry->get_text);
});

$window->set_focus ($search_entry);

my $hpaned = Gtk2::HPaned->new;
$vbox->pack_end ($hpaned, TRUE, TRUE, 0);
$hpaned->set_position (200);

my $object_model = Gtk2::TreeStore->new ('Glib::String');
my $object_tree = Gtk2::TreeView->new ($object_model);
$object_tree->append_column
	(Gtk2::TreeViewColumn->new_with_attributes
			("Class", Gtk2::CellRendererText->new, text => 0));
my $scroller = Gtk2::ScrolledWindow->new;
$scroller->add ($object_tree);
$scroller->set_policy (qw/automatic automatic/);
$hpaned->add1 ($scroller);



my $notebook = Gtk2::Notebook->new;
$hpaned->add2 ($notebook);


my $prop_tree = PropertyView->new;
$scroller = Gtk2::ScrolledWindow->new;
$scroller->add ($prop_tree);
$scroller->set_policy (qw/automatic automatic/);
$scroller->set_shadow_type ('in');

my $label = Gtk2::Label->new_with_mnemonic ('P_roperties');
$notebook->append_page ($scroller, $label);


my $sig_tree = SignalView->new;
$scroller = Gtk2::ScrolledWindow->new;
$scroller->add ($sig_tree);
$scroller->set_policy (qw/automatic automatic/);
$scroller->set_shadow_type ('in');

$label = Gtk2::Label->new_with_mnemonic ('_Signals');
$notebook->append_page ($scroller, $label);


my $method_tree = MethodView->new;
$scroller = Gtk2::ScrolledWindow->new;
$scroller->add ($method_tree);
$scroller->set_policy (qw/automatic automatic/);
$scroller->set_shadow_type ('in');

$label = Gtk2::Label->new_with_mnemonic ('_Methods');
$notebook->append_page ($scroller, $label);


my $podview = PodView->new;
# this will spew warnings when Gtk2::Ex::PodViewer is not available
$podview->signal_connect (link_clicked => sub {
	my (undef, $text) = @_;
	warn "link clicked";
}) if $podview->isa ('Gtk2::Ex::PodViewer');
$scroller = Gtk2::ScrolledWindow->new;
$scroller->set_policy (qw/automatic automatic/);
$scroller->set_shadow_type (qw/in/);
$scroller->add ($podview);

$label = Gtk2::Label->new_with_mnemonic ('_POD');
$notebook->append_page ($scroller, $label);



fill_tree ($object_tree);
$object_tree->signal_connect (row_activated => sub {
	my ($tree, $path, $column) = @_;
	if ($tree->row_expanded ($path)) {
		$tree->collapse_row ($path);
	} else {
		$tree->expand_row ($path, FALSE);
	}
});
$object_tree->get_selection->set_mode ('browse');
$object_tree->get_selection->signal_connect (changed => sub {
	my $selection = shift;
	my ($model, $iter) = $selection->get_selected;
	return unless $iter;
	my $type = $model->get ($iter, 0);
	$prop_tree->set_type ($type);
	$sig_tree->set_type ($type);
	$method_tree->set_type ($type);
	$podview->set_type ($type);
});

$window->set_default_size (700, 450);
$window->show_all;

Gtk2->main;


sub about {
	my $name = "Object Browser";
	my $description = "An object browser for Gtk2-Perl developers";
	my $copyright = "(c) 2004 by muppet <scott at asofyet dot org>";
	my $dlg;
	if ($Gtk2::VERSION >= 1.040 and Gtk2->CHECK_VERSION (2, 4, 0)) {
		$copyright =~ s/</\&lt;/g;
		$copyright =~ s/>/\&gt;/g;
		$dlg = Gtk2::MessageDialog->new ($window, [], 'info', 'close',
		                                 undef);
		$dlg->set_markup ("<big><b>$name</b></big>\n\n"
		                  ."$description.\n\n"
				  ."$copyright");
	} else {
		# lo-fi fallback
		$dlg = Gtk2::MessageDialog->new ($window, [], 'info', 'close',
		                                 "$name\n\n"
		                                 ."$description.\n\n"
		                                 ."$copyright");
	}
	$dlg->signal_connect (response => sub {$_[0]->destroy});
	$dlg->show;
}

sub connect_proxy {
	my ($uimanager, $action, $proxy, $statusbar) = @_;

	if ($proxy->isa (Gtk2::MenuItem::)) {
		# we know from the design of this particular program that
		# we'll only set up these things once, so we can just use
		# normal closures.  if the objects change on the fly, this
		# construction could be problematic.
		$proxy->signal_connect (select => sub {
			$statusbar->push (0, $action->get ('tooltip') || '')
		});
		$proxy->signal_connect (deselect => sub {
			$statusbar->pop (0)
		});
	}
}

sub fill_tree {
	my $tree = shift;
	my $model = $tree->get_model;

	# search through the symbol table for things which inherit
	# from Glib::Object; then turn this information into a tree
	# representing the object hierarchy.  this will be messy.
	#
	# GObject supports only single inheritance, so we only need to
	# find a single parent inheriting from Glib::Object; the rest
	# of the things in @ISA will be GInterfaces or perl classes.

	my %forward = ();
	foreach my $pkg (@namespaces) {
		no strict;
		my @keys = keys %{ $pkg."::" };

		if (0 == @keys) {
			eval "use $pkg; 1";
			next if $@;
			@keys = keys %{ $pkg."::" };
		}

		foreach my $k (@keys) {
			$k =~ s/^(.*)::$/$pkg\::$1/;
			no strict;
			if ($k->isa (Glib::Object::)) {
				foreach my $p (@{$k."::ISA"}) {
					if ($p->isa (Glib::Object::)) {
						push @{ $forward{$p} }, $k;
						# GObject supports only single
						# inheritance - "there can be
						# only one", and this is it.
						last;
					}
					else {
						print "tossing non-object $p\n";
					}
				}
			}
		}
	}

	push @{ $forward{'Glib::Object'} }, 'Glib::InitiallyUnowned'
		if $Glib::VERSION >= 1.120 && Gtk2->CHECK_VERSION  (2, 10, 0);

	$model->clear;

	# Glib::Object is our starting point...
	my $iter = $model->append (undef);
	$model->set ($iter, 0, 'Glib::Object');
	# add a dummy child, so the row may be expanded.
	$model->append ($iter);

	$model->{forward} = \%forward;

	# load the rest on demand.
	$tree->signal_connect (row_expanded => sub {
		my ($treeview, $iter, $path) = @_;
		add_children ($treeview->get_model, $iter);
	});

	$tree->expand_row ($model->get_path ($iter), FALSE);
}

sub add_children {
	my ($model, $parent) = @_;
	my $class = $model->get ($parent, 0);
	if (exists $model->{forward}{$class} &&
	    $model->iter_n_children ($parent) == 1 &&
	    !$model->get ($model->iter_nth_child ($parent, 0))) {
		my $thisset = $model->{forward}{$class};
		delete $model->{forward}{$class};
		foreach my $child (sort @$thisset) {
			# add this child.
			my $iter = $model->append ($parent);
			$model->set ($iter, 0, $child);
			# set things up to this one may expand if it has
			# children.
			$model->append ($iter)
				if exists $model->{forward}{$child};
		}
		# remove the dummy child.
		$model->remove ($model->iter_nth_child ($parent, 0));
	}
}

sub do_search {
	my $type = $search_entry->get_text;
	return unless $type;
	eval {
		my @ancestors = reverse Glib::Type->list_ancestors ($type);
		my @indices = ();
		my $path = Gtk2::TreePath->new;
		my $model = $object_tree->get_model;
		my $iter = undef;
		ANCESTOR:
		foreach (@ancestors) {
			my $n = $model->iter_n_children ($iter);
			foreach my $i (0..$n-1) {
				my $child = $model->iter_nth_child ($iter, $i);
				if ($_ eq ($model->get ($child, 0))[0]) {
					$iter = $child;
					$path->append_index ($i);
					# force lazy-loading
					$object_tree->expand_to_path ($path);
					next ANCESTOR;
				}
			}
			
			croak "Can't find ancestor $_ of $type";
		}
		$object_tree->get_selection->select_path ($path);
		$object_tree->scroll_to_cell ($path);
	};
	if ($@) {
		$@ =~ s/ at .* line \d+//
			if $@ =~ /not registered with/;
		error ($@);
	};
}

sub error {
	my $dlg = Gtk2::MessageDialog->new ($window, [], 'error', 'ok', $_[0]);
	$dlg->run;
	$dlg->destroy;
}

sub namespaces {
	if ($window->{namespaces_window}) {
		$window->{namespaces_window}->present;
		return;
	}

	my $dialog = Gtk2::Dialog->new ('Namespaces', $window,
	                                'destroy-with-parent',
	                                'gtk-apply' => 'accept',
					'gtk-close' => 'close');

	my $hbox = Gtk2::HBox->new (FALSE, 6);
	$hbox->set_border_width (6);
	$dialog->vbox->add ($hbox);

	my $namespaces = Gtk2::SimpleList->new ('' => 'text');
	$namespaces->set_headers_visible (FALSE);
	$namespaces->set_column_editable (0, TRUE);
	@{ $namespaces->{data} } = @namespaces;

	my $scroller = Gtk2::ScrolledWindow->new;
	$scroller->set_shadow_type ('in');
	$scroller->set_policy ('never', 'automatic');
	$scroller->add ($namespaces);

	$hbox->add ($scroller);

	my $vbox = Gtk2::VBox->new (FALSE, 6);
	$hbox->pack_start ($vbox, FALSE, FALSE, 0);

	my $add = Gtk2::Button->new_from_stock ('gtk-add');
	$vbox->pack_start ($add, FALSE, FALSE, 0);
	$add->signal_connect (clicked => sub {
		my $model = $namespaces->get_model;
		my $path = $model->get_path ($model->append);
		$namespaces->scroll_to_cell ($path, undef, TRUE, 1.0, 0.0);
		# let the scrolling finish before we set the cell editable.
		Gtk2->main_iteration while Gtk2->events_pending;
		$namespaces->set_cursor ($path,
		                         $namespaces->get_column (0), TRUE);
	});

	my $remove = Gtk2::Button->new_from_stock ('gtk-remove');
	$vbox->pack_start ($remove, FALSE, FALSE, 0);
	$remove->set_sensitive (FALSE);
	$namespaces->get_selection->signal_connect (changed => sub {
		$remove->set_sensitive ($_[0]->count_selected_rows)
	});
	$remove->signal_connect (clicked => sub {
		if ($Gtk2::VERSION < 1.030) {
			# splice isn't fully implemented on SimpleList in this
			# version of Gtk2.  we'll have to remove the selected
			# row by hand.
			my $path = $namespaces->get_selection->get_selected_rows;
			my $model = $namespaces->get_model;
			$model->remove ($model->get_iter ($path));
		} else {
			my ($sel) = $namespaces->get_selected_indices;
			print "selected $sel\n";
			splice @{ $namespaces->{data} }, $sel, 1;
		}
	});

	$dialog->signal_connect (delete_event => sub {
		$dialog->response ('delete-event');
		return TRUE;
	});
	$dialog->signal_connect (response => sub {
		my (undef, $response) = @_;
		if ($response eq 'accept') {
			@namespaces = grep { length } # ignore blanks
			              map { $_->[0] } @{$namespaces->{data}};
			fill_tree ($object_tree);
		} else {
			$dialog->hide;
		}
	});
	$dialog->show_all;
	$window->{namespaces_window} = $dialog;
}


#
# gtk_tree_view_expand_to_path() was not available in 2.0.x; here's our
# own implementation as a fallback.
#
sub expand_to_path {
	my ($tree_view, $path) = @_;
	my $tmp = Gtk2::TreePath->new;
	foreach my $i ($path->get_indices) {
		$tmp->append_index ($i);
		$tree_view->expand_row ($tmp, FALSE);
	}
}

my @namespaces_xpm;
BEGIN {
    @namespaces_xpm = (
	'48 48 7 1',
	' 	c None',
	'.	c #0C0707',
	'+	c #FEFEFE',
	'@	c #D31B1B',
	'#	c #F0F0F0',
	'$	c #AE5B5B',
	'%	c #D9D9D9',
	'                                                ',
	'                                                ',
	'                                                ',
	'                                                ',
	'                                                ',
	'                                                ',
	'                                                ',
	'       @@@@@@          @@@@@@                   ',
	'       @@@@@@@         @@@@@@                   ',
	'       @@@@@@@@        @@@@@@                   ',
	'       @@@@@@@@        @@@@@@                   ',
	'       @@@@@@@@@       @@@@@@                   ',
	'       @@@@@@@@@@      @@@@@@                   ',
	'       @@@@@@@@@@@     @@@@@@                   ',
	'       @@@@@@@@@@@     @@@@@@                   ',
	'       @@@@@@@@@@@@    @@@@@@.                  ',
	'       @@@@@@@@@@@@@...@@@@@.......             ',
	'       @@@@@@@@@@@@@....@@@@@.........          ',
	'       @@@@@@@@@@@@@@..@@@@@............        ',
	'       @@@@@ @@@@@@@@@.@@@@@@............       ',
	'       @@@@@  @@@@@@@@..@@@@...............     ',
	'       @@@@@   @@@@@@@@@@@@@@%$$...........     ',
	'       @@@@@  .@@@@@@@@@@@@@$##%%...........    ',
	'       @@@@@  ..@@@@@@@@@@@@$###+%...........   ',
	'       @@@@@ ....@@@@@@@@@@@$+++++$..........   ',
	'       @@@@@......@@@@@@@@@@$++++++..........   ',
	'       @@@@@......@@@@@@@@@@$++++++%.........   ',
	'       @@@@@......@@@@@@@@@@$+++++#%.........   ',
	'       @@@@@......$%@@@@@@@@$+++++++$........   ',
	'       @@@@@......$#$@@@@@@@$++++++#$........   ',
	'       @@@@@......$#$@@@@@@@$+++++++%........   ',
	'       @@@@@.......++$@@@@@@$+++++#%%........   ',
	'       @@@@@.......#++%@$$$$%#+++++#$........   ',
	'           ........$+#++++##+++++++#$.......    ',
	'           .........%++++++++++++++%........    ',
	'           ..........%++++++++++++%%.......     ',
	'           ...........%%+++++++++#$........     ',
	'            ............$%%%%#%%%$........      ',
	'            ..............................      ',
	'             ............................       ',
	'              ...........................       ',
	'               .........................        ',
	'                .......................         ',
	'                 .....................          ',
	'                   ..................           ',
	'                     ..............             ',
	'                        .....                   ',
	'                                                ',
    );
}

sub misc_init {
	Gtk2::Stock->add ({
		stock_id => 'namespaces',
		label    => '_Namespaces',
	});

	my $pixbuf = Gtk2::Gdk::Pixbuf->new_from_xpm_data (@namespaces_xpm);
	my $icon_set = Gtk2::IconSet->new_from_pixbuf ($pixbuf);
	my $icon_factory = Gtk2::IconFactory->new;
	$icon_factory->add ('namespaces', $icon_set);
	$icon_factory->add_default;

	if (not Gtk2->CHECK_VERSION (2, 2, 0)) {
		no warnings; # quell "used only once" warnings about next line:
		*Gtk2::TreeView::expand_to_path = \&expand_to_path;
	} else {
		Glib::set_application_name ("Object Browser")
			if $Glib::VERSION >= 1.040;
	}
}

sub manual {
	my $dlg = Gtk2::Dialog->new ('Help', $window, 'destroy-with-parent',
	                             'gtk-close' => 'close');
	$dlg->signal_connect (response => sub {$dlg->destroy});
	$dlg->set_default_size (400, 300);

	my $manual;
	if ($have_podviewer) {
		# yippee, skippee!
		$manual = Gtk2::Ex::PodViewer->new;
		$manual->load ($0);
	} else {
		# oh, bother.
		$manual = Gtk2::TextView->new;
		my $buffer = $manual->get_buffer;
		# on some systems, certain values of TERM will cause perldoc
		# to put formatting characters into the text; this is an
		# attempt to prevent that.
		local $ENV{TERM} = '';
		my $text = `perldoc $0`;
		$buffer->insert ($buffer->get_start_iter, $text);

		$dlg->vbox->pack_start (Gtk2::Label->new
				("You don't have Gtk2::Ex::PodViewer installed;"
				 ." falling back to plain text.\nThis could"
				 ." be very ugly and hard to read.\nPlease"
				 ." consider getting Gtk2::Ex::PodViewer from"
				 ." CPAN."), FALSE, FALSE, 10); 
	}

	my $scroller = Gtk2::ScrolledWindow->new;
	$scroller->set_policy ('automatic', 'automatic');
	$scroller->set_shadow_type ('in');
	$scroller->add ($manual);
	$dlg->vbox->add ($scroller);

	$dlg->show_all;
}

#===========================================================================
package PropertyView;

use strict;
use constant TRUE => 1;
use Gtk2;
BEGIN { our @ISA = qw(Gtk2::TreeView); }

sub new {
	my $class = shift;
	my $model = Gtk2::ListStore->new ('Glib::String', # name
	                                  'Glib::String', # type
	                                  'Glib::String', # flags
	                                  'Glib::String', # descr
	                                 );
	my $self = Gtk2::TreeView->new ($model);
	$self->set_rules_hint (TRUE);
	$self->get_selection->set_mode ('none');
	foreach ([Name        => 0],
	         [Type        => 1],
		 [Flags       => 2],
		 [Description => 3]) {
		my $col = Gtk2::TreeViewColumn->new_with_attributes
					($_->[0], Gtk2::CellRendererText->new,
					 text => $_->[1]);
		$col->set_sizing ('autosize');
		$self->append_column ($col);
	}
	return bless $self, $class;
}

sub set_type {
	my ($propview, $typename) = @_;

	return if $propview->{type} and $propview->{type} eq $typename;
	$propview->{type} = $typename;

	my $model = $propview->get_model;
	$model->clear;

	eval {
		foreach my $p (sort { $a->{name} cmp $b->{name} }
		               grep { $_->{owner_type} eq $typename }
			       $typename->list_properties) {
			my $iter = $model->append;
			my $flagsstr = '';
			$flagsstr .= 'R' if $p->{flags} >= 'readable';
			$flagsstr .= 'W' if $p->{flags} >= 'writable';
			$flagsstr .= 'c' if $p->{flags} >= 'construct';
			$flagsstr .= 'C' if $p->{flags} >= 'construct-only';
			$flagsstr .= 'P' if $p->{flags} >= 'private';
			$model->set ($iter,
			             0, $p->{name},
				     1, $main::typemap{$p->{type}} || $p->{type},
				     2, $flagsstr,
				     3, $p->{descr} || '');
		}
	};
	# if the class is not a GType, but just inherits perl-wise (e.g.
	# SimpleList), then the bindings will warn "package ... is not 
	# registered with GPerl".  we might want to do something spiffy
	# like change it to gray or italics or something.
	warn $@ if $@;
}


#===========================================================================
package SignalView;

use strict;
use constant TRUE => 1;
use Gtk2;
BEGIN { our @ISA = qw(Gtk2::TreeView); }

sub new {
	my $class = shift;
	my $model = Gtk2::ListStore->new ('Glib::String', # name
	                                  'Glib::String', # type
	                                  'Glib::String', # flags
	                                  'Glib::String', # descr
	                                 );
	my $self = Gtk2::TreeView->new ($model);
	$self->set_rules_hint (TRUE);
	$self->get_selection->set_mode ('none');
	foreach (['Return Type' => 0],
	         [Name          => 1],
		 ['Param Types' => 2],
		 [Flags         => 3]) {
		my $col = Gtk2::TreeViewColumn->new_with_attributes
					($_->[0], Gtk2::CellRendererText->new,
					 text => $_->[1]);
		$col->set_sizing ('autosize');
		$self->append_column ($col);
	}
	return bless $self, $class;
}

sub set_type {
	my ($sigview, $typename) = @_;

	return if $sigview->{type} and $sigview->{type} eq $typename;
	$sigview->{type} = $typename;

	my $model = $sigview->get_model;
	$model->clear;

	eval {
		foreach my $s (sort { $a->{signal_name} cmp $b->{signal_name} }
		               grep { $_->{itype} eq $typename }
			       Glib::Type->list_signals ($typename)) {
			my $iter = $model->append;
			my $ret = $s->{return_type}
				? $main::typemap{$s->{return_type}} ||
			          $s->{return_type}
				: '';
			my $params = $s->{param_types}
			           ? join ', ', map {
			                   $main::typemap{$_} || $_
			             } @{$s->{param_types}}
			           : '';
			$model->set ($iter,
			             0, $ret,
				     1, $s->{signal_name},
				     2, $params,
				     3, "@{$s->{signal_flags}}");
		}
	};
	# if the class is not a GType, but just inherits perl-wise (e.g.
	# SimpleList), then the bindings will warn "package ... is not 
	# registered with GPerl".  we might want to do something spiffy
	# like change it to gray or italics or something.
	warn $@ if $@;
}

#===========================================================================
package MethodView;

use strict;
use constant TRUE => 1;
use Gtk2;
BEGIN { our @ISA = qw(Gtk2::TreeView); }

sub new {
	my $class = shift;
	my $model = Gtk2::ListStore->new ('Glib::String', # name
	                                 );
	my $self = Gtk2::TreeView->new ($model);
	$self->set_rules_hint (TRUE);
	$self->get_selection->set_mode ('none');
	foreach ([Name => 0]) {
		my $col = Gtk2::TreeViewColumn->new_with_attributes
					($_->[0], Gtk2::CellRendererText->new,
					 text => $_->[1]);
		$col->set_sizing ('autosize');
		$self->append_column ($col);
	}
	return bless $self, $class;
}

sub set_type {
	my ($sigview, $typename) = @_;

	return if $sigview->{type} and $sigview->{type} eq $typename;
	$sigview->{type} = $typename;

	my $model = $sigview->get_model;
	$model->clear;

	foreach my $m (SymbolScraper::get_methods_from ($typename)) {
		my $iter = $model->append;
		$model->set ($iter, 0, $m);
	}
}

#===========================================================================
package PodView;

use strict;
use constant FALSE => !1;
use Gtk2;
our @ISA;

sub new {
	my $class = shift;
	my $self;
	if ($main::have_podviewer) {
		$self = Gtk2::Ex::PodViewer->new;
	} else {
		$self = Gtk2::TextView->new;
	}
	push @ISA, ref $self;
	return bless $self, $class;
}

sub set_type {
	my ($podview, $typename) = @_;

	return if $podview->{type} and $podview->{type} eq $typename;
	$podview->{type} = $typename;

	Glib::Source->remove ($podview->{timeout})
		if $podview->{timeout};

	$podview->{timeout} = Glib::Timeout->add (1000, sub {
		if ($podview->isa ('Gtk2::Ex::PodViewer')) {
			$podview->load ($typename)
				or $podview->clear;
		} else {
			my $buffer = $podview->get_buffer;
			$buffer->delete ($buffer->get_start_iter,
			                 $buffer->get_end_iter);
			# on some systems, certain values of TERM will cause
			# perldoc to put formatting characters into the text;
			# this is an attempt to prevent that.
			local $ENV{TERM} = '';
			my $text = `perldoc $typename`;
			$buffer->insert ($buffer->get_start_iter, $text);
		}
		undef $podview->{timeout};
		FALSE;
	});
}

#===========================================================================
package SymbolScraper;

sub get_methods_from {
	my $pkg = shift;
	my @methods = ();
	no strict 'refs';
	foreach my $k (keys %{ $pkg.'::' }) {
		push @methods, $k
			if *{ $pkg.'::'.$k }{CODE};
	}
	return sort sort_methods @methods;
}

sub sort_methods {
	my ($at, $bt);
	for ($at=$a, $bt=$b) {
		# remove prefixes
		s/^.+:://;
		# new's goto the front
		s/^new/\x00/;
		# group set's/get'ss
		s/^(get|set)_(.+)/$2_$1/;
		# put \<set\>'s with \<get\>'s
		s/^(get|set)$/get_$1/;
	}
	# now actually do the sorting compare
	$at cmp $bt; 
}

#===========================================================================
package main;

__END__

=head1 NAME

object_browser

=head1 SYNOPSIS

  object_browser

=head1 DESCRIPTION

This gtk2-perl utility displays information about Glib::Objects.
The code actually scrapes through the Perl symbol table for packages that
derive from Glib::Object, and then queries the GLib type system for information
about those objects.

If you have Gavin Brown's excellent L<Gtk2::Ex::PodViewer> installed, you can
also look at the POD for those objects.

The user interface is in two main parts; an object hierarchy on the left,
and a notebook full of information panels on the right.  The panels on the
right display information about the currently selected node in the tree on
the left.  (Fairly standard stuff.)

=head2 WHERE ARE MY OBJECTS?

As mentioned above, the program scrapes the Perl symbol table for packages
derived from Glib::Object.  By default, the program scrapes only three
namespaces, Gtk2, Gtk2::Gdk, and Gtk2::Gdk::Event.  You can easily add other
namespaces at runtime by clicking on the "Namespaces" button and editing the
list.  (Hint: double-click a row to edit it.)

If a package named in the list contains no symbols, the program does an

  eval "use $pkg; 1";

to load it, and then tries again.  Any objects found in that namespace will
be inserted into the proper places in the hierarchy (so you may not see them
immediately).

This way you can look at Gnome2, Gnome2::Canvas, etc, without having to edit
the code of the object browser itself.  :-)

=head1 BUGS

This is a work in progress; many features are missing, including the spiffy
action-based menus which require gtk+ 2.4.0.

No support for GInterfaces.  Don't really know what to do about this.

No support for listing enum and flag values.  This is possible, but collecting
enum values will not be easy as they don't get registered in the same way as
flags types.

=head1 AUTHOR

muppet <scott at asofyet dot org>, with inspiration from the examples
and tests distributed with gtk+.

=head1 SEE ALSO

L<Glib>, L<Gtk2>, L<http://gtk2-perl.sourceforge.net/>.

Gavin Brown's L<Gtk2::Ex::PodViewer> will be used if available.

=head1 COPYRIGHT and LICENSE

(c) 2004, 2008 by muppet <scott at asofyet dot org>.  All rights reserved.
This program is free software; you can redistribute it and/or modify
it under the same terms as Perl itself. 

=cut

__DATA__

GInterface
	Gtk2::TreeModel
	Gtk2::TreeDragSource
	Gtk2::TreeDragDest
	Gtk2::TreeSortable
	Gtk2::Editable
	Gtk2::CellEditable
	Gtk2::FileChooser
