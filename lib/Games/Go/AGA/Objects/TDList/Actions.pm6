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
        my %opts = 
            id              => ~$m<id>,
            last-name       => ~$m<last-name>;
        with $m<first-name>      { %opts<first-name>      = ~$m<first-name> }
        with $m<rating>          { %opts<rating>          =  $m<rating>.Rat }
        with $m<membership-type> { %opts<membership-type> = ~$m<membership-type> }
        with $m<club>            { %opts<club>            = "Club=" ~ $m<club> }
        with $m<state>           { %opts<state>           = ~$m<state> }
        with $m<membership-date> {
            my @mdy = $m<membership-date>.split(/\D+/);  # split on non-numerics
            %opts<membership-date> = Date.new(+@mdy[2], +@mdy[0], +@mdy[1]);
        }
        make Games::Go::AGA::Objects::Player.new(|%opts);
    }
}

