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

    has Str-no-Space $.key is required; # directive name
    has Str-no-Space @.values;          # one or more values
    has              &!change-callback = sub { };

    my %booleans = ( TEST => 1, AGA_RATED => 1 ); # class variable
    my %arrays   = (                    # values are an array of items
        DATE => 1,
        ONLINE_REGISTRATION => 1,
    );

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
    # methods to access/modify the class list of arrays
    #
    method arrays {
        keys %arrays;
    }

    method is-array (Str $key) {
        %arrays{$key.uc};
    }

    method add-array (Str $key) {
        %arrays{$key.uc} = 1;
        self;
    }

    method delete-array (Str $key) {
        %arrays{$key.uc}:delete;
        self;
    }

    ######################################
    #
    # set the directive values
    #
    multi method set-values (@values) {
        @!values = @values;
        $.changed;
        self;
    }
    multi method set-values (Str $values) {
        if $.is_array($,key) {
            @!values = $values.split(rx{<[\s,;]>);
        }
        else {
            @!values = $values;
        }
        $.changed;
        self;
    }
}
