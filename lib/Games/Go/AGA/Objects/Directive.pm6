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
    subset str-no-space of Str where { m/^\S+$/ };
    has str-no-space $.key is required;  # directive name
    has str-no-space @.values;           # one or more values

    my @booleans = qw[ TEST AGA_RATED ]; # class variable

    ######################################
    #
    # methods to modify the class list of booleans
    #
    method booleans {
        @booleans;
    }

    method add_boolean (Str $k) {
        my $key = $k.uc;     # booleans are all upper-case
        $.delete_boolean($key);  # prevent duplicates
        push @booleans, $key;
    }

    method delete_boolean (Str $k) {
        my $key = $k.uc;     # booleans are all upper-case
        my @new_booleans;
        @booleans.map( { @new_booleans.push($_) if (not $_ ~~ $key); } );
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
