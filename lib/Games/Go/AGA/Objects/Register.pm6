#!/usr/bin/env perl6
################################################################################
# ABSTRACT:  Represents AGA register.tde file, Constructable from Grammar.
#
#   AUTHOR:  Reid Augustin
#    EMAIL:  reid@hellosix.com
#  CREATED:  04/07/2016 12:40:28 PM
################################################################################
use v6;

use Games::Go::AGA::Objects::Register::Grammar;
use Games::Go::AGA::Objects::Directive;
use Games::Go::AGA::Objects::Player;

# an 'action object' for the parser.  use like this:
#   my $register = Games::Go::AGA::Objects::Register->new;
#   Games::Go::AGA::Objects::Register::Grammar.parse($string, :actions($register));
# Alternatively, make a 'new' one and use add-* methods to populate
class Games::Go::AGA::Objects::Register {
    has Games::Go::AGA::Objects::Directive @!directives;   # array of directive objects
    has Games::Go::AGA::Objects::Player    @!players;      # array of player objects
    has Str                                @!comments;     # array of strings

    method BUILD (:@comments, :@directives, :@players) {
        @comments.map( { $.add-comment($_) } );
        @directives.map( { $.add-directive($_) } );
        @players.map( { $.add-player($_) } );
    };


    ######################################
    #
    #   directives methods
    #
    multi method add-directive (Games::Go::AGA::Objects::Directive $directive) {
        push @!directives, $directive;
        self;
    }
    multi method add-directive (Str $key, Str $value) {
        push @!directives, Games::Go::AGA::Objects::Directive.new(
            key   => $key,
            value => $value,
        );
        self;
    }

    method set-directive (Str $key, Str $value) {
        my $directive = .get-directive($key);
        if (defined $directive) {
            $directive.value($value);
        }
        self;
    }

    multi method get-directive (Int $idx) {
        @!directives[$idx];
    }

    multi method get-directive (Str $key) {
        my $key-uc = $key.uc;
        for @!directives -> $directive {
            return $directive.value if ($directive.key eq $key-uc);
        }
        return; # undef
    }

    method delete-directive (Str $key) {
        my $idx = 0;
        my $key-uc = $key.uc;
        for @!directives -> $directive {
            if ($directive.key eq $key-uc) {
                return @!directives.splice($idx, 1); # delete and return it
            }
            $idx++;
        }
        self;
    }

    ######################################
    #
    #   player methods
    #
    method add-player (Games::Go::AGA::Objects::Player $player) {
        my $id = $player.id;
        @!players.map({
            die "Duplicate ID $id" if *.id eq $id;
        });
        push @!players, $player;
        self;
    }

    multi method get-player (Int $idx) {
        @!players[$idx];
    }

    multi method get-player (Str $id) {
        for @!players -> $player {
            return $player if ($player.id eq $id);
        }
        return; # undef
    }

    method delete-player (Str $id) {
        my $idx = 0;
        for @!players -> $player {
            if ($player.id eq $id) {
                @!players.splice($idx, 1);    # delete and return it
                last;
            }
        }
        self;
    }

    ######################################
    #
    #   comment methods
    #
    method add-comment (Str $comment) {
        my @comments = $comment.split("\n");    # multi-line?
        for @comments -> $comment {
            # ensure every line in comment is actually commented
            $comment.match(/ ^^ (\s*) ('#'?) (.*) /);
            push @!comments, $1.Str
              ?? $comment   # no change
              !! "$0# $2";
        }
        self;
    }

    method get-comments () {
        return @!comments;
    }
    multi method get-comment (Int $idx) {
        return @!comments[$idx];
    }
    multi method get-comment (Regex $re) {
        for @!comments -> $comment {
            return $comment if $comment.match($re);
        }
        return; # undef
    }

    multi method delete-comment (Int $idx) {
        @!comments.splice($idx, 1);
        self;
    }

    multi method delete-comment (Regex $re) {
        my @new_comments;
        @!comments.map({
            push @new_comments, $_ if not $_.match($re);
        });
        @!comments = @new_comments;
        self;
    }

    ######################################
    #
    #   other methods
    #
    method gist {
        (
            @!comments,
            @!directives.map(*.gist);
            @!players.map(*.gist);
        ).join("\n");
    }
}
