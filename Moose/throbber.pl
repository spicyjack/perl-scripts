#!/usr/bin/perl

# script to display a throbber

package Throbber;
use Moose; # comes with 'strict' and 'warnings'
use Time::HiRes qw(usleep);

has q(count_pulse) => ( is => q(rw), isa => q(Int), default => 10 );
has q(_beats) => ( is => q(rw), isa => q(Int), default => 1);

sub throb {
    my $self = shift;
    my %args = @_;

    if ( defined $args{total_lines} ) {
    # set non-buffering output on STDOUT
    $| = 1;
#print qq(total lines mod count pulse is ) .
#$args{total_lines} % $self->count_pulse() . qq(\n);
#        if ( ( $args{total_lines} % $self->count_pulse() ) == 0 ) {
            #print qq(self->_beats is ) . $self->_beats() . qq(\r);
            if ( $self->_beats == 1 ) { print q(- ); }
            elsif ( $self->_beats == 2 ) { print q(\ ); }
            elsif ( $self->_beats == 3 ) { print q(| ); }
            elsif ( $self->_beats == 4 ) {
                print q(/ );
                $self->_beats(0);
            } # if ( $self->_beats == 1 )
            $self->_beats($self->_beats() + 1);
            print q(Total Lines counted: ) . $args{total_lines} . qq(\r);
            usleep(100);
#        } # if ( ( $args{total_lines} % $self->count_pulse() ) == 0 )
    } # if ( defined $args{total_lines} )
} # sub throb

package main;
my $throbber = Throbber->new( count_pulse => 1 );
foreach my $total_lines ( 1..100 ) {
    $throbber->throb(total_lines => $total_lines); 
} # foreach my $total_lines ( 1..100 )

