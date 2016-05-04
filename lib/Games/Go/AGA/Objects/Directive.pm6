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

    has Str-no-Space  $.key is required; # directive name
    has Directive-Val $.value = '';      # the value string, if any
    has Str           $.comment = '';    # optional comment
    has               &.change-callback = sub { };
 
    my %booleans = (    #= class variable: which keys are boolean
        Test => 1,
        Aga_rated => 1
    );
    my %lists   = (     #= class variable: which keys contain a list of items
        Date => 1,
        Online_registration => 1,
    );

    method set-change-callback (&ccb) { &!change-callback = &ccb; self };
    method changed {
        &!change-callback();
        self; }

    ######################################
    #
    # methods to access/modify the class list of booleans
    #
    method booleans { %booleans.keys.sort; }
    method add-boolean (Str $key) {
        %booleans{$key.tclc} = True;
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
        %lists{$key.tclc} = True;
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
    method set-value (Directive-Val $value) {
        $!value = $value;
        $.changed;
    }

    ######################################
    #
    # set/get the comment
    #
    method set-comment (Str $comment) {
        $!comment = $comment // '';
        $.changed;
    }
    method comment {
        $!comment.subst-mutate(/\n .*/, '');    # truncate at first newline
        if     not $!comment eq ''
           and not $!comment.match(/^ \h* '#'/) {
            $!comment = "# $!comment";
        }
        $!comment;
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

# vim: expandtab shiftwidth=4 ft=perl6
