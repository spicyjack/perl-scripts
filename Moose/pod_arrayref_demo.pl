#!/usr/bin/env perl

    package Fruit;
    use Moose;

    has q(name) => ( is => q(rw), required => 1 );
    has q(species) => ( is => q(rw), required => 1 );

    package ProduceStore;
    use Moose;
    use Moose::Util::TypeConstraints;

    has q(fruit_aisle) => ( is => q(rw), isa => q(ArrayRef[Int]) );

    sub show_inventory { 
        my $self = shift;
        foreach my $item ( @{$self->fruit_aisle} ) {
            print qq(Item: ) . blessed($item) . q(; name: ) . $item->name
                . q(; species: ) . $item->species . qq(\n);
        } # foreach my $item ( @{$inventory} )
    } # sub show_inventory

    package main;
    use Moose; # gains 'blessed' function 
    # we need something to put in the fruit aisle
    my $orange = Fruit->new( name => q(orange), species => q(C. sinensis) );
    my $apple = Fruit->new( name => q(apple), species => q(M. domestica) );
    my @fruit = ( $apple, $orange );
    my $store = ProduceStore->new( fruit_aisle => \@fruit );
    print qq(First inventory...\n);
    $store->show_inventory;

    # replace existing inventory
    my $grape = Fruit->new( name => q(grape), species => q(V. vinifera) );
    my $tomato = Fruit->new( name => q(tomato), species => q(S. lycopersicum));
    $store->fruit_aisle( [ $grape, $tomato ] );
    print qq(Second inventory...\n);
    $store->show_inventory;

    # this clears the ArrayRef 
    $store->fruit_aisle( [ ] );
    print qq(Third inventory:\n);
    $store->show_inventory;

    exit 0;
