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
    has                                    &.change-callback;

    method BUILD (:@comments, :@directives, :@players) {
        &!change-callback = method {};
        @comments.map( { $.add-comment($_) } );
        @directives.map( { $.add-directive($_) } );
        @players.map( { $.add-player($_) } );
    };

    method set-change-callback ($ccb) { &!change-callback = $ccb; self; };
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
        my &old-callback = $directive.change-callback;
        my $register = self;
        $directive.set-change-callback(
            method {
                $directive.&old-callback; # call directives previous callback
                $register.changed;        # call our own changed callback
            }
        );
        $.changed;
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
        my $directive = %!directives{$key.tclc};
        with $directive {
            $directive.set-value($value);
        }
        else {
            $.add-directive($key, $value);
        }
        self;   # changed gets called via directive's callback
    }

    method get-directive (Str $key) {
        %!directives{$key.tclc};
    }

    method delete-directive (Str $key) {
        %!directives{$key.tclc}:delete;
        $.changed;
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
        die "Duplicate ID $id" if %!players{$id}.defined;
        %!players{$id} = $player;
        my &old-callback = $player.change-callback;
        $player.set-change-callback(
            method {
                $player.{&old-callback};    # call players previous callback
                $.changed;                  # call our own changed callback
            }
        );
        $.changed;
        self;
    }

    method get-player (AGA-Id $id) {
        %!players{$id};
    }

    method delete-player (Str $id) {
        %!players{$id}:delete;
        $.changed;
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
        $.changed;
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
        @!comments.delete($idx);
        $.changed;
        self;
    }

    multi method delete-comment (Regex $re) {
        my @new_comments;
        @!comments.map({
            push @new_comments, $_ if not $_.match($re);
        });
        @!comments = @new_comments;
        $.changed;
        self;
    }

    ######################################
    #
    #   other methods
    #
    method sprint {
        append(
            @!comments,
        ).append(
            %!directives.sort.map({ .value.sprint }),
        ).append(
            %!players.sort.map({ .value.sprint }),
        ).join("\n");
    }
}
