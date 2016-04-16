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
    has Str          $.value = '';      # the value string, if any
    has Str          $.comment = '';    # optional comment
    has              &.change-callback = method { };

    my %booleans = (    # class variable: which keys are boolean
        Test => 1,
        Aga_rated => 1
    );
    my %lists   = (     # class variable: which keys contain a list of items
        Date => 1,
        Online_registration => 1,
    );

    method set-change-callback (&ccb) { &!change-callback = &ccb; self };
    method changed { self.&!change-callback(); self; }

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
        my $comment = $!comment.subst(/\n.*/, '').trim;
        $comment = "# $comment" if $comment ne '' and not $comment ~~ / ^ \h* '#'/;
        $comment;
    }

    ######################################
    #
    # other methods
    #

    method gist {
        my $gist = "## $!key";
        $gist ~= " $.value" if $!value ne '';
        $gist ~= " $.comment" if $.comment ne '';
        $gist;
    }
}
