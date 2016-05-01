#!/usr/bin/env perl6
################################################################################
# ABSTRACT:  Represents a Tournament.  is-a Register, and contains Rounds
#
#   AUTHOR:  Reid Augustin
#    EMAIL:  reid@hellosix.com
#  CREATED:  Wed Apr 27 19:06:22 PDT 2016
################################################################################
use v6;

use Games::Go::AGA::Objects::Types;
use Games::Go::AGA::Objects::Game;
use Games::Go::AGA::Objects::Round;
use Games::Go::AGA::Objects::Register;
use Games::Go::AGA::Objects::ID_Normalizer_Role;

class Games::Go::AGA::Objects::Tournament
    is Games::Go::AGA::Objects::Register
    does Games::Go::AGA::Objects::ID_Normalizer_Role {

    has Games::Go::AGA::Objects::Round @!rounds;   # list of rounds, skip [0]
    has                                %!player-stats;
    has Bool                           $.suppress-changes = False;
    has Bool                           $!change-pending = False;
    has Bool                           $!adj-ratings-stale = False; # when a Round changes

    submethod BUILD (:@rounds, :$suppress-changes, :$change-pending) {
        @rounds.map( { self!set-round(*) } );
        %!player-stats = [];
    };

    method set-suppress-changes (Bool $val = True)  { $!suppress-changes = $val; self; }
    method set-change-pending (Bool $val = True)    { $!change-pending = $val; self; }
    method set-adj-ratings-stale (Bool $val = True) { $!adj-ratings-stale = $val; self; }
    method changed {
        if not $!suppress-changes {
            $!change-pending = True;
            &.change-callback();
        }
        self;
    }

    method !set-round (Games::Go::AGA::Objects::Round $round,
                       Non-Neg-Int $round-number = @!rounds.elems) {
        @!rounds[$round-number] = $round;
        my $self = self;
        my &prev-callback = $round.change-callback;
        $round.set-change-callback(
            sub {
                %!player-stats = [];        # force re-count
                $!adj-ratings-stale = True; # probably
                &prev-callback();
            }
        );
    }
    method add-round (Games::Go::AGA::Objects::Round $round) {
        self!set-round($round);
        self;
    }
    method replace-round (Games::Go::AGA::Objects::Round $round, Pos-Int $round-number) {
        self!set-round($round, $round-number - 1);
        self;
    }
    method delete-round (Games::Go::AGA::Objects::Round $round, Pos-Int $round-number) {
        @!rounds.splice($round-number - 1, 1);
        self;
    }
    method rounds { @!rounds.elems }
    method round (Pos-Int $round-number) { @!rounds[$round-number - 1] }
    ######################################
    #
    #   other methods
    #
    # list of all games in the tournament
    method games {
        @!rounds.map( |*.games ); # flatten into one big list
    }
    multi method game (Pos-Int $round-number, Int $idx) {
        @!rounds.[$round-number - 1].game($idx)
    }
    multi method game (Pos-Int $round-number, AGA-Id $id0, AGA-Id $id1?) {
        @!rounds.[$round-number - 1].game($id0, $id1)
    }
    method add-game (Pos-Int $round-number, Games::Go::AGA::Objects::Game $game) {
        without @!rounds[$round-number - 1] {
            $.add-round(
                Games::Go::AGA::Objects::Round.new(
                    round-number => $round-number,
                ),
            );
        }
        @!rounds[$round-number - 1].add-game($game);
    }
    method count-player-stats {
say "\n", $.games().perl, "\n";
        for $.games() -> $game {
say "\n", $game.perl, "\n";
            my $white = $game.white;
            my $black = $game.black;
            my $wid = $white.id;
            my $bid = $black.id;
            push %!player-stats{$wid}<games>, $game;
            push %!player-stats{$bid}<games>, $game;
            if (not defined $game.winner) {
                push %!player-stats{$wid}<no_result>, $black;
                push %!player-stats{$bid}<no_result>, $white;
                next;
            }
            my $win-id = $game.winner.id;
            my $los-id = $game.loser.id;
            push %!player-stats{$win-id}<wins>, $game;
            push %!player-stats{$win-id}<defeated>, $game.loser;
            push %!player-stats{$los-id}<losses>, $game;
            push %!player-stats{$los-id}<defeated_by>, $game.winner;
        }
        self;
    }
    method player-stats (Str $stat, AGA-Id $id) {
        $.count-player-stats if not %!player-stats.keys;
        given %!player-stats{$stat}{$id} {
            $_ if .defined;
            die "No player-stat called $stat (expect: games, "
                ~ 'no_result, wins, losses, defeated or '
                ~ 'defeated_by)' without %!player-stats{$stat};
            die "No player-stat for ID $id";
        }
    }

    method send-to-aga {
        my @dates = $.get-directive('Date').value.split(/<[\s-]>+/);
        @dates[1] ||= @dates[0];
        @dates[0] = @dates[0].subst(/\D/, '-', :g);
        @dates[1] = @dates[1].subst(/\D/, '-', :g);

        (
            "TOURNEY {$.get-directive('Tourney').value}",
            "     start=@dates[0]",
            "    finish=@dates[1]",
            "     rules={$.get-directive('RULES').value}",
            '',
            'PLAYERS',
            |$.players-to-aga,
            '',
            'GAMES',
            |$.games-to-aga,
            ''
        ).join("\n");
    }

    method players-to-aga {
        my $name-width = $.players.map({ .length }).max;
        $.players.map({
            "%9.9s %*.*s %s\n".sprintf(
                .id,
                $name-width,
                $name-width,
                .full-name,
                .rating,
            );
        });
    }

    method games-to-aga {
        $.games.grep({ .winner }).map({
            "%9.9s %9.9s %s %s %s\n".printf(
                .white.id,
                .black.id,
                .result.uc,
                .handi,
                .komi,
            );
        });
    }
}

# vim: expandtab shiftwidth=4 ft=perl6
