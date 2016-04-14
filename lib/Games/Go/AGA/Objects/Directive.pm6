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
    has Str-no-Space @.values;          # zero or more values
    has Str          $.comment;         # optional comment
    has              &.change-callback = method { };

    my %booleans = ( Test => 1, Aga_rated => 1 ); # class variable
    my %arrays   = (                    # values are an array of items
        Date => 1,
        Online_registration => 1,
    );

    method set-change-callback (&ccb)       { &!change-callback = &ccb; self };
    method changed {
        self.&!change-callback();
        self;
    }

    ######################################
    #
    # methods to access/modify the class list of booleans
    #
    method booleans {
        %booleans.keys.sort;
    }

    method is-boolean (Str $key = $!key) {
        %booleans{$key.tclc};
    }

    method add-boolean (Str $key) {
        %booleans{$key.tclc} = 1;
        self;
    }

    method delete-boolean (Str $key) {
        %booleans{$key.tclc}:delete;
        self;
    }

    ######################################
    #
    # methods to access/modify the class list of arrays
    #
    method arrays {
        %arrays.keys.sort;
    }

    method is-array (Str $key = $!key) {
        %arrays{$key.tclc};
    }

    method add-array (Str $key) {
        %arrays{$key.tclc} = 1;
        self;
    }

    method delete-array (Str $key) {
        %arrays{$key.tclc}:delete;
        self;
    }

    ######################################
    #
    # set/get the directive values
    #
    multi method set-values (Str $values) {
        @!values = $values;
        $.changed;
    }
    multi method set-values (Str @values) {
        @!values = @values;
        $.changed;
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
    }

    ######################################
    #
    # other methods
    #

    method gist {
        my $gist = "## $!key ";
        $gist ~= @!values.join(' ') if @.values;
        $gist ~= $!comment if $.comment;
    }
}
