#!/usr/bin/perl

use IO::Socket;
use CGI qw(:standard);

if (param()) {
    $remote_port = &param("remote_port");
    $remote_host = &param("remote_host");
    $virtual_host = &param("virtual_host");
} # if param

if (! $remote_port) {$remote_port = "80"}

if ($remote_host && $virtual_host) {    
   
    $socket = IO::Socket::INET->new(PeerAddr => $remote_host,
                                    PeerPort => $remote_port,
                                    Proto    => "tcp",
                                    Type     => SOCK_STREAM)
        or die "Couldn't connect to $remote_host:$remote_port : $@\n";

    # smack the server around, so it spits out output
    # this should be enough to get the server to work
    print $socket "GET / HTTP/1.1\n";
    print $socket "Host: $virtual_host\n";
    print $socket "User-Agent: hosttest.pl by Brian Manning (c)2000\n\n";

    # now read in what the server returns us
    while ( $answer = <$socket> ) { 
        # copy the server output over to another variable
        $answer =~ s/</&lt;/;
        $answer =~ s/>/&gt;/;
        $server_output .= $answer; 
        # and terminate the connection when we're done
        if ($answer =~ /<\/HTML>/i) {close($socket)}
    } # while $answer
} # if $remote_host && $virtual_host

# start the HTML part
print header, start_html("hosttest.pl Virtual Host Tester");

print h2("Virtual Host Test Script");
print p("Enter the IP, Virtual Host Name, and port of the machine that you want
to check");

print start_form();
print p("Host IP: ", textfield("remote_host", $remote_host, 30, 50));
print p("Virtual host name: ", 
        textfield("virtual_host", $virtual_host, 30, 50));
print p("Port Number: ", textfield("remote_port", $remote_port, 5 , 5));
print p(submit("Go get it!"), reset("Reset"));
print end_form(), hr();

if ($server_output) {
   print "<PRE>$server_output</PRE>"; 
#   print textarea("server_output", $server_output, 20, 80); 
} # if $server_output

print end_form();
print end_html;
