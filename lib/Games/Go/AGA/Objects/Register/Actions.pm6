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
            comments   => $<comment>>>.ast,
        );
    }
    method directive ($/) {
        say "chunks ", $/.chunks;
        say "key is: ", ~$<key>;
        my $directive = Games::Go::AGA::Objects::Directive.new(
            key => ~$<key>,
        );
        say "made dir";
        $directive.set-values(~$<values>) if ~$<values>;
        make $directive;
    }

    method comment ($/) {
        say $/.Str;
        make $/.Str;   # simple string
    }

    method player ($/) {
        say $<player>;
        make Games::Go::AGA::Objects::Player.new(
            id         => ~$<id>,
            last-name  => ~$<last-name>,
            first-name => ~$<first-name>,
            rank       => ~$<rank>,
            rating     => ~$<rating>,
            flags      => ~$<flags>,
            comment    => ~$<player-comment>,
        );
    }
}

