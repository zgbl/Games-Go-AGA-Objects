#!/usr/bin/env perl6
################################################################################
# ABSTRACT:  Represents an AGA Game
#
#   AUTHOR:  Reid Augustin
#    EMAIL:  reid@hellosix.com
#  CREATED:  04/07/2016 12:40:28 PM
################################################################################
use v6;
use Games::Go::AGA::Objects::Types;
use Games::Go::AGA::Objects::ID_Normalizer_Role;

class Games::Go::AGA::Objects::Game
    does Games::Go::AGA::Objects::ID_Normalizer_Role {

=begin pod
=head1 SYNOPSIS

    use Games::Go::AGA::Objects::Game;

    my Games::Go::AGA::Objects::Game $game .= new( :key<Rules>, :value<Ing>);

=header1 DESCRIPTION

Games::Go::AGA::Objects::Game represents a single game.

=head1 ATTRIBUTES

Attributes may be retrieved with the name of the attribute (e.g:
$directive.key). Settable attributes are set with the name prefixed by
'set-' (e.g: $game.set-white-id( ... )).

=item white-id => AGA-Id  [ required ] # ID of white player
=item black-id => AGA-Id  [ required ] # ID of black player

Note that IDs are 'normalized' (see
L<Games::Go::AGA::Objects::ID_Normalizer_Role>).  IDs consist of at least
one letter followed by at least one number.  Normalization forces all
letters to upper case, and removes any preceding zeros from the numeric
part.

=item table-number => Non-Neg-Int  = 0;
=item handicap => Non-Neg-Int  = 0;
=item komi => Rat          = 7.5;
=item result => Result       = '?';         # 'w', 'b', or '?'
=item white-adj-rating => Rating           # adjusted rating as a result of this game
=item black-adj-rating => Rating
=item comment => Str          = '';         # optional game comment
=item change-callback => sub { };

Callback called from the B<changed> method.

=end pod

    has AGA-Id      $.white-id is required; # ID of white player
    has AGA-Id      $.black-id is required; # ID of black player
    has AGA-Id      $!normalized-white-id;
    has AGA-Id      $!normalized-black-id;
    has Non-Neg-Int $.table-number = 0;
    has Non-Neg-Int $.handicap = 0;
    has Rat         $.komi = 7.5;
    has Result      $.result = '?';         # 'w', 'b', or '?'
    has Rating      $.white-adj-rating;     # adjusted rating as a result of this game
    has Rating      $.black-adj-rating;
    has Str         $.comment = '';         # optional game comment
    has             &.change-callback = sub { };

=begin pod
=head1 METHODS

Methods that don't explicitly return a value return B<self> to enable
chaining.
=end pod

    ######################################
    #
    # accessors
    #
    #|
    method white-id { # override accessor to normalize IDs
        $!normalized-white-id //= $.normalize-id($!white-id);
        $!normalized-white-id;
    }
    #| Returns the normalized id.
    method black-id { # override accessor to normalize IDs
        $!normalized-black-id = $.normalize-id($!black-id) without $!normalized-black-id;
        $!normalized-black-id;
    }
    #|
    method un-normalized-white-id { # in case you want your original ID back
        $!white-id;
    }
    #| Returns the original id.
    method un-normalized-black-id { # in case you want your original ID back
        $!black-id;
    }
    method set-white-id (AGA-Id $w)         { $!white-id         = $w; $.changed; }; #=
    method set-black-id (AGA-Id $b)         { $!black-id         = $b; $.changed; }; #=
    method set-table-number (Pos-Int $t)    { $!table-number     = $t; $.changed; }; #=
    method set-handicap (Non-Neg-Int $h)    { $!handicap         = $h; $.changed; }; #=
    method set-komi (Rat $k)                { $!komi             = $k; $.changed; }; #=
    method set-result (Result $r)           { $!result           = $r; $.changed; }; #=
    method set-white-adj-rating (Rating $w) { $!white-adj-rating = $w; $.changed; }; #=
    method set-black-adj-rating (Rating $b) { $!black-adj-rating = $b; $.changed; }; #=
    method set-change-callback (&ccb)       { &!change-callback  = &ccb; self;    }; #=
    method set-comment(Str $c)              { $!comment          = $c; $.changes; }; #=

    ######################################
    #
    # methods
    #
    #| Called to indicate a change (called from
    #| B<set-white-id>,
    #| B<set-black-id>,
    #| B<set-table-number>,
    #| B<set-handicap>,
    #| B<set-komi>,
    #| B<set-result>,
    #| B<set-white-adj-rating>,
    #| B<set-black-adj-rating>,
    #| and B<set-comment>).
    #| Calls B<change-callback>.
    method changed { &!change-callback(); self; }

    #| Returns the ID of the winner, if B<result> is 'w' or 'b'.
    method winner {
        given $!result {
            when 'w' {$.white-id};
            when 'b' {$.black-id};
        }
    }

    #| Returns the ID of the loser, if B<result> is 'w' or 'b'.
    method loser {
        given $!result {
            when 'b' {$.white-id};
            when 'w' {$.black-id};
        }
    }

    #| Returns the game information printed into a string, suitable for
    #| reporting in a Round result file (1.tde, 2.tde, etc).
    method sprint {
        my @comment;
        @comment.push($!comment) if $!comment.chars;

        if $!table-number {
            @comment.push("Tbl $!table-number");
        }

        with $!white-adj-rating or $!black-adj-rating {
            @comment.push("adjusted ratings:",
                ($!white-adj-rating || '?') ~ ',',
                $!black-adj-rating || '?',
            );
        }

        if @comment.elems > 0 and
           not @comment[0] ~~ m/^ \h* '#'/ {
            @comment.unshift('#');
        }

        (
            $.white-id,
            $.black-id,
            $!result,
            $!handicap,
            $!komi,
            |@comment,
        ).join(' ');
    }
}

=begin pod
=head1 SEE ALSO

=item L<Games::Go::AGA::Objects::Round>

=end pod

# vim: expandtab shiftwidth=4 ft=perl6
