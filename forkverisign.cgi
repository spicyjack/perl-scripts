#!/usr/bin/perl

# Fork Verisign
# An attempt to point out to VeriSign the stupidity of wildcarding .com/.net
# and to slow spammers at the same time

# Written by Sam Bashton, sam@forkqueue.com

# This program is release under the terms of the GNU GPL v2.0 or later at
# your option

use strict;
use CGI;
use Net::DNS;

use constant VERIP => '64.94.110.11'; # When we lookup a non-existant domain
				     # this should be returned.

my $page = new CGI;
print $page->header,
      $page->start_html('Fork Verisign');

my $address = gen_address();
print <<BLAH;

Hello,
<P>
This is a page designed to bombard Verisign's servers with requests from
spammers.  It is based on an idea by Pat Lashley in a post to the exim-users
list.  It generates a random email address at a random non-existant domain (it
always makes sure it <i>is</i> a random domain) with the idea that this will
then be picked up by spammers.  As Verisign have now taken the insane step of
adding .com and .net wildcard addresses, their servers will then be swamped
with emails offering penis enlargment and the like.  If you have any questions,
don't contact me at the email address below, it doesn't exist:<P>
<A HREF="mailto:$address">$address</A>
<P>
<A HREF="fork.tar.gz">Download the source for this page</A>
BLAH
print $page->end_html;
exit 0;

###############################################################################

sub gen_address
{
  my $tld    = ".com";
  my $domain = gen_str(10).$tld;
  my $user   = gen_str(12);

  while(dom_exist($domain))
  { $domain = gen_str(10).$tld } # Generate a new domain if this one exists

  return $user."@".$domain;
}

sub gen_str
{
  my @chars = ('a','b','c','d','e','f','g','h','i','j','k','l','m','n','o','p','q','r','s','t','u','v','w','x','y','z','0','1','2','3','4','5','6','7','8','9');
  my $maxlength = shift;
  my $length = int(rand($maxlength) + 0.5);
  my $string;
  for (my $i = 0; $i <= $length; $i++)
  {
    $string .= $chars[int(rand(scalar(@chars)) + 0.5)];
  } 
  return $string;
}    

sub dom_exist
{
  my $res  = Net::DNS::Resolver->new;
  my $query = $res->search($_[0]);

  if ($query)
  {
    foreach my $rr ($query->answer)
    {
      next unless $rr->type eq "A";
      if ($rr->address eq VERIP) { return 0; }
    }
  }
  else
  {
    # Maybe Verisign have seen the error of their ways?
    print "Unable to check IP",
    $page->end_html;
    exit 1;
  }
  # If we got here the domain must exist
  return 1;
}
