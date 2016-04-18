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

class Games::Go::AGA::Objects::Player does Games::Go::AGA::Objects::ID_Normalizer_Role {
    has Str    $.id is required;    # AGA or tmp ID
    has AGA-Id $!normalized-id;
    has Str    $.last-name is required;
    has Str    $.first-name = '';
    has Rank   $.rank;     # like 5D or 4k
    has Rating $.rating;   # like 5.5 or -4.5
    has Str    $.membership-type = '';
    has Date   $.membership-date;
    has Str    $.state = '';
    has Str    $.comment = '';
    has Num    $.sigma;    # for the calculating ratings
    has Str    $.flags = '';    # other flags
    has        &.change-callback = method { };

    method id { # override accessor to normalize IDs
        $!normalized-id = $.normalize-id($!id) if $!normalized-id.not;
        $!normalized-id;
    }
    method un-normalized-id { # in case you want your original ID back
        $.id;
    }

    ######################################
    #
    # accessors
    #
    method set-id (AGA-Id $id)              { $!id = $id; $.changed; self};
    method set-last-name (Str $last)        { $!last-name = $last; $.changed; self};
    method set-first-name (Str $first)      { $!first-name = $first; self};
    method rank { $!rank; };
    method set-rank (Str $rank) {
        $!rank = $rank.uc;
      # $!rating = $.rank-to-rating($rank);
        $!rating = Nil;
        $.changed;
        self;
    };
    method rating { $!rating };
    method set-rating (Rating $rating)      {
        $!rating = $rating;
      # $!rank = $.rating-to-rank($rating);
        $!rank = Nil;
        $.changed;
        self;
    };
    method set-membership-type (Str $type)  { $!membership-type = $type; $.changed; self; }
    method set-membership-date (Date $date) { $!membership-date = $date; $.changed; self; }
    method set-state (Str $state)           { $!state = $state; $.changed; self; }
    method set-comment (Str $comment)       { $!comment = $comment; $.changed; self; }
    method set-sigma (Rat $sigma)           { $!sigma = $sigma; $.changed; self; }
    method set-flags (Str $flags)           { $!flags = $flags; $.changed; self; }
    method set-change-callback (&ccb)       { &!change-callback = &ccb; self; }

    ######################################
    #
    # methods
    #
    method changed { self.&!change-callback(); self; }

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
        $.rating
          ?? $.rating 
          !! $.rank;
    }

    method gist {
        (
            $.id,
            $.last-name ~ ',',
            $.first-name     || '',
            $.rating-or-rank || '<no-rank>',
            $.flags          || '',
            $.comment        || '',
        ).grep(/./).join(' ');
    }
}
