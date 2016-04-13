#!/usr/bin/env perl6
################################################################################
# ABSTRACT:  Represents an AGA Player
#
#   AUTHOR:  Reid Augustin
#    EMAIL:  reid@hellosix.com
#  CREATED:  04/07/2016 12:40:28 PM
################################################################################
use v6;

class Games::Go::AGA::Objects::Player {
    use Games::Go::AGA::Objects::Types;
    has AGA-Id $.id is required;  # AGA or tmp ID
    has Str    $.last-name is required;
    has Str    $.first-name;
    has Rank   $.rank;     # like 5D or 4k
    has Rating $.rating;   # like 5.5 or -4.5
    has Str    $.membership-type;
    has Date   $.membership-date;
    has Str    $.state;
    has Str    $.comment;
    has Num    $.sigma;    # for the calculating ratings
    has Str    $.flags;    # other flags
    has        &!change-callback = method { };

    method BUILD (
        :$id,
        :$last-name,
        :$first-name = '',
        :$rank?,
        :$rating?,
        :$membership-type?,
        :$membership-date?,
        :$state?,
        :$comment = '',
        :$sigma?,
        :$flags = '',
        :&change-callback = sub {},
    ) {
        $!id = $.normalize-id($id);
        for < last-name first-name rank rating membership-type membership-date state comment sigma flags > -> $key {
            $!($key) = $$key if $$key;
        }
        &!change-callback = &change-callback if &change-callback;
    }
    ######################################
    #
    # accessors
    #
    method set-id (AGA-Id $id)              { $!id = $id; $.changed; self};
    method set-last-name (Str $last)        { $!last-name = $last; $.changed; self};
    method set-first-name (Str $first)      { $!first-name = $first; self};
    method rank {
        $!rank.defined
          ?? $!rank
          !! $.rating-to-rank($!rating);
    };
    method set-rank (Str $rank) {
        $!rank = $rank;
        $!rating = $.rank-to-rating($rank);
        $.changed;
        self;
    };
    method rating {
        $!rating.defined
          ?? $!rating
          !! $.rank-to-rating($!rank);
    };
    method set-rating (Rating $rating)      {
        $!rating = $rating;
        $!rank = $.rating-to-rank($rating);
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
    method changed { &!change-callback(); self; }

    # rank is coarse-grained.  return middle of rating range.
    method rank-to-rating ( Rank $rank ) {
        return if not $rank.defined;
        $rank ~~ m:i/(\d+)(<[dk]>)/;
        $/[1].uc ~~ 'D'
          ??  $/[0] + 0.5   # dan from 1 to 9.99
          !! -$/[0] - 0.5;  # kyu from -99.99 to -1
    }

    method rating-to-rank ( Rating $rating ) {
        return if not $rating.defined;
        return $rating.Int.abs ~ ($rating > 0 ?? 'D' !! 'K');
    }

    method normalize-id ( Str $id ) {
        # separate word part from number part,
        # remove leading zeros from digit part
        $id ~~ m:i/(<[a..z_]>+)0*(\d+)/;
        if not ($/[0].defined and $/[1].defined) {
            die 'ID expects letters followed by digits like Tmp00123';
        }
        return $/[0].uc ~ $/[1];
    }

    ######################################
    #
    # other methods
    #

    method gist {
        "$!id $!last-name, $!first-name { $!rating || $!rank }";
    }
}
