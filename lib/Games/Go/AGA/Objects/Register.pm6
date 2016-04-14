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
    has Games::Go::AGA::Objects::Directive %!directives;   # hash by key.tclc
    has Games::Go::AGA::Objects::Player    %!players;      # hash by player.id
    has Str                                @!comments;     # array of strings

    method BUILD (:@comments, :@directives, :@players) {
        say "comments: ", @comments;
        @comments.map( { $.add-comment($_) } );
        @directives.map( { $.add-directive($_) } );
        @players.map( { $.add-player($_) } );
    };


    ######################################
    #
    #   directives methods
    #
    multi method add-directive (Games::Go::AGA::Objects::Directive $directive) {
        %!directives{$directive.key.tclc} = $directive;
        self;
    }
    multi method add-directive (Str $key, Str $value) {
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
        return %!directives{$key.tclc};
    }

    method delete-directive (Str $key) {
        %directives{$key.tclc}:delete;
        self;
    }

    ######################################
    #
    #   player methods
    #
    method add-player (Games::Go::AGA::Objects::Player $player) {
        my $id = $player.id;
        die "Duplicate ID $id" if %!players{id};
        %players{$id} = $player;
        self;
    }

    method get-player (AGA-id $id) {
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
            @!comments.Str,
            @!directives.map(*.gist);
            @!players.map(*.gist);
        ).join("\n");
    }
}
