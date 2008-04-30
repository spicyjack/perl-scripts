#!/usr/bin/perl

    # Perl 5 Object, as taught by the 'perltoot' POD page
    package Perl5::Demo;
    use strict;
    use warnings;

    sub new {
        my $class = shift;
        # assign the rest of the method arguments to a temp hash
        my %args = @_;

        # create the object out of a blessed hash reference
        my $self = bless ( {}, ref($class) || $class );
        # create the script_name attribute
        $self->{script_name} = undef;

        # verify that the user passed in the 'script_name' attribute
        if ( exists $args{script_name} ) {
            $self->script_name($args{script_name});
        } else {
            die q(ERROR: can't create object without 'script_name' );
        } # if ( exists $args{script_name} )

        # return the object reference back to the caller
        return $self;
    } # sub new

    sub script_name {
        my $self = shift;
        if (@_) { $self->{script_name} = shift }
        return $self->{script_name};
    } # sub script_name

    package main;
    use strict;
    use warnings;

    my $demo = Perl5::Demo->new( script_name => $0 );

    print qq(My name is ) . $demo->script_name . qq(\n);
    print qq(I am a ) . ref($demo) . qq( type of object\n);

    # this could also be $demo->script_name(q(I changed this!))
    $demo->{script_name} = "I changed this!";
    print qq(My name is now ) . $demo->script_name . qq(\n);

