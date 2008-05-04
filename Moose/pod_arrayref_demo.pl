#!/usr/bin/env perl

    package Fruit;
    use Moose;

    has q(name) => ( is => q(rw), required => 1 );
    has q(species) => ( is => q(rw), required => 1 );

    package ProduceStore;
    use Moose;
    use Moose::Util::TypeConstraints;

    has q(fruit_aisle) => ( is => q(rw), isa => q(ArrayRef[Fruit]) );

    sub show_inventory { 
        foreach my $item ( @{$store->fruit_aisle} ) {
            print qq(Item: ) . blessed $item . q(; name: ) . $item->name
                . q(; species: ) . $item->species . qq(\n);
        } # foreach my $item ( @{$inventory} )
    } # sub show_inventory

    package main;
    use Moose; # gains 'blessed' function 
    # we need something to put in the fruit aisle
    my $orange = Fruit->new( name => q(orange), species => q(C. sinensis) );
    my $apple = Fruit->new( name => q(apple), species => q(M. domestica) );
    my @fruits = ( $apple, $orange );
    my $store = ProduceStore->new( fruit_aisle => \@fruits );

    $store->show_inventory;
    # FIXME add another array here; does it append to or replace the existng
    # array?

    exit 0;
