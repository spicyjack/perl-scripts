#!/usr/bin/perl

# script to show loaded modules and module versions
# taken from dbi-users mailing list post:
# http://www.nntp.perl.org/group/perl.dbi.users/2009/08/msg34210.html
{
    no strict 'refs';
    foreach (sort keys %INC) {
         next unless m{^(.*)\.pm$};
          (my $mod = $1) =~ s{[\\/]+}{::}g;
           print "$mod : ${$mod . '::VERSION'}\n"
    }
}
