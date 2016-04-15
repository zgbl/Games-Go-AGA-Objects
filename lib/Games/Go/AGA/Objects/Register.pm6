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

    method BUILD (:@comments, :@directives, :@players) {
        say @comments.elems, " comments: ", @comments;
        @comments.map( { $.add-comment($_) } );
        say @directives.elems, " directives";
        @directives.map( { $.add-directive($_) } );
        say @players.elems, " players";
        @players.map( { $.add-player($_) } );
    };

    ######################################
    #
    #   directives methods
    #
    # called from Actions:
    method directives(Games::Go::AGA::Objects::Directive @directives) {
        @directives.map({ .add-directive(*) });
    }

    multi method add-directive (Games::Go::AGA::Objects::Directive $directive) {
say "Register::add-directive: ", $directive.gist;
        %!directives{$directive.key.tclc} = $directive;
        self;
    }
    multi method add-directive (Str $key, Str $value) {
say "Register::add-directive (Str Str): $key $value";
        %!directives{$key.tclc} = Games::Go::AGA::Objects::Directive.new(
            key   => $key,
            value => $value,
        );
        self;
    }

    method set-directive (Str $key, Str $value) {
        my $directive = %!directives($key.tclc);
        $directive.value($value) if $directive.defined;
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
        die "Duplicate ID $id" if %!players{$id};
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
    # called from Actions:
    method comments(Str @comments) {
        @comments.map({ .add-comment(*) });
    }

    method add-comment (Str $comment) {
        my @comments = $comment.split("\n");    # multi-line?
        for @comments -> $comment {
            # ensure every line in comment is actually commented
            $comment.match(/ ^^ (\s*) ('#'?) (.*) /);
say "add-comment: $comment";
            push @!comments, $1.Str
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
        say ( 'test1', 'test2', 'test3' ).join("\n");
        my @gist;
        @gist.append(
            @!comments,
        ).append(
            %!directives.values,
        ).append(
            %!players.values,
        ).map( *.gist ).join("\n");
    }
}
