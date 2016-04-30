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

    has Str    $.id is required;       # AGA or tmp ID
    has AGA-Id $!normalized-id;
    has Str    $.last-name is required;
    has Str    $.first-name      = '';
    has Rank   $.rank;                 # like 5D or 4k
    has Rating $.rating;               # like 5.5 or -4.5
    has Str    $.membership-type = '';
    has Date   $.membership-date;
    has Str    $.state           = '';
    has Str    $.comment         = '';
    has Num    $.sigma;                # for the calculating ratings
    has Str    $.flags           = ''; # other flags
    has        &.change-callback = sub { };

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
    method set-rank (Str $r)             { $!rank            = $r.uc; $!rating = Nil; $.changed; }
    method set-rating (Rating $r)        { $!rating          = $r; $!rank = Nil; $.changed; }
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
    method changed { &!change-callback(); self; }

    multi method rank-to-rating ( Rating $rating ) { $rating } # already a Rating
    # rank is coarse-grained.  return middle of rating range.
    multi method rank-to-rating ( Rank $rank ) {
        $rank ~~ m:i/(\d+)(<[dk]>)/;
        $/[1].uc ~~ 'D'
          ??  $/[0] + 0.5   # dan from 1 to 9.99
          !! -$/[0] - 0.5;  # kyu from -99.99 to -1
    }

    multi method rating-to-rank ( Rank $rank ) { $rank }  # already a Rank
    multi method rating-to-rank ( Rating $rating ) {
        $rating.Int.abs ~ ($rating >= 0 ?? 'D' !! 'K');
    }

    ######################################
    #
    # other methods
    #
    method rating-or-rank {
        with $!rating { $!rating    }
        orwith $!rank { $!rank      }
        else          { '<no-rank>' }
    }

    # convenience method to extract an individual named flag
    method flag (Str $key) {
        $!flags ~~ m:i/ << $key '=' (\S+) /;
        ~$0 if $0.defined;
    }
    method club { $.flag('Club') }      # required for TDList Club column

    method sprint {
        (
            $.id,
            $!last-name ~ ($!first-name.so ?? ',' !! ''),
            $!first-name,
            $.rating-or-rank,
            $!flags,
            $!comment,
        ).grep({ .so }).join(' ');
    }
}

# vim: expandtab shiftwidth=4 ft=perl6
