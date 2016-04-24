#!/usr/bin/env perl6
#===============================================================================
#     ABSTRACT:  perl 6 Actions for Games::Go::AGA::Objects::TDList
#
#       AUTHOR:  Reid Augustin
#        EMAIL:  reid@hellosix.com
#      CREATED:  Wed Apr 20 12:36:10 PDT 2016
#===============================================================================
use v6;

class Games::Go::AGA::Objects::TDList::Actions {
    use Games::Go::AGA::Objects::Player;

    ######################################
    #
    # 'action object' methods - construct G::G::A::O::Players directly
    #   from the TDList Grammar:
    #
    method TOP ($/) {
        my $m = $<player>;  # the match
        my %opts;
        for <id last-name first-name membership-type state> -> $key {
            with $m{$key} { %opts{$key} = ~$m{$key} }
        }
        # options that need special treatment:
        with $m<rating>          { %opts<rating> =  $m<rating>.Rat }
        with $m<club>            { %opts<flags>  = "Club=" ~ $m<club> }
        with $m<membership-date> {
            my @mdy = $m<membership-date>.split(/\D+/);  # split on non-numerics
            %opts<membership-date> = Date.new(+@mdy[2], +@mdy[0], +@mdy[1]);
        }
        make Games::Go::AGA::Objects::Player.new(|%opts);
    }
}

