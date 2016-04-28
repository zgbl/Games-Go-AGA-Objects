#!/usr/bin/env perl6
################################################################################
# ABSTRACT:  Represents a Tournament.  is-a Register, and contains Rounds
#
#   AUTHOR:  Reid Augustin
#    EMAIL:  reid@hellosix.com
#  CREATED:  Wed Apr 27 19:06:22 PDT 2016
################################################################################
use v6;

use Games::Go::AGA::Objects::Types;
use Games::Go::AGA::Objects::Round;
use Games::Go::AGA::Objects::Player;

class Games::Go::AGA::Objects::Tournament
    is Games::Go::AGA::Objects::Register {

    has Games::Go::AGA::Objects::Round @!rounds;   # list of rounds, skip [0]
    has                                &.change-callback;

    method set-change-callback ($ccb) { &!change-callback = $ccb; self; };
    method changed { self.&!change-callback(); self; }

    method add-round (Games::Go::AGA::Objects::Round $round, Int $idx) {
        push @!rounds, $round;
    }
    method replace-round (Games::Go::AGA::Objects::Round $round, Int $idx) {
        @!rounds[$idx] = $round;
    }
    method delete-round (Games::Go::AGA::Objects::Round $round, Int $idx) {
        @!rounds.splice($idx, 1);
    }
    method rounds { @rounds.elems - 1 } # don't include [0]
    method round (Pos-Int $idx) { @rounds[$idx] }
    ######################################
    #
    #   other methods
    #
    # list of all games in the tournament
    method games {
        my @games;
        for @!rounds -> $round {
            push @games, $round->games;
        }
        @games;
    }
    method player-stats (Str $stat, Aga-ID $id) {
        # TODO
    }

    method sprint {
        append(
            @!comments,
        ).append(
            %!directives.sort.map({ .value.sprint }),
        ).append(
            %!players.sort.map({ .value.sprint }),
        ).join("\n");
    }
}
