################################################################################
# ABSTRACT:  tests for Games::Go::AGA::Objects::Tournament
#
#   AUTHOR:  Reid Augustin
#    EMAIL:  reid@hellosix.com
#  CREATED:  04/07/2016 12:40:28 PM
################################################################################
use v6;
use Test;
plan 5;

use Games::Go::AGA::Objects::Directive;
use Games::Go::AGA::Objects::Player;
use Games::Go::AGA::Objects::Game;
use Games::Go::AGA::Objects::Round;
use Games::Go::AGA::Objects::Tournament;          # the module under test

my $dut = Games::Go::AGA::Objects::Tournament.new(
    comments => [ <comment> ],
    directives => (
        Games::Go::AGA::Objects::Directive.new(
            key => 'Tourney',
            value => 'Test Tournament 1',
            comment => 'tourney comment',
        ),
        'DATE 2016/04/28 # date comment',
    ),
    players => (
        Games::Go::AGA::Objects::Player.new(
            id         => 'TST022',
            last-name  => 'Last Name 22',
            first-name => 'First Name 22',
            rank       => '5D',
            flags      => 'Club=FooB Xyz=ABC',
        ),
        Games::Go::AGA::Objects::Player.new(
            id         => 'Tst001',
            last-name  => 'Last Name 1',
            first-name => 'First Name 1',
            rank       => '4D',
            flags      => 'Club=ABCD',
        ),
    ),
);

my $callback-called;
my $game-callback-called;
my &old-callback = $dut.change-callback;
$dut.set-change-callback(
    method {
        $dut.&old-callback();
        $callback-called++;
    }
);

my $expect = (
).join("\n");

is $dut.sprint, $expect, 'sprint OK';
is $callback-called, 10, 'callback-called';

my $game = Games::Go::AGA::Objects::Game.new(
    white-id => 'Tst1',
    black-id => 'Tst22',
    komi     => 0.5,
    handicap => 2,
    change-callback => method { $game-callback-called++ },
);
throws-like(
    { $dut.round(1).add-game( $game ); },
    X::AdHoc,
);
$dut.add-player(Games::Go::AGA::Objects::Player.new(
    id         => 'Tst033',
    last-name  => 'Last Name33',
    first-name => 'First Name33',
    rank       => '3D',
));

$dut.round(1).add-game(
    Games::Go::AGA::Objects::Game.new(
        white-id => 'Tst1',
        black-id => 'TST033',
        komi     => 0.5,
        handicap => 2,
        change-callback => method { $game-callback-called++ },
    );
);
