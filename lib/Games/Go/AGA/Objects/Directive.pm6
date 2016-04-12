#!/usr/bin/env perl6
################################################################################
# ABSTRACT:  Represents AGA directive (from a register.tde file)
#
#   AUTHOR:  Reid Augustin
#    EMAIL:  reid@hellosix.com
#  CREATED:  04/07/2016 12:40:28 PM
################################################################################
use v6;

class Games::Go::AGA::Objects::Directive {
    use Games::Go::AGA::Objects::Types;

    has Str-no-Space $.key is required;  # directive name
    has Str-no-Space @.values;           # one or more values
    has              &!change-callback = sub { };

    my %booleans = ( TEST => 1, AGA_RATED => 1 ); # class variable

    method set-change-callback (&ccb)       { &!change-callback = &ccb; self };
    method changed { &!change-callback(); self}

    ######################################
    #
    # methods to access/modify the class list of booleans
    #
    method booleans {
        keys %booleans;
    }

    method is-boolean (Str $key) {
        %booleans{$key.uc};
    }

    method add-boolean (Str $key) {
        %booleans{$key.uc} = 1;
        self;
    }

    method delete-boolean (Str $key) {
        %booleans{$key.uc}:delete;
        self;
    }

    ######################################
    #
    # set the directive values
    #
    method set-values (@values) {
        @!values = @values;
        $.changed;
        self;
    }
}
