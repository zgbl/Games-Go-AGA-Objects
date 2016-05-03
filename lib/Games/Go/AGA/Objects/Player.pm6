#!/usr/bin/env perl6
################################################################################
# ABSTRACT:  Represents an AGA Player
#
#   AUTHOR:  Reid Augustin
#    EMAIL:  reid@hellosix.com
#  CREATED:  04/07/2016 12:40:28 PM
################################################################################
use v6;
use Games::Go::AGA::Objects::ID_Normalizer_Role;
use Games::Go::AGA::Objects::Types;

class Games::Go::AGA::Objects::Player
    does Games::Go::AGA::Objects::ID_Normalizer_Role {

    has Str            $.id is required;       # AGA or tmp ID
    has AGA-Id         $!normalized-id;
    has Str            $.last-name is required;
    has Str            $.first-name      = '';
    has Rank-or-Rating $.rank-or-rating is required;
    has Str            $.membership-type = '';
    has Date           $.membership-date;
    has Str            $.state           = '';
    has Str            $.comment         = '';
    has Num            $.sigma;                # for the calculating ratings
    has Str            $.flags           = ''; # other flags
    has                &.change-callback = sub { };
    has Bool           $.change-flag     = False;   # set by changed()

    method id { # override accessor to normalize IDs
        $!normalized-id = $.normalize-id($!id) if $!normalized-id.not;
        $!normalized-id;
    }
    method id_original { # in case you want your original ID back
        $!id;
    }

    ######################################
    #
    # accessors
    #
    method set-id (AGA-Id $i)            { $!id              = $i; $.changed; }
    method set-last-name (Str $l)        { $!last-name       = $l; $.changed; }
    method set-first-name (Str $f)       { $!first-name      = $f; $.changed; }
    method set-rank-or-rating (Rank-or-Rating $r) { $!rank-or-rating = $r; $.changed; }
    method set-membership-type (Str $t)  { $!membership-type = $t; $.changed; }
    method set-membership-date (Date $d) { $!membership-date = $d; $.changed; }
    method set-state (Str $s)            { $!state           = $s; $.changed; }
    method set-comment (Str $c)          { $!comment         = $c; $.changed; }
    method set-sigma (Rat $s)            { $!sigma           = $s; $.changed; }
    method set-flags (Str $f)            { $!flags           = $f; $.changed; }
    method set-change-callback (&ccb)    { &!change-callback = &ccb; self; }

    ######################################
    #
    # methods
    #
    method set-changed-flag (Bool $new = True) { $!change-flag = $new; self; }
    method changed { &!change-callback(); $.set-changed-flag(); self; }

    method rating ( Rank-or-Rating $rating = $!rank-or-rating ) {
        given $rating {
            when Rating { $rating }
            default {   # convert Rank to Rating
                $rating ~~ m:i/(\d+)(<[dk]>)/;
                $/[1].uc ~~ 'D'
                ??  $/[0] + 0.5   # dan from 1 up
                !! -$/[0] - 0.5;  # kyu from -1 down
            }
        }
    }
    method rank ( Rank-or-Rating $rank = $!rank-or-rating ) {
        given $rank {
            when Rank { $rank }
            default {   # convert Rating to Rank
                $rank.Int.abs ~ ($rank >= 0 ?? 'D' !! 'K');
            }
        }
    }

    ######################################
    #
    # other methods
    #
    # convenience method to extract an individual named flag
    method flag (Str $key) {
        $!flags ~~ m:i/ << $key '=' (\S+) /;
        ~$0 if $0.defined;
    }
    method club { $.flag('Club') }      # required for TDList Club column

    method full-name {
        $!first-name
          ?? "$!last-name, $!first-name"
          !! $!last-name;
    }
    method sprint {
        (
            $.id,
            $!last-name ~ ($!first-name.so ?? ',' !! ''),
            $!first-name,
            $.rank-or-rating,
            $!flags,
            $!comment,
        ).grep({ .so }).join(' ');
    }
}

# vim: expandtab shiftwidth=4 ft=perl6
