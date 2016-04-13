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

    has Str-no-Space $!key is required; # directive name
    has Str-no-Space @!values;          # zero or more values
    has Str          $!comment;         # optional comment
    has              &!change-callback = method { };

    my %booleans = ( TEST => 1, AGA_RATED => 1 ); # class variable
    my %arrays   = (                    # values are an array of items
        DATE => 1,
        ONLINE_REGISTRATION => 1,
    );

    method set-change-callback (&ccb)       { &!change-callback = &ccb; self };
    method changed {
        &!change-callback() if &!change-callback;
        self;
    }

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

    method is-array (Str $key = $!key) {
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
    # set/get the directive values
    #
    method set-values (@values) {
        @!values = @values;
        $.changed;
        self;
    }
    method get-values {
        if $.is-array() and @!values.elem == 1 {
            return @!values[0].split(rx{<[\s,;]>+})
        }
        @!values;
    }

    ######################################
    #
    # set the comment
    #
    method set-comment (Str $comment) {
        $!comment = $comment;
        $.changed;
        self;
    }

    ######################################
    #
    # other methods
    #

    method gist {
        "## $!key " ~ @!values.join(' ') ~ $!comment;
    }
}
