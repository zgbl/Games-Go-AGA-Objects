#!/usr/bin/env perl6
################################################################################
# ABSTRACT:  Represents an AGA Game
#
#   AUTHOR:  Reid Augustin
#    EMAIL:  reid@hellosix.com
#  CREATED:  04/07/2016 12:40:28 PM
################################################################################
use v6;

class Games::Go::AGA::Objects::Game {
    use Games::Go::AGA::Objects::Types;
    use Games::Go::AGA::Objects::Player;

    has Games::Go::AGA::Objects::Player $.white is required;  # white player
    has Games::Go::AGA::Objects::Player $.black is required;  # black player
    has Pos-Int $.table_number;
    has Pos-Int $.handi;
    has Num     $komi;
    has Result $.result;    # 'w', 'b', or '?'
    has Rating $.white-adj;  # adjusted rating as a result of this game
    has Rating $.black-adj;
    has Code   $change-callback = { };

    ######################################
    #
    # accessors
    #
    method get-white { $.white };         method set-white (Player $w) { $.white = $w };
    method get-black { $.black };         method set-black (Player $b) { $.black = $b };
    method get-result { $.result };       method set-result (Result $r) { $.result = $r, $.changed };
    method get-white-adj { $.white-adj }; method set-white-adj (Rating $w) { $.white-adj = $w };
    method get-black-adj { $.black-adj }; method set-black-adj (Rating $b) { $.black-adj = $b };
    method set-change-callback (Code $ccb) { $.change-callback = $ccb };;

    ######################################
    #
    # methods
    #
    method changed { $.($.change-callback)(); }
}
