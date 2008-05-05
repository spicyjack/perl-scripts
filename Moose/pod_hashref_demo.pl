#!/usr/bin/env perl

    package Fruit;
    use Moose;

    has q(species) => ( is => q(rw), required => 1 );

    package ProduceStoreHash;
    use Moose;
    use Moose::Util::TypeConstraints;
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
    print qq(First inventory:\n);
    $store->show_inventory;

    # this replaces the existing HashRef contents
    my $grape = Fruit->new( species => q(V. vinifera) );
    my $tomato = Fruit->new( species => q(S. lycopersicum));
    $store->fruit_aisle( { grape => $grape, tomato => $tomato } );
	print qq(Second inventory:\n);
    $store->show_inventory;

    # this clears the HashRef
    $store->fruit_aisle( { } );
	print qq(Third inventory:\n);
    $store->show_inventory;

    exit 0;
