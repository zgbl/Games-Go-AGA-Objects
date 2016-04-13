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
say 'key: ', ~$<key>;
        my $directive = Games::Go::AGA::Objects::Directive.new(
            key => ~$<key>,
        );
        $directive.set-values(~$<values>) if ~$<values>;
        $directive.set-comment(~$<directive-comment>) if ~$<directive-comment>;
        make $directive;
    }

    method line-comment ($/) {
        say "line-comment: ", $/.Str;
        make $/.Str;   # simple string
    }

    method player ($/) {
        say $<player>;
        my $player = Games::Go::AGA::Objects::Player.new(
            id         => ~$<id>,
            last-name  => ~$<last-name>,
        );
        for < first-name rank rating flags player-comment > -> $key {
            $player.add-$key(~$<$key>) if ~$<$key>;
        }
        make $player;
    }
}

