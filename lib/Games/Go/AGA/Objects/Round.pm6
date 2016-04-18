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

    has Pos-Int $.round-number is required;
    has Games::Go::AGA::Objects::Game @!games;  # games
    has Int     $.next-table-number = 1;
    has         &.change-callback = method { };

    ######################################
    #
    # accessors
    #
    method get-round-number { $!round-number };
    method set-change-callback ($ccb) { &!change-callback = $ccb };
    method get-next-table-number { $!next-table-number++; }


    ######################################
    #
    # methods
    #
    method changed { self.&!change-callback(); self; }

    method add-game (Games::Go::AGA::Objects::Game $game) {
        @!games.push($game);
        $.changed;
    }

    multi method get-game (Int $idx) { @!games[$idx] }
    multi method get-game (AGA-Id $id_0, AGA-Id $id_1) {
        my $idx = $.idx-of-game($id_0, $id_1);
        return if not $idx;
        @.games[$idx];
    }

    multi method delete-game (Int $idx) { @!games.splice($idx, 1) }
    multi method delete-game (AGA-Id $id_0, AGA-Id $id_1) {
        my $idx = $.idx-of-game($id_0, $id_1);
        return if not $idx;
        my $game = @!games.splice($idx, 1);
        $.changed;
        $game;
    }

    method idx-of-game (AGA-Id $id_0, AGA-Id $id_1) {
        for @.games -> $game {
            if ( ($game.white-id eq $id_0 or $game.black-id eq $id_0) and
                 ($game.white-id eq $id_1 or $game.black-id eq $id_1) ) {
                return $game;
            }
        }
        return; # undef
    }
}
