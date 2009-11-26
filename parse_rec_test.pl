#!/usr/bin/perl

=pod

=head1 NAME

B<testparse.pl> - Read a file on STDIN and parse Cisco router/switch options


=head1 DESCRIPTION

This should print out some text when called with C<pod2usage> from
L<Pod::Usage>.

=cut

use strict;
use warnings;
use CiscoParse::Parser;

my $parser = CiscoParse::Parser->new();

    # block of text that would indicate an interface of some sort
    my $textblock;
    while ( defined(my $text = <STDIN>) ) {
        if ( $text =~ /^interface/ ) {
            # line starts with 'interface'
            # reset $textblock, as this is a new block of text
            $textblock = $text;
            # read lines until the end of this block, a block being a line that
            # doesn't start with a cisco comment character (!)
            my $line;
            $textblock .= <STDIN>; 
            CURRBLOCK: while ( defined($line = <STDIN>) ) {
                if ( $line =~ /^!/ ) {
                    last CURRBLOCK; # skips out of this while block
                } else {
                    # add the current line to the block of text
                    $textblock .= $line;
                } # if ( $line =~ /^!/ )
            } # while ( ! defined $endblock )

            my $parser_return = $parser->parse($textblock);
            if ( ! defined $parser_return ) {
                my $first_line = (split(qq(\n), $textblock))[0];
                if ( $textblock =~ /shutdown/ ) {
                    print qq(~~~ shutdown interface: $first_line\n);
                } else {
                    print qq(--- block doesn't match: $first_line \n);
                } # if ( $textblock =~ /shutdown/ )
            } else {
                my %out = %{$parser_return};
                print qq(=== matched block: ) 
                    . $out{q(__RULE__)} . qq( ===\n);
                foreach my $key ( sort(keys(%out)) ) {
                    # in the parser rule definition, there are fields used as
                    # "labels", or text that never changes; these get made
                    # into hash keys, and we don't need them for anything, so
                    # we skip out of them here
                    next if ( $key =~ /l_/ ); 
                    next if ( $key =~ /__ACTION.*__/ );
                    next if ( $key =~ /__PATTERN.*__/ );
                    my $keyval = $out{$key};
                    if ( $key eq 'description(?)' ) {
                        # Optional descriptions appear in nested ARRAYs, but
                        # shouldn't be treated as vlan ranges
                        print qq(\tdescription -> $keyval->[0]\n);
                    }
                    elsif ( ref($keyval) =~ /ARRAY/ ) {
                        my @vlans = @{$keyval};
                        # check all of the vlan values to see if there's a
                        # range of vlan ports; expand that range of ports
                        my @checked_vlans;
                        foreach my $vlan_num ( @vlans ) {
                            if ( $vlan_num =~ /-/ ) {
                                my ($low, $high) = split(/-/, $vlan_num);
                                push(@checked_vlans, ($low .. $high));
                            } else {
                                push(@checked_vlans, $vlan_num);
                            } # if ( $vlan_num =~ /-/ )
                        } # foreach my $vlan_num ( @vlans )
                        print qq(\t$key -> ) 
                            . join(q(:), @checked_vlans) . qq(\n);
                    } else {
                        print qq(\t$key -> $keyval\n);
                    } # if ( ref($keyval) =~ /ARRAY/ )
                } # foreach my $key ( sort(keys(%out)) )
            } # if ( ! defined $parser_return )
        } else { 
            next;   # not a block of text we're looking for; start again from
                    #the top
        } # if ( $text ~= /^interface/ )
    } # while ( defined(<STDIN>) )

exit 0;
