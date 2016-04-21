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
        my $player = Games::Go::AGA::Objects::Player.new(
            id              => ~$<player><id>,
            last-name       => ~$<player><last-name>,
            first-name      => ~$<player><first-name>,
            rating          => +$<player><rating>,
            membership-type => ~$<player><membership-type>,
            flags           =>  $<player><club>.so ?? "Club=" ~ $<player><club> !! '',
            state           => ~$<player><state>,
        );
        with $<player><membership-date> {
            my @mdy = $<player><membership-date>.split(/\D+/);  # split on non-numerics
            $player.set-membership-date(Date.new(+@mdy[2], +@mdy[0], +@mdy[1]));
        }
        make $player;
    }
}

