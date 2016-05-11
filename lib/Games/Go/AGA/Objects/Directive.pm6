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

=begin pod

=head1 SYNOPSIS

    use Games::Go::AGA::Objects::Directive;

    my Games::Go::AGA::Objects::Directive $directive .= new( :key<Rules>, :value<Ing> );

=head1 DESCRIPTION

Games::Go::AGA::Objects::Directive abstracts a single directive line from
an AGA register.tde file.  Directives generically look like:

    ## Key Value

Boolean Directives are indicated by their presence, a Value is not
necessary:

    ## AGA_Rated

List Directives can contain several values separated by white-space, such
as when Drop contains several IDs:

    ## Drop3 USA123 USA456 TMP2

List directives split the B<value> string on whitespace and return an array.

=head1 ATTRIBUTES

Attributes may be retrieved with the name of the attribute (e.g:
$directive.key). Settable attributes are set with the name prefixed by
'set-' (e.g: $directive.set-value( ... )).

=item key => Str [required]

The name of the directive, such as 'Tourney' or 'DATE'.

=item value => Str

The directive's value, if any.  B<Boolean> directives don't require a value.
B<List> directive values are split on whitespace.

=item comment => Str

Optional comment attached to this directive.  Comments start with '#' in
file text.  If B<comment> does not start with '#' (possibly after initial
whitespace), one is prepended.

=item change-callback => &sub

Callback called from the B<changed> method.

=end pod

    has Str-no-Space  $.key is required; # directive name
    has Directive-Val $.value = '';
    has Str           $.comment = '';    # optional comment
    has               &.change-callback = sub { };
 
    my %booleans = (    # class variable: which keys are boolean
        Test => 1,
        Aga_rated => 1
    );
    my %lists   = (     # class variable: which keys contain a list of items
        Date => 1,
        Online_registration => 1,
    );

=begin pod
=head1 METHODS

Methods that don't explicitly return a value return B<self> to enable
chaining.
=end pod

    #| Set a new B<change-callback>.
    method set-change-callback (&change-callback) { &!change-callback = &change-callback; self };
    #| Called to indicate a change (called from B<set-value> and
    #| B<set-comment>).  Calls B<change-callback>.
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
    #| Returns boolean indicating if $key (or this directive) is Boolean.
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
    #| Returns boolean indicating if $key (or this directive) is a List.
    method is-list (Str $key = $!key) { %lists{$key.tclc}:exists; }

    ######################################
    #
    # set the directive value
    #
    #| Set a new B<$value>.
    method set-value (Directive-Val $value) {
        $!value = $value;
        $.changed;
    }
    #| Get the B<$value>.  Sets 'but True' on B<Boolean>s so: C<if
    #| $key.value> works even if no value has been set.  Returns an array
    #| (split on whitespace) for B<List>s.
    method value {
        given $!value {
            when $.is-boolean { $_ but True }
            when $.is-list    { $_.split(/\h+/) }
            default { $_ };
        }
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

=begin pod
=head1 SEE ALSO

=item L<Games::Go::AGA::Objects::Register>
=end pod

# vim: expandtab shiftwidth=4 ft=perl6
