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

    has AGA-Id   $.white-id is required;  # ID of white player
    has AGA-Id   $.normalized-white-id;
    has AGA-Id   $.black-id is required;  # ID of black player
    has AGA-Id   $.normalized-black-id;
    has Pos-Int  $.table-number;
    has Pos-Int  $.handicap = 0;
    has Rat      $.komi = 7.5;
    has Result   $.result = '?';     # 'w', 'b', or '?'
    has Rating   $.white-adj;        # adjusted rating as a result of this game
    has Rating   $.black-adj;
    has          &.change-callback = method { };

    ######################################
    #
    # accessors
    #
    method white-id { # override accessor to normalize IDs
        $!normalized-white-id = $.normalize-id($!white-id) without $!normalized-white-id;
        $!normalized-white-id;
    }
    method un-normalized-white-id { # in case you want your original ID back
        $!white-id;
    }
    method black-id { # override accessor to normalize IDs
        $!normalized-black-id = $.normalize-id($!black-id) without $!normalized-black-id;
        $!normalized-black-id;
    }
    method un-normalized-black-id { # in case you want your original ID back
        $!black-id;
    }
    method set-white (AGA-Id $w)         { $!white-id        = $w; $.changed; };
    method set-black (AGA-Id $b)         { $!black-id        = $b; $.changed; };
    method set-table-number (Pos-Int $t) { $!table-number    = $t; $.changed; };
    method set-handicap (Pos-Int $h)     { $!handicap        = $h; $.changed; };
    method set-komi (Rat $k)             { $!komi            = $k; $.changed; };
    method set-result (Result $r)        { $!result          = $r; $.changed; };
    method set-white-adj (Rating $w)     { $!white-adj       = $w; $.changed; };
    method set-black-adj (Rating $b)     { $!black-adj       = $b; $.changed; };
    method set-change-callback (&ccb)    { &!change-callback = &ccb; self; };

    ######################################
    #
    # methods
    #
    method changed { self.&!change-callback(); self; }

    method winner {
        given $!result {
            when 'w' {$.white-id};
            when 'b' {$.black-id};
        }
    }

    method loser {
        given $!result {
            when 'b' {$.white-id};
            when 'w' {$.black-id};
        }
    }

    method gist {
        my $gist = (
            $.white-id,
            $.black-id,
            $!handicap,
            $!komi,
            $!result,
        ).grep(*.defined).join(' ');
        with $!table-number or $!white-adj or $!black-adj {
            $gist ~= ' #';
            with $!table-number {
                $gist ~= " Tbl $!table-number";
            }
            with $!white-adj or $!black-adj {
                $gist ~= " adjusted ratings: " ~ (
                    $!white-adj || '?',
                    $!black-adj || '?',
                ).join(', ');
            }
        }
        $gist;
    }
}
