#!/usr/bin/env perl6
#===============================================================================
#     ABSTRACT:  perl 6 Actions for Games::Go::AGA::Objects::Register
#
#       AUTHOR:  Reid Augustin
#        EMAIL:  reid@hellosix.com
#      CREATED:  04/07/2016 12:40:28 PM
#===============================================================================
use v6;

class Games::Go::AGA::Objects::Register::Actions {
    use Games::Go::AGA::Objects::Types;     # include types
    use Games::Go::AGA::Objects::Register;  # Register object contains:
    use Games::Go::AGA::Objects::Directive; #   Directives and
    use Games::Go::AGA::Objects::Player;    #   Players
                                            #   and comments

    ######################################
    #
    # 'action object' methods - construct G::G::A::O::Register directly
    #   from the Grammar:
    #
    method TOP ($/) {
       make Games::Go::AGA::Objects::Register.new(
            directives => $<directive>>>.ast,
            players    => $<player>>>.ast,
            comments   => $<line-comment>>>.ast,
        );
    }
    method directive ($/) {
        make Games::Go::AGA::Objects::Directive.new(
            key => ~$<key>,
            value => ($<value> // '').trim,
            comment => ($<directive-comment> // '').trim,
        );
    }

    method line-comment ($/) {
        make $/.trim;   # simple string, trim leading and trailing whitespace
    }

    method player ($/) {
        make Games::Go::AGA::Objects::Player.new(
            id             => ~$<id>,
            last-name      => ~$<last-name>,
            first-name     => ($<first-name> // '').trim,
            rank-or-rating => ~$<rank-or-rating> ~~ Rank  # string in Rank form?
                ?? ~$<rank-or-rating>          # use Rank form
                !! +$<rank-or-rating>,         # numeric Rating form
            flags          => ($<flags> // '').trim,
            comment        => ($<player-comment> // '').trim,
        );
    }
}

# vim: expandtab shiftwidth=4 ft=perl6
