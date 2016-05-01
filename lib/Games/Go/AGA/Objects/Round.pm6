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

    has                       Pos-Int $.round-number is required;
    has Games::Go::AGA::Objects::Game @.games;  # games
    has                           Int $.next-table-number = 1;
    has                               &.change-callback = sub { };

    ######################################
    #
    # accessors
    #
    method set-change-callback ($ccb) { &!change-callback = $ccb; self };

    ######################################
    #
    # methods
    #
    method get-next-table-number { $!next-table-number++; }
    method changed { &!change-callback(); self; }

    method add-game (Games::Go::AGA::Objects::Game $game) {
        @!games.push($game);
        $.changed;
        self;
    }

    multi method game (Int $idx) { @!games[$idx] }
    multi method game (AGA-Id $id0, AGA-Id $id1 = $id0) {
        given $.idx-of-game($id0, $id1) {
            when .defined { @!games[$_] }
        }
    }

    multi method delete-game (Int $idx) { @!games.delete($idx) }
    multi method delete-game (AGA-Id $id0, AGA-Id $id1 = $id0) {
        my $idx = $.idx-of-game($id0, $id1);
        return without $idx;
        my $game = @!games.delete($idx);
        $.changed;
        self;
    }

    method idx-of-game (AGA-Id $id0 is copy, AGA-Id $id1 is copy = $id0) {
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

    method sprint {
        (
            "# Round $!round-number",
            |@!games>>.sprint,
        ).join("\n");
    }
}

# vim: expandtab shiftwidth=4 ft=perl6
