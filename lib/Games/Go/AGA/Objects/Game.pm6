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
    has Pos-Int  $.table_number;
    has Pos-Int  $.handicap;
    has Num      $.komi;
    has Result   $.result = '?';     # 'w', 'b', or '?'
    has Rating   $.white-adj;        # adjusted rating as a result of this game
    has Rating   $.black-adj;
    has          &!change-callback = sub { };

    ######################################
    #
    # accessors
    #
    method set-white (Games::Go::AGA::Objects::Player $w) { $!white = $w; $.changed; self; };
    method set-black (Games::Go::AGA::Objects::Player $b) { $!black = $b; $.changed; self; };
    method set-handicap (Result $h)   { $!handicap = $h; $.changed; self; };
    method set-komi (Result $k)       { $!komi = $k; $.changed; self; };
    method set-result (Result $r)     { $!result = $r; $.changed; self; };
    method set-white-adj (Rating $w)  { $!white-adj = $w; $.changed; self; };
    method set-black-adj (Rating $b)  { $!black-adj = $b; $.changed; self; };
    method set-change-callback (&ccb) { &!change-callback = &ccb; self; };

    ######################################
    #
    # methods
    #
    method changed { self.&!change-callback(); self; }

    method winner {
        return $.white if $.result eq 'w';
        return $.black if $.result eq 'b';
        return;
    }

    method loser {
        return $.black if $.result eq 'w';
        return $.white if $.result eq 'b';
        return;
    }
}
