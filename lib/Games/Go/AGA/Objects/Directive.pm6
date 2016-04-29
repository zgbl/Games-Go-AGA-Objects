#!/usr/bin/env perl6
################################################################################
# ABSTRACT:  Represents AGA directive (from a register.tde file)
#
#   AUTHOR:  Reid Augustin
#    EMAIL:  reid@hellosix.com
#  CREATED:  04/07/2016 12:40:28 PM
################################################################################
use v6;

#| Abstracts a single directive line from AGA register.tde file.
class Games::Go::AGA::Objects::Directive {
    use Games::Go::AGA::Objects::Types;

    has Str-no-Space $.key is required; # directive name
    has Str          $.value = '';      # the value string, if any
    has Str          $.comment = '';    # optional comment
    has              &!change-callback;

    my %booleans = (    #= class variable: which keys are boolean
        Test => 1,
        Aga_rated => 1
    );
    my %lists   = (     #= class variable: which keys contain a list of items
        Date => 1,
        Online_registration => 1,
    );

    submethod BUILD (Str $str-key, Str $str-value?, Str $str-comment?,
                        :$key, :$value, :$comment, :&change-callback ) {

        $str-key.match(/^ \s* (\w+) \s+ (<-[#]>*) \s* (.*)/);
        with $0 { $!key = $0 } else { die 'No key' }
        with $1 { $!value = $1 }
        with $2 { $!comment = $2 }
        #&!change-callback = method { }  # must install callback after build with positionals
        with $key {$!key = $key}
        with $value {$!value = $value}
        with $comment {$!comment = $comment}
        with &change-callback {&!change-callback = &change-callback}
        else {&!change-callback = method { }}
    }

    method     change-callback        { &!change-callback              };
    method set-change-callback (&ccb) { &!change-callback = &ccb; self };
    method changed {
        self.&!change-callback();
        self; }

    ######################################
    #
    # methods to access/modify the class list of booleans
    #
    method booleans { %booleans.keys.sort; }
    method add-boolean (Str $key) {
        %booleans{$key.tclc} = 1;
        self;
    }
    method delete-boolean (Str $key) {
        %booleans{$key.tclc}:delete;
        self;
    }
    # is this (or some other) Directive boolean?
    method is-boolean (Str $key = $!key) { %booleans{$key.tclc}; }

    ######################################
    #
    # methods to access/modify the class list of lists
    #
    method lists { %lists.keys.sort; }
    method add-list (Str $key) {
        %lists{$key.tclc} = 1;
        self;
    }
    method delete-list (Str $key) {
        %lists{$key.tclc}:delete;
        self;
    }
    # is this (or some other) Directive a list?
    method is-list (Str $key = $!key) { %lists{$key.tclc}; }

    ######################################
    #
    # set/get the directive value
    #
    method set-value (Str $value) {
        $!value = $value;
        $.changed;
    }
    method value {
        $!value.subst(/\n.*/, '').trim;
    }

    ######################################
    #
    # set/get the comment
    #
    method set-comment (Str $comment) {
        $!comment = $comment;
        $.changed;
    }
    method comment {
        given $!comment.subst(/\n.*/, '').trim-trailing {
            when ''             { $_ };
            when m/ ^ \h* '#' / { $_ };
            default             { "# $_" };
        }
    }

    ######################################
    #
    # other methods
    #

    method sprint {
        my $sprint = "## $!key";
        $sprint ~= " $.value" if $!value ne '';
        $sprint ~= " $.comment" if $.comment ne '';
        $sprint;
    }
}
