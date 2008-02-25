#!/usr/bin/perl

# On 14/02/2008, Jeffrey Ratcliffe <jeffrey.ratcliffe@gmail.com>

use warnings;
use strict;
use Socket;
use Gtk2 -init;
use Glib qw(TRUE FALSE);             # To get TRUE and FALSE
use FileHandle;
use POSIX;

# Create the windows
my $window = Gtk2::Window->new('toplevel');
my $box = Gtk2::VBox->new;
my $entry = Gtk2::Entry->new;
my $pbar = Gtk2::ProgressBar->new;
my $button = Gtk2::Button->new('Quit');

my ($child, $parent);
start_process();

$window->add ($box);
$box->add($entry);
$box->add($pbar);
$box->add($button);

my %helperTag;

# We should also link this to the destroy message on the main window,
# this is just quick and dirty
$button->signal_connect(clicked => \&on_quit_clicked);
$entry->signal_connect(activate => sub {send($parent, $entry->get_text, 0)});
$window->show_all;
Gtk2->main;


# Process the exit of the child. If you were doing something useful,
# you might keep things like information about what data needs
# to be reloaded when a child process exits.

sub sig_child {
 my $pid = wait;
 if ($pid >= 0) {
 delete $helperTag{$pid};
 }
}

$SIG{CHLD} = \&sig_child;

sub start_process {
 my $pid;

 $child = FileHandle->new;
 $parent = FileHandle->new;
 socketpair($child, $parent,  AF_UNIX, SOCK_DGRAM, PF_UNSPEC);
 binmode $child, ':utf8';
 binmode $parent, ':utf8';

 $pid = fork();

 if ($pid) {
 # We're still in the parent, set up to watch the streams:

 my $line;
 $helperTag{$pid} = Glib::IO->add_watch($parent->fileno(), ['in', 'hup'], sub {
  my ($fileno, $condition) = @_;

  if ($condition & 'in') { # bit field operation. >= would also work
   recv($parent, $line, 1000, 0);
   if (defined($line) and $line =~ /(\d*\.?\d*)(.*)/) {
    my $fraction=$1;
    my $text=$2;
    $pbar->set_fraction($fraction);
    $pbar->set_text($text);
   }
  }

# Can't have elsif here because of the possibility that both in and hup are set.
# Only allow the hup if sure an empty buffer has been read.
  if (($condition & 'hup') and (! defined($line) or $line eq '')) { # bit field operation. >= would also work
   return FALSE;  # uninstall
  }
  return TRUE;  # continue without uninstalling
 });
 }
 else {
    # We're in the child. Do whatever processes we need to. We *must*
    # exit this process with POSIX::_exit(...), because exit() would
    # "clean up" open file handles, including our display connection,
    # and merely returning from this subroutine in a separate process
    # would *really* confuse things.

 $pid = getpid();

# Now block until the GUI passes a message
 while (TRUE) {
  my $rin = '';
  my $rout = '';
  vec($rin, $child->fileno(), 1) = 1;
  my $line;
  if (select($rout=$rin,undef,undef,undef)) {
   recv($child, $line, 1000, 0);
  }
  POSIX::_exit(0) if ($line eq '-1');

  my $n = 4;
  for (my $i = 0; $i <= $n; $i++) {
   sleep(1);
   send($child, $i/$n."Running $line $i of $n\n", 0);
  }
 }
 }
}


# We should clean up after ourselves so that we don't
# leave dead processes flying around.
sub on_quit_clicked {
   # 15 = SIGTERM
 kill 15, $_ foreach (keys %helperTag);
 Gtk2->main_quit;
}
