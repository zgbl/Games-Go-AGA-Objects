#!/usr/bin/env perl6
use v6;
################################################################################
# ABSTRACT:  Represents AGA directive (from a register.tde file)
#
#   AUTHOR:  Reid Augustin
#    EMAIL:  reid@hellosix.com
#  CREATED:  04/07/2016 12:40:28 PM
################################################################################

class Games::Go::AGA::Objects::Directive {
    has $.key is required;  # directive name
    has @.values;           # one or more values

    my @booleans = qw[ TEST AGA_RATED ]; # class variable

    ######################################
    #
    # methods to modify the class list of booleans
    #
    method add_boolean (Str $key) {
        $key = $key.uc;     # booleans are all upper-case
        .delete_boolean($key);  # prevent duplicates
        push @booleans, $key;
    }

    method delete_boolean (Str $key) {
        $key = $key.uc;     # booleans are all upper-case
        my @new_booleans;
        @booleans.map{ @new_booleans.push if (* ne $key) };
        @booleans = @new_booleans;
    }

    ######################################
    #
    # set the directive values
    #
    method set_values (@values) {
        @!values = @values;
    }
}
