#!/usr/bin/env perl6
################################################################################
# ABSTRACT:  Represents an AGA tournament Round
#
#   AUTHOR:  Reid Augustin
#    EMAIL:  reid@hellosix.com
#  CREATED:  Sat Apr  9 13:17:35 PDT 2016
################################################################################
use v6;
use Games::Go::AGA::Objects::Types;
use Games::Go::AGA::Objects::Game;
use Games::Go::AGA::Objects::ID_Normalizer_Role;


class Games::Go::AGA::Objects::Round
    does Games::Go::AGA::Objects::ID_Normalizer_Role {

=begin pod
=head1 SYNOPSIS

    use Games::Go::AGA::Objects::Register;

    my Games::Go::AGA::Objects::Register $register .= new( [ ... ] );

=header1 DESCRIPTION

Games::Go::AGA::Objects::Game represents a single game.

=head1 ATTRIBUTES

Attributes may be retrieved with the name of the attribute (e.g:
$directive.key). Settable attributes are set with the name prefixed by
'set-' (e.g: $game.set-white-id( ... )).

=item round-number => Pos-Int [ required ]
=item games => Games::Go::AGA::Objects::Game   # list of games
=item next-table-number => Int  = 1
=item change-callback => sub { }

Callback called from the B<changed> method.  You might want to set
this after populating the Round.

=end pod

    has                       Pos-Int $.round-number is required;
    has Games::Go::AGA::Objects::Game @.games;  # games
    has                           Int $.next-table-number = 1;
    has                               &.change-callback = sub { };

    ######################################
    #
    # accessors
    #
    method set-change-callback ($ccb) { &!change-callback = $ccb; self } #=
    #| Called to indicate a change (called from
    #| B<add-game>
    #| and B<delete-game>.
    #| Calls B<change-callback>.
    method changed { &!change-callback(); self; } #=

    ######################################
    #
    # methods
    #
    #| Returns the current Btable-number> and increments it.
    method next-table-number { $!next-table-number++; }

    method add-game (Games::Go::AGA::Objects::Game $game) { #=
        my &prev-callback = $game.change-callback;
        my $round = self;
        $game.set-change-callback(
            sub {
                &prev-callback();   # call game's previous callback
                $round.changed;     # call our own changed callback
            }
        );
        @!games.push($game);
        $.changed;
        self;
    }

    multi method game (Int $idx) { @!games[$idx] } #=
    multi method game (AGA-Id $id0, AGA-Id $id1 = $id0) { #=
        given $.idx-of-game($id0, $id1) {
            when .defined { @!games[$_] }
        }
    }

    multi method delete-game (Int $idx) { @!games.delete($idx) } #=
    multi method delete-game (AGA-Id $id0, AGA-Id $id1 = $id0) { #=
        my $idx = $.idx-of-game($id0, $id1);
        return without $idx;
        my $game = @!games.delete($idx);
        $.changed;
        self;
    }

    method idx-of-game (AGA-Id $id0 is copy, AGA-Id $id1 is copy = $id0) { #=
        $id0 = $.normalize-id($id0);
        $id1 = $.normalize-id($id1);
        for @!games.kv -> $idx, $game {
            if ( ($game.white-id eq $id0 or $game.black-id eq $id0) and
                 ($game.white-id eq $id1 or $game.black-id eq $id1) ) {
                return $idx;
            }
        }
        return; # undef
    }

    #| Returns the Round information printed into a string, suitable for
    #| writing to a round file (1.tde, 2.tde, etc).
    method sprint {
        (
            "# Round $!round-number",
            |@!games>>.sprint,
        ).join("\n");
    }
}

# vim: expandtab shiftwidth=4 ft=perl6
