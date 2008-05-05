#!/usr/bin/env perl

    package Fruit;
    use Moose;

    has q(name) => ( is => q(rw), required => 1 );
    has q(species) => ( is => q(rw), required => 1 );

    package ProduceStoreArray;
    use Moose;
    use Moose::Util::TypeConstraints;

    has q(fruit_aisle) => ( is => q(rw), isa => q(ArrayRef[Fruit]) );
    #has q(fruit_aisle) => ( is => q(rw), isa => q(ArrayRef[Str]) );

    sub show_inventory { 
        my $self = shift;
        foreach my $item ( @{$self->fruit_aisle} ) {
            print qq(Item: ) . blessed($item) . q(; name: ) . $item->name
                . q(; species: ) . $item->species . qq(\n);
        } # foreach my $item ( @{$inventory} )
    } # sub show_inventory

    package main;

    # we need something to put in the fruit aisle
    my $orange = Fruit->new( name => q(orange), species => q(C. sinensis) );
    my $apple = Fruit->new( name => q(apple), species => q(M. domestica) );
    my @fruit = ( $apple, $orange );
    my $store = ProduceStoreArray->new( fruit_aisle => \@fruit );
    print qq(\nFirst inventory (initial object creation):\n);
    $store->show_inventory;

    # replace existing inventory
    my $grape = Fruit->new( name => q(grape), species => q(V. vinifera) );
    my $tomato = Fruit->new( name => q(tomato), species => q(S. lycopersicum));
    $store->fruit_aisle( [ $grape, $tomato ] );
    print qq(\nSecond inventory (replacing the ArrayRef):\n);
    $store->show_inventory;

    # append to inventory
    my @fruit_aisle_copy = @{$store->fruit_aisle};
    my $avocado = Fruit->new( name => q(avocado), species => q(P. americana) );
    push(@fruit_aisle_copy, $avocado);
    $store->fruit_aisle( \@fruit_aisle_copy );
    print qq(\nThird inventory (appending to the ArrayRef):\n);
    $store->show_inventory;

    # delete from inventory
    @fruit_aisle_copy = @{$store->fruit_aisle};
    my @reworked_fruit_aisle;
    for my $fruit_obj ( @fruit_aisle_copy ) {
        if ( $fruit_obj->name ne q(tomato) ) {
            push(@reworked_fruit_aisle, $fruit_obj);
        } # if ( $fruit_obj->name ne q(tomato) )
    } # for my $fruit_obj ( @fruit_aisle_copy )
    $store->fruit_aisle( \@reworked_fruit_aisle );
    print qq(\nFourth inventory (deleting from the ArrayRef):\n);
    $store->show_inventory;

    # this clears the ArrayRef 
    $store->fruit_aisle( [ ] );
    print qq(\nFifth inventory (clearing the ArrayRef):\n);
    $store->show_inventory;

    exit 0;
