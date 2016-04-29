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

    submethod BUILD (:@rounds, :$suppress-changes, :$change-pending) {
        @rounds.map( { $.add-rounds($_) } );
    };

    method set-suppress-changes (Bool $val) { $!suppress-changes = $val; self; }
    method set-change-pending (Bool $val)   { $!change-pending = $val; self; }
    method changed {
        if not $!suppress-changes {
            $!change-pending = True;
            self.&!change-callback();
        }
        self;
    }

    method add-round (Games::Go::AGA::Objects::Round $round) {
        $.replace-round($round, $.rounds + 1 || 1);
        self;
    }
    method replace-round (Games::Go::AGA::Objects::Round $round, Int $idx) {
        @!rounds[$idx] = $round;
        my $self = self;
        my &prev-ccb = $round.change-callback;
        $round.change-callback(
            sub {
                $self.clear-player-stats;   # force re-count
                $round.&prev-ccb();
            }
        );
        self;
    }
    method delete-round (Games::Go::AGA::Objects::Round $round, Int $idx) {
        @!rounds.splice($idx, 1);
        self;
    }
    method rounds { @!rounds.elems - 1 } # don't include [0]
    method round (Pos-Int $idx) { @!rounds[$idx] }
    ######################################
    #
    #   other methods
    #
    # list of all games in the tournament
    method games { @!rounds.grep({ .so }).map({ |.games }); }
    method count-player-stats {
        for $.games -> $game {
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
            my $win_id = $game.winner.id;
            my $los_id = $game.loser.id;
            push %!player-stats{$win_id}<wins>, $game;
            push %!player-stats{$win_id}<defeated>, $game.loser;
            push %!player-stats{$los_id}<losses>, $game;
            push %!player-stats{$los_id}<defeated_by>, $game.winner;
        }
        self;
    }
    method clear-player-stats { %!player-stats = Nil }
    method player-stats (Str $stat, AGA-Id $id) {
        $.count-player-stats without %!player-stats;
        %!player-stats{$stat}{$.normalize-id($id)};
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
                .full_name,
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
