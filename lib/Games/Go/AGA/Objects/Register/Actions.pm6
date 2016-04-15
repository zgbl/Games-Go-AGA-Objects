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
say 'value ', ~$<value> if $<value>;
say 'comment ', ~$<directive-comment> if $<directive-comment>;
        my $directive = Games::Go::AGA::Objects::Directive.new(
          # key => 'GGG',
            key => ~$<key>,
        );
        $directive.set-values(~$<values>) if $<values>;
        $directive.set-comment(~$<directive-comment>) if $<directive-comment>;
        make $directive;
    }

    method line-comment ($/) {
        say "line-comment: ", $/.Str;
        make $/.Str;   # simple string
    }

    method player ($/) {
        say "id ", ~$<id>;
        say "last-name: ",      ~$<last-name>;
        say "first-name: ",     ~$<first-name>     if $<first-name>;
        say "flags: ",          ~$<flag>           if $<flag>;
        say "player-comment: ", ~$<player-comment> if $<player-comment>;
        my $player = Games::Go::AGA::Objects::Player.new(
            id         => ~$<id>,
            last-name  => ~$<last-name>,
            first-name => $<first-name> ?? ~$<first-name> !! '',
            flags      => $<flags> ?? ~$<flags> !! '',
            comment    => $<player-comment> ?? ~$<player-comment> !! '',
        );
        $player.set-rank(~$<rank>) if $<rank>;
        $player.set-rating(+~$<rating>) if $<rating>;
        make $player;
    }
}

