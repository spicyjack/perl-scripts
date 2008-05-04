#!/usr/bin/env perl

    package Fruit;
    use Moose;

    has q(species) => ( is => q(rw), required => 1 );

    package ProduceStoreHash;
    use Moose;
    use Moose::Util::TypeConstraints;
    has q(fruit_aisle) => ( is => q(rw), isa => q(HashRef) );

    sub show_inventory {
        my $self = shift;
		# de-reference the HashRef stored in $self->fruit_aisle
		# and enumerate over it's keys
        foreach my $item ( keys(%{$self->fruit_aisle}) ) {
			# note that the HashRef contains another hash
			# hence the $object->{hash1}{hash2} syntax below
            my $fruit = $self->{fruit_aisle}{$item};
            print qq(Item: $item, type: ) . blessed($fruit) 
            . qq(\n);#    . q( species: ) . $fruit->species . qq(\n);
        } # foreach my $key    } # sub show_inventory
    } # sub show_inventory

    package main;
    use Moose;

    # we need something to put in the fruit aisle
    my $orange = Fruit->new( species => q(C. sinensis) );
    my $apple = Fruit->new( species => q(M. domestica) );
    my $store = ProduceStoreHash->
        new( fruit_aisle => { apple => $apple, orange => $orange } );
    print qq(First inventory:\n);
    $store->show_inventory;

    # this replaces the existing HashRef contents
    my $grape = Fruit->new( species => q(V. vinifera) );
    my $tomato = Fruit->new( species => q(S. lycopersicum));
    my %new_fruit = ( grape => $grape, tomato => $tomato );
    $store->fruit_aisle( \%new_fruit );
	print qq(Second inventory:\n);
    $store->show_inventory;

    # this clears the HashRef
    $store->fruit_aisle( { } );
	print qq(Third inventory:\n);
    $store->show_inventory;

    exit 0;
