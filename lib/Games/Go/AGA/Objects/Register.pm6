#!/usr/bin/env perl6
################################################################################
# ABSTRACT:  Represents AGA register.tde file, Constructable from Grammar.
#
#   AUTHOR:  Reid Augustin
#    EMAIL:  reid@hellosix.com
#  CREATED:  04/07/2016 12:40:28 PM
################################################################################
use v6;

use Games::Go::AGA::Objects::Types;
use Games::Go::AGA::Objects::Register::Grammar;
use Games::Go::AGA::Objects::Directive;
use Games::Go::AGA::Objects::Player;

# an 'action object' for the parser.  use like this:
#   my $register = Games::Go::AGA::Objects::Register->new;
#   Games::Go::AGA::Objects::Register::Grammar.parse($string, :actions($register));
# Alternatively, make a 'new' one and use add-* methods to populate
class Games::Go::AGA::Objects::Register {
    has Games::Go::AGA::Objects::Directive %!directives;   # hash by key.tclc
    has Games::Go::AGA::Objects::Player    %!players;      # hash by player.id
    has Str                                @!comments;     # array of strings
    has                                    &.change-callback = method { };

    method BUILD (:@comments, :@directives, :@players) {
        @comments.map( { $.add-comment($_) } );
        @directives.map( { $.add-directive($_) } );
        @players.map( { $.add-player($_) } );
    };

    method set-change-callback ($ccb) { &!change-callback = $ccb };
    method changed { self.&!change-callback(); self; }

    ######################################
    #
    #   directives methods
    #
    # called from Actions:
    method directives(Games::Go::AGA::Objects::Directive @directives) {
        @directives.map({ .add-directive(*) });
    }

    multi method add-directive (Games::Go::AGA::Objects::Directive $directive) {
        %!directives{$directive.key.tclc} = $directive;
        say "Register::add-directive TODO: set directive's change-callback?";
        self;
    }
    multi method add-directive (Str $key, Str $value) {
        $.add-directive(
            Games::Go::AGA::Objects::Directive.new(
                key   => $key,
                value => $value,
            ),
        );
    }

    method set-directive (Str $key, Str $value) {
        my $directive = %!directives($key.tclc);
        $directive.value($value) if $directive.so;
        self;
    }

    method get-directive (Str $key) {
        %!directives{$key.tclc};
    }

    method delete-directive (Str $key) {
        %!directives{$key.tclc}:delete;
        self;
    }

    ######################################
    #
    #   player methods
    #
    # called from Actions:
    method players(Games::Go::AGA::Objects::Player @players) {
        @players.map({ .add-player(*) });
    }

    method add-player (Games::Go::AGA::Objects::Player $player) {
        my $id = $player.id;
        die "Duplicate ID $id" if %!players{$id}.so;
        %!players{$id} = $player;
        self;
    }

    method get-player (AGA-Id $id) {
        %!players{$id};
    }

    method delete-player (Str $id) {
        %!players{$id}:delete;
        self;
    }

    ######################################
    #
    #   comment methods
    #
    # override default setter
    method comments(Str @comments) {
        @comments.map({ .add-comment(*) });
    }

    method add-comment (Str $comment) {
        my @comments = $comment.split("\n");    # multi-line?
        for @comments -> $comment {
            # ensure each line is valid comment
            $comment ~~ / ^^ (\h*) ('#'*) (.*) /;
            push @!comments, $1 eq '#'
                  ?? $comment   # no change
                  !! "$0# $2";
        }
        self;
    }

    method get-comments () {
        @!comments;
    }
    multi method get-comment (Int $idx) {
        @!comments[$idx];
    }
    multi method get-comment (Regex $re) {
        @!comments.grep($re);
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
        my @gist;
        @gist.append(
            @!comments,
        ).append(
            %!directives.values.sort,
        ).append(
            %!players.values.sort,
        ).map( *.gist ).join("\n");
    }
}
