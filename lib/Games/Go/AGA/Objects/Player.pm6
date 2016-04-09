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
    has Str    $.club;
    has Str    $.comment;
    has Num    $.sigma;    # for the rating system
    has Str    $.flags;    # other flags
    has Code   $change-callback = { };

    ######################################
    #
    # accessors
    #
    method get-id { $.id };                           method set-id (AGA-Id $id) { $.id = $id };
    method get-last-name { $.last-name };             method set-last-name (Str $last) { $.last-name = $last };
    method get-first-name { $.first-name };           method set-first-name (Str $first) { $.first-name = $first};
    method get-rank { $.rank };                       method set-rank (Str $rank) { $.rank = $rank };
    method get-rating { $.rating };                   method set-rating (Num $rating) { $.rating = $rating };
    method get-membership-type { $.membership-type }; method set-membership-type (Str $type) { $.membership-type = $type };
    method get-membership-date { $.membership-date }; method set-membership-date (Date $date) { $.membership-date = $date };
    method get-state { $.state };                     method set-state (Str $state) { $.state = $state };
    method get-club { $.club };                       method set-club (Str $club) { $.club = $club };
    method get-comment { $.comment };                 method set-comment (Str $comment) { $.comment = $comment };
    method get-sigma { $.sigma };                     method set-sigma (Num $sigma) { $.sigma = $sigma };
    method get-flags { $.flags };                     method set-flags (Str $flags) { $.flags = $flags };
    method set-change-callback (Code $ccb) { $.change-callback =-$ccb };

    ######################################
    #
    # methods
    #
    method changed { $.($.change-callback)(); }

    method get-rating-or-rank { defined $.rating ?? $.rating !! $.rank; }
}
