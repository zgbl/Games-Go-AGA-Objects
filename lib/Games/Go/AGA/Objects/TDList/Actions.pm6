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
    use Games::Go::AGA::Objects::Types;
    use Games::Go::AGA::Objects::Player;

    ######################################
    #
    # 'action object' methods - construct G::G::A::O::Players directly
    #   from the Grammar:
    #
    method TOP ($/) {
        my $player = Games::Go::AGA::Objects::Player.new(
            last-name       => ~$<last-name>,
            first-name      => ~$<first-name>,
            id              => ~$<id>,
            membership-type => ~$<membership-type>,
            rating          => ~$<rating>,
            membership-date => ~$<membership-date>,
            flags           =>  $<club>.so ?? "Club=" ~ $<club> !! '',
            state           => ~$<state>,
        );
        make $player;
    }
}

