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

    submethod BUILD (:&change-callback,
                     :@comments,
                     :@directives,
                     :@players) {
        &!change-callback = &change-callback // sub {};       # first!
        @comments.map( { self!_add-comment($_) } );
        @directives.map( { self!_set-directive($_) } );
        @players.map( { self!_add-player($_) } );
    };

    method set-change-callback ($ccb) { &!change-callback = $ccb; self; };
    method changed { &!change-callback(); self; }

    ######################################
    #
    #   directives methods
    #
    # get/set array of directives
    multi method directives { %!directives.values }
    multi method directives (Games::Go::AGA::Objects::Directive @directives) {
        @directives.map({ .set-directive(*) });
    }

    multi method set-directive (Games::Go::AGA::Objects::Directive $directive) { self!_set-directive($directive) }
    method !_set-directive (Games::Go::AGA::Objects::Directive $directive) {
        %!directives{$directive.key.tclc} = $directive;
        my &prev-callback = $directive.change-callback;
        my $register = self;
        $directive.set-change-callback(
            sub {
                &prev-callback();    # call directives previous callback
                $register.changed;  # call our own changed callback
            }
        );
        $.changed;
        self;
    }
    multi method set-directive (Str $key, Str $value, Str $comment? = '') {
        self!_set-directive(
            Games::Go::AGA::Objects::Directive.new(
                key     => $key,
                value   => $value // '1',
                comment => $comment,
            ),
        );
    }
    multi method set-directive (Str $str) {
        $str.match(/^ \s* (\w+) \h+ (<-[#]>*) \h* (.*)/);
        die 'Not a valid directive' without $0;
        self!_set-directive(
            Games::Go::AGA::Objects::Directive.new(
                key     => ~$0,
                value   => ~$1,
                comment => ~$2,
            ),
        );
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
    # get/set array of players
    multi method players { %!players.values; }
    multi method players (Games::Go::AGA::Objects::Player @players) {
        @players.map({ .add-player(*) });
        self;
    }

    method add-player (Games::Go::AGA::Objects::Player $player) { self!_add-player($player) }
    method !_add-player (Games::Go::AGA::Objects::Player $player) {
        my $id = $player.id;
        die "Duplicate ID $id" if %!players{$id}.defined;
        %!players{$id} = $player;
        my &prev-callback = $player.change-callback;
        $player.set-change-callback(
            sub {
                &prev-callback();    # call players previous callback
                $.changed;          # call our own changed callback
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
    # get/set array of comments
    multi method comments { @!comments }
    multi method comments (Str @comments) { @comments.map({ .add-comment(*) }); }

    method add-comment (Str $comment) { self!_add-comment($comment) }
    method !_add-comment (Str $comment) {
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
        @!comments = @!comments.grep({ not $_.match($re) });
        $.changed;
        self;
    }

    ######################################
    #
    #   other methods
    #
    method sprint {
        my @sprint.append(
            @!comments,
        ).append(
            %!directives.sort.map({ .value.sprint }),
        ).append(
            %!players.sort({ $^b.value.rating cmp $^a.value.rating }).map({ .value.sprint }),
        ).join("\n");
    }
}

# vim: expandtab shiftwidth=4 ft=perl6
