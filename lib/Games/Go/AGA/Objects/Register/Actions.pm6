#!/usr/bin/env perl6
#===============================================================================
#     ABSTRACT:  perl 6 Actions for Games::Go::AGA::DataObjects::Register
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
        my $directive = Games::Go::AGA::Objects::Directive.new(
          # key => 'GGG',
            key => ~$<key>,
            value => $<value>.so ?? ~$<value> !! '',
            comment => $<directive-comment>.so ?? ~$<directive-comment> !! '',
        );
        #say "set-value({~$<value>})" if $<value>;
        #$directive.set-value(~$<value>) if $<value>;
        #$directive.set-comment(~$<directive-comment>) if $<directive-comment>;
        make $directive;
    }

    method line-comment ($/) {
        make $/.Str.trim;   # simple string, trim leading and trailing whitespace
    }

    method player ($/) {
        my $player = Games::Go::AGA::Objects::Player.new(
            id         => ~$<id>,
            last-name  => ~$<last-name>.trim,
            first-name => $<first-name> ?? ~$<first-name>.trim !! '',
            flags      => $<flags> ?? ~$<flags>.trim !! '',
            comment    => $<player-comment> ?? ~$<player-comment>.trim !! '',
        );
        $player.set-rank(~$<rank>) if $<rank>;
        $player.set-rating(+~$<rating>) if $<rating>;
        make $player;
    }
}

