#!/usr/bin/env perl

    package Fruit;
    use Moose;

    has q(name) => ( is => q(rw), required => 1 );
    has q(species) => ( is => q(rw), required => 1 );

    package ProduceStore;
    use Moose;
    use Moose::Util::TypeConstraints;

    has q(fruit_aisle) => ( is => q(rw), isa => q(ArrayRef[Fruit]) );

    package main;
    use Moose; # gains 'blessed' function

    # we need something to put in the fruit aisle
    my $orange = Fruit->new( name => q(orange), species => q(C. sinensis) );
    my $apple = Fruit->new( name => q(apple), species => q(M. domestica) );
    my @fruits = ( $apple, $orange );
    my $store = ProduceStore->new( fruit_aisle => \@fruits );

    my $inventory = $store->fruit_aisle;
    foreach my $item ( @{$inventory} ) {
        print qq(Item: ) . blessed $item . q(; name: ) . $item->name
            . q(; species: ) . $item->species . qq(\n);
    }

    exit 0;
