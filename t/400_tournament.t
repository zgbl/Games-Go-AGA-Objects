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
        Games::Go::AGA::Objects::Directive.new(
            key => 'DATE',
            value => '2016/04/28',
            comment => '# date comment',
        ),
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

my $expect = (
    '# comment',
    '## DATE 2016/04/28 # date comment',
    '## Tourney Test Tournament 1 # tourney comment',
    'TST1 Last Name 1, First Name 1 4D Club=ABCD',
    'TST22 Last Name 22, First Name 22 5D Club=FooB Xyz=ABC',
).join("\n");

my $callback-called = 0;
my $game-callback-called = 0;
my &old-callback = $dut.change-callback;
$dut.set-change-callback(
    method {
        &old-callback();
        $callback-called++;
    }
);

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
say 'Add player';
$dut.add-player(Games::Go::AGA::Objects::Player.new(
    id         => 'Tst033',
    last-name  => 'Last Name33',
    first-name => 'First Name33',
    rank       => '3D',
));

say 'Add game';
$dut.add-game(1,
    Games::Go::AGA::Objects::Game.new(
        white-id => 'TST1',
        black-id => 'TST33',
        komi     => 0.5,
        handicap => 2,
        change-callback => sub { $game-callback-called++ },
    ),
);

$expect ~= "\nTST33 Last Name33, First Name33 3D";
is $dut.sprint, $expect, 'sprint OK';

is $callback-called, 10, 'callback-called';
is $game-callback-called, 10, 'game-callback-called';


# vim: expandtab shiftwidth=4 ft=perl6
