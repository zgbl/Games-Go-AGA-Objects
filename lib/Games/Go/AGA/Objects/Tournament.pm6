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
    has Bool                           $!change-pending = False;    # when changed called
    has Bool                           $!adj-ratings-stale = False; # when a Round changes

    submethod BUILD (:@rounds, :$suppress-changes, :$change-pending) {
        @!rounds = [];
        @rounds.map( { self!set-round($_) } );
        %!player-stats = [];
    };

    method set-suppress-changes (Bool $val = True)  { $!suppress-changes = $val; self; }
    method set-change-pending (Bool $val = True)    { $!change-pending = $val; self; }
    method set-adj-ratings-stale (Bool $val = True) { $!adj-ratings-stale = $val; self; }
    method changed {
        if not $!suppress-changes {
            $!change-pending = True;
            callsame;
        }
        self;
    }

    method !set-round (Games::Go::AGA::Objects::Round $round,
                       Non-Neg-Int $round-number = @!rounds.elems) {
        my @not-found;
        for $round.games -> $game {
            @not-found.push($game.white-id) without %.players{$game.white-id};
            @not-found.push($game.black-id) without %.players{$game.black-id};
        }
        if @not-found.elems {
            die "Missing ID{@not-found.elems > 1 ?? 's' !! ''} {@not-found}";
        }
        @!rounds[$round-number] = $round;
        my $self = self;
        my &prev-callback = $round.change-callback;
        $round.set-change-callback(
            sub {
                %!player-stats = [];        # force re-count
                $!adj-ratings-stale = True; # probably
                &prev-callback();
                $self.changed;
            }
        );
        $.changed;
        self;
    }
    method add-round (Games::Go::AGA::Objects::Round $round) {
        self!set-round($round);
    }
    method replace-round (Games::Go::AGA::Objects::Round $round, Pos-Int $round-number) {
        self!set-round($round, $round-number - 1);
    }
    method delete-round (Games::Go::AGA::Objects::Round $round, Pos-Int $round-number) {
        @!rounds.splice($round-number - 1, 1);
        $.changed;
        self;
    }
    method rounds { @!rounds.elems }
    method round (Pos-Int $round-number) {
        without @!rounds[$round-number - 1] {
            $.add-round(
                Games::Go::AGA::Objects::Round.new(
                    round-number => $round-number,
                ),
            );
        }
        @!rounds[$round-number - 1];
    }
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
    multi method game (Pos-Int $round-number, AGA-Id $id0, AGA-Id $id1 = $id0) {
        @!rounds.[$round-number - 1].game($id0, $id1)
    }
    method add-game (Pos-Int $round-number, Games::Go::AGA::Objects::Game $game) {
        my @not-found;
        @not-found.push($game.white-id) without %.players{$game.white-id};
        @not-found.push($game.black-id) without %.players{$game.black-id};
        if @not-found.elems {
            die "Missing ID{@not-found.elems > 1 ?? 's' !! ''} @not-found";
        }
        @.round($round-number).add-game($game);
    }
    method count-player-stats {
        for <games no_result defeated defeated_by> -> $key {
            %!player-stats{$key} = {};
        }
        for @.games() -> $game {
            my $wid = $game.white-id;
            my $bid = $game.black-id;
            push %!player-stats<games>{$wid}, $game;
            push %!player-stats<games>{$bid}, $game;
            if not $game.winner {
                push %!player-stats<no_result>{$wid}, $bid;
                push %!player-stats<no_result>{$bid}, $wid;
                next;
            }
            my $win-id  = $game.winner;
            my $lose-id = $game.loser;
            push %!player-stats<defeated>{$win-id}, $lose-id;
            push %!player-stats<defeated_by>{$lose-id}, $win-id;
        }
        self;
    }
    method player-stats (Str $stat, AGA-Id $id) {
        $.count-player-stats if not %!player-stats.keys;
        die "No player-stat called $stat (expect: games, "
            ~ 'no_result, defeated or '
            ~ 'defeated_by)' without %!player-stats{$stat};
        %!player-stats{$stat}{$id} // [];
    }

    method send-to-aga {
        my $date = $.get-directive('Date');
        without $date {
            die 'Please set a DATE directive (Start (optional) Finish) to use send-to-aga';
        }
        my @dates = $date.value;    # DATE is a Lists, so return goes into Array
        @dates[1] ||= @dates[0];    # but there may only be one date there
        @dates[0] = @dates[0].subst(/\D/, '-', :g);
        @dates[1] = @dates[1].subst(/\D/, '-', :g);

        my $rules = $.get-directive('RULES');
        without $rules {
            die 'Please set a RULES directive (e.g: AGA, Ing, etc) to use send-to-aga';
        }

        (
            "TOURNEY {$.get-directive('Tourney').value}",
            "     start=@dates[0]",
            "    finish=@dates[1]",
            "     rules={$rules.value}",
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
        my $name-width = 2 + $.players.map({ .last-name.chars + .first-name.chars }).max;
        $.players.map({
            "%9.9s %*.*s %5.1f".sprintf(
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
            "%9.9s %9.9s %s %s %s".sprintf(
                .white-id,
                .black-id,
                .result.uc,
                .handicap,
                .komi,
            );
        });
    }
}

# vim: expandtab shiftwidth=4 ft=perl6
