#!/usr/bin/perl

# script to pop mail and re-mail it to another address.  basically a scripted
# mail forwarder.  Thanks Joann, without your motivation, I would have never
# written something like this...

$pop_server = "localhost";
$username = "raivyn";
$password = "6gieN8tQd";


$pop = Net::POP3->new($pop_server)
    or die "Can't open connection to $pop_server : $!\n";
defined ($pop->login($username, $password))
    or die "Can't authenticate: $!\n";
$messages = $pop->list
    or die "Can't get list of undeleted messages: $!\n";
foreach $msgid (keys %$messages) {
    $message = $pop->get($msgid);
    unless (defined $message) {
        warn "Couldn't fetch $msgid from server: $!\n";
        next;
	}
    # $message is a reference to an array of lines
    $pop->delete($msgid);
}
