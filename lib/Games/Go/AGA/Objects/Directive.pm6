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

    my @booleans = qw[ TEST AGA_RATED ]; # class variable

    ######################################
    #
    # methods to modify the class list of booleans
    #
    method booleans {
        @booleans;
    }

    method add-boolean (Str $k) {
        my $key = $k.uc;     # booleans are all upper-case
        $.delete-boolean($key);  # prevent duplicates
        push @booleans, $key;
    }

    method delete-boolean (Str $k) {
        my $key = $k.uc;     # booleans are all upper-case
        my @new-booleans;
        @booleans.map( { @new-booleans.push($_) if (not $_ ~~ $key); } );
        @booleans = @new-booleans;
    }

    ######################################
    #
    # set the directive values
    #
    method set-values (@values) {
        @!values = @values;
    }
}
