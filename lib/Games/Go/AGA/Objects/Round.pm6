#!/usr/bin/env perl6
################################################################################
# ABSTRACT:  Represents an AGA tournament Round
#
#   AUTHOR:  Reid Augustin
#    EMAIL:  reid@hellosix.com
#  CREATED:  Sat Apr  9 13:17:35 PDT 2016
################################################################################
use v6;

class Games::Go::AGA::Objects::Round {
    use Games::Go::AGA::Objects::Types;
    use Games::Go::AGA::Objects::Game;

    has Pos-Int $.round_number is required;
    has Game    @.games;  # games
    has Pos-Int $.next_table_number = 0;
    has Code   $change-callback = { };

    ######################################
    #
    # accessors
    #
    method get-round-number { $.round-number };
    method set-change-callback (Code $ccb) { $.change-callback =-$ccb };

    ######################################
    #
    # methods
    #
    method changed { $.($.change-callback)(); }

    method get-next-table-number { ++$.next-table-number; }

    method add-game (Int $idx, Game $game) {
        @.games.push($game);
        $.changed;
    }
    multi method get-game (Int $idx) { @.games[$idx] }
    multi method get-game (AGA-Id $id-0, AGA-Id $id-1) {
        my $idx = $.idx-of-game($id-0, $id-1);
        return if not $idx;
        @.games[$idx];
    }
    multi method delete-game (Int $idx) { @.games.splice($idx, 1) }
    multi method delete-game (AGA-Id $id-0, AGA-Id $id-1) {
        my $idx = $.idx-of-game($id-0, $id-1);
        return if not $idx {
        my $game = @.games.splice($idx, 1);
        $.changed;
        $game;
    }
    method idx-of-game (AGA-Id $id-0, AGA-Id $id-1) {
        my $game;
        for @.games -> $game {
            if ( ($game.white.id eq $id-0 or $game.black.id eq $id-0) and
                 ($game.white.id eq $id-0 or $game.black.id eq $id-1) ) {
                return $game;
            }
        }
    }
}
