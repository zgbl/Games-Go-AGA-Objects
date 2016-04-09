#!/usr/bin/env perl6
use v6;
################################################################################
# ABSTRACT:  Represents AGA register.tde file, Constructable from Grammer.
#
#   AUTHOR:  Reid Augustin
#    EMAIL:  reid@hellosix.com
#  CREATED:  04/07/2016 12:40:28 PM
################################################################################

use Games::Go::AGA::Objects::Register::Grammer;
use Games::Go::AGA::Objects::Directive;
use Games::Go::AGA::Objects::Player;


# an 'action object' for the parser.  use like this:
#   my $register = Games::Go::AGA::Objects::Register->new;
#   Games::Go::AGA::Objects::Register::Grammer.parse($string, :actions($register));
# Alternatively, make a 'new' one and use add_* methods to populate
class Games::Go::AGA::Objects::Register {
    has Games::Go::AGA::Objects::Directive @!directives;   # array of directive objects
    has Games::Go::AGA::Objects::Player    @!players;      # array of player objects
    has Str                                @!comments;     # array of strings


    ######################################
    #
    # 'action object' methods - construct directly from Grammer:
    #
    method directive ($/) {
        .add_directive(
            Games::Go::AGA::Objects::Directive.new(
                $/.make: ~$/,
            );
        )
    }

    method comment ($/) {
        .add_comment($/.make: ~$/);
    }

    method player ($/) {
        .add_player(
            Games::Go::AGA::Objects::Player.new(
                $/.make: ~$,
            )
        );
    }


    ######################################
    #
    #   directives methods
    #
    method add_directive (Str $key, Str $value) { # TODO Str?  Array?
        push @.directives, Games::Go::AGA::Objects::Directives->new(
            key   => $key,
            value => $value,
        }
    }

    method set_directive (Str $key, Str $value) {
        my $directive = .get_directive($key);
        if (defined $directive) {
            $directive.value($value);
        }
    }

    multi method get_directive (Int $idx) {
        @.directives[$idx];
    }

    multi method get_directive (Str $key) {
        for @directive -> $directive {
            return $directive.value if ($directive.key eq $key);
        }
        return; # undef
    }

    method delete_directive (Str $key) {
        my $idx = 0;
        for @directives -> $directive {
            if ($directive.key eq $key) {
                return @directives.splice($idx, 1); # delete and return it
            }
            $ii++;
        }
        return; # undef
    }

    ######################################
    #
    #   player methods
    #
    method add_player (Games::Go::AGA::Objects::Player $player) {
        push @.players, $player;
    }

    multi method get_player (Int $idx) {
        @.players[$idx];
    }

    multi method get_player (Str $id) {
        for @player -> $player {
            return $player if ($player.id eq $id);
        }
        return; # undef
    }

    method delete_player (Str $id) {
        my $idx = 0;
        for @players => $player {
            if ($player.id eq $id) {
                return @players.splice($idx, 1);    # delete and return it
            }
        }
        return; # undef
    }

    ######################################
    #
    #   comment methods
    #
    method add_comment (Str $comment) {
        my @comments = $comment.split("\n");    # multi-line?
        for @comments -> $comment {
            # ensure every line in comment is actually commented
            $comment =~ s/ ^^ (\s*) <-[#]> /$1# /;
            push @.comments, $comment;
        }
    }

    multi method get_comment (Int $idx) {
        return @.comments[$idx];
    }

    multi method get_comment (Regex $re) {
        for @.comments -> $comment {
            return $comment if ($comment =~ m/$re/);
        }
        return; # undef
    }

    multi method delete_comment (Int $idx) {
        return @.comments.splice($idx, 1);
    }

    multi method delete_comment (Regex $re) {
        my $idx = 0;
        for @.comments -> $comment {
            return .delete_comment($idx) if ($comment =~ m/$re/);
        }
        return; # undef
    }
}
