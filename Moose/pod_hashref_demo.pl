#!/usr/bin/env perl

    package Fruit;
    use Moose;

    has q(species) => ( is => q(rw), required => 1 );

    package ProduceStoreHash;
    use Moose;
    use Moose::Util::TypeConstraints;

    #has q(fruit_aisle) => ( is => q(rw), isa => q(HashRef[Int]) );
    has q(fruit_aisle) => ( is => q(rw), isa => q(HashRef[Fruit]) );

    sub show_inventory {
        my $self = shift;
        my %fruit_aisle_copy = %{$self->fruit_aisle};
        foreach my $item ( keys(%fruit_aisle_copy) ) {
            my $fruit = $fruit_aisle_copy{$item};
            print qq(Item: $item, type: ) . blessed($fruit) 
                . q( species: ) . $fruit->species . qq(\n);
        } # foreach my $item ( keys(%fruit_aisle_copy) )
		# de-reference the HashRef stored in $self->fruit_aisle
		# and enumerate over it's keys
#        foreach my $item ( keys(%{$self->fruit_aisle}) ) {
			# note that the HashRef contains another hash
			# hence the $object->{hash1}{hash2} syntax below
#            my $fruit = $self->{fruit_aisle}{$item};
#            print qq(Item: $item, type: ) . blessed($fruit) 
#                . q( species: ) . $fruit->species . qq(\n);
#        } # foreach my $key
    } # sub show_inventory

    package main;
    use Moose;

    # we need something to put in the fruit aisle
    my $orange = Fruit->new( species => q(C. sinensis) );
    my $apple = Fruit->new( species => q(M. domestica) );
    my %fruit = ( orange => $orange, apple => $apple );
    my $store = ProduceStoreHash->new( fruit_aisle => \%fruit );
    print qq(\nFirst inventory (initial object creation):\n);
    $store->show_inventory;

    # this replaces the existing HashRef contents
    my $grape = Fruit->new( species => q(V. vinifera) );
    my $tomato = Fruit->new( species => q(S. lycopersicum));
    $store->fruit_aisle( { grape => $grape, tomato => $tomato } );
	print qq(\nSecond inventory (replacing the HashRef):\n);
    $store->show_inventory;

    # append a new attribute to the HashRef
    my %fruit_aisle_copy = %{$store->fruit_aisle};
    my $avocado = Fruit->new( species => q(P. americana) );
    $fruit_aisle_copy{avocado} = $avocado;
    $store->fruit_aisle( \%fruit_aisle_copy );
	print qq(\nThird inventory (appending a new key/value pair):\n);
    $store->show_inventory;

    # delete an attribute from the HashRef
    %fruit_aisle_copy = %{$store->fruit_aisle};
    delete($fruit_aisle_copy{tomato});
    $store->fruit_aisle( \%fruit_aisle_copy );
	print qq(\nFourth inventory (deleting a key/value pair):\n);
    $store->show_inventory;

    # this clears the HashRef
    $store->fruit_aisle( { } );
	print qq(\nFifth inventory (clearing the HashRef):\n);
    $store->show_inventory;

    exit 0;
