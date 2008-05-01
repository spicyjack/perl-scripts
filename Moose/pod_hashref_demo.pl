#!/usr/bin/env perl

    package HashDemo;
    use Moose;
    use Moose::Util::TypeConstraints;

    # this attribute is a HashRef
    has 'files' => ( is => 'rw', isa => q(HashRef) );

    sub dump {
        my $self = shift; 
		# de-reference the HashRef stored in $self->files
		# and enumerate over it's keys
        foreach my $key ( keys(%{$self->files}) ) {
			# note that the HashRef contains another hash
			# hence the $object->{hash1}{hash2} syntax below
            print qq(this hash key/value pair is $key : )
                . $self->{files}{$key} . qq(\n);
        } # foreach my $key
    } # sub dump
	
    package main;
    use Moose;

    my $demo = HashDemo->new( files => { 1 => q(/path/to/some/file) } );
	print qq(First dump:\n);
    $demo->dump;
    # prints "My hash is 1:/path/to/some/file"

    # this replaces the existing HashRef contents
    my %second_hash = ( 2 => q(/path/to/file2), 3 => q(/path/to/file3) );
    $demo->files( \%second_hash );
	print qq(Second dump:\n);
    $demo->dump;

    # this clears the HashRef
    $demo->files( { } );
	print qq(Third dump:\n);
    $demo->dump;

    exit 0;

