#!/usr/bin/env perl6
################################################################################
# ABSTRACT:  Represents AGA directive (from a register.tde file)
#
#   AUTHOR:  Reid Augustin
#    EMAIL:  reid@hellosix.com
#  CREATED:  04/07/2016 12:40:28 PM
################################################################################
use v6;

=begin pod
Abstracts a single directive line from an AGA register.tde file.
Directives generically look like:

    ## Key Value

Boolean Directives are indicated by their presence, a Value is not
necessary:

    ## AGA_Rated

List Directives can contain several Values separated by white-space, such
as when Drop contains several IDs:

    ## Drop3 USA123 USA456 TMP2

=end pod

class Games::Go::AGA::Objects::Directive {
    use Games::Go::AGA::Objects::Types;

    #| key => Directive name, like Tourney or DATE.
    has Str-no-Space  $.key is required; # directive name
    #| value => Directive value.  For Booleans, presence is sufficient.
    has Directive-Val $.value = '';      # the value string, if any
    #| comment => Optional comment.
    has Str           $.comment = '';    # optional comment
    #| change-callback => Callback called whenever B<set-value> or B<set-comment> are called.
    has               &.change-callback = sub { };
 
    my %booleans = (    # class variable: which keys are boolean
        Test => 1,
        Aga_rated => 1
    );
    my %lists   = (     # class variable: which keys contain a list of items
        Date => 1,
        Online_registration => 1,
    );

    #| Set a new B<change-callback>.
    method set-change-callback (&ccb) { &!change-callback = &ccb; self };
    #| Called to indicate a change.  Calls B<change-callback>.
    method changed {
        &!change-callback();
        self; }

    ######################################
    #
    # methods to access/modify the class list of booleans
    #
    #| Returns a (class) list of B<keys> which are considered Boolean.
    method booleans { %booleans.keys.sort; }
    #| Add a new key to the (class) list of Booleans.
    method add-boolean (Str $key) {
        %booleans{$key.tclc} = True;
        self;
    }
    #| Delete a key from the (class) list of Booleans.
    method delete-boolean (Str $key) {
        %booleans{$key.tclc}:delete;
        self;
    }
    #| Returns boolean indicating if $key (or $!key) is Boolean.
    method is-boolean (Str $key = $!key) { %booleans{$key.tclc}:exists; }

    ######################################
    #
    # methods to access/modify the class list of lists
    #
    #| Returns a (class) list of B<keys> which are considered Lists.
    method lists { %lists.keys.sort; }
    #| Add a new key to the (class) list of Lists.
    method add-list (Str $key) {
        %lists{$key.tclc} = True;
        self;
    }
    #| Delete a key from the (class) list of Lists.
    method delete-list (Str $key) {
        %lists{$key.tclc}:delete;
        self;
    }
    #| Returns boolean indicating if $key (or $!key) is a List.
    method is-list (Str $key = $!key) { %lists{$key.tclc}; }

    ######################################
    #
    # set the directive value
    #
    #| Set a new B<$value>.
    method set-value (Directive-Val $value) {
        $!value = $value;
        $.changed;
    }

    ######################################
    #
    # set/get the comment
    #
    #| Set a new B<$comment>.
    method set-comment (Str $comment) {
        $!comment = $comment // '';
        $.changed;
    }
    #| Get the B<$!comment>.  Ensures that it is a single line with leading '#'
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

    #| Returns a string suitable for printing to the register.tde file.
    method sprint {
        my $sprint = "## $!key";
        $sprint ~= " $.value" if $!value ne '';
        $sprint ~= " $.comment" if $.comment ne '';
        $sprint;
    }
}

# vim: expandtab shiftwidth=4 ft=perl6
