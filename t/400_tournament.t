################################################################################
# ABSTRACT:  tests for Games::Go::AGA::Objects::Tournament
#
#   AUTHOR:  Reid Augustin
#    EMAIL:  reid@hellosix.com
#  CREATED:  04/07/2016 12:40:28 PM
################################################################################
use v6;
use Test;
plan 10;

use Games::Go::AGA::Objects::Directive;
use Games::Go::AGA::Objects::Player;
use Games::Go::AGA::Objects::Game;
use Games::Go::AGA::Objects::Round;
use Games::Go::AGA::Objects::Tournament;          # the module under test

my $dut = Games::Go::AGA::Objects::Tournament.new(
    :comments(['comment']),
    :directives( [
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
    ] ),
    :players( [
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
    ] ),
);

my $expect = (
    '# comment',
    '## DATE 2016/04/28 # date comment',
    '## Tourney Test Tournament 1 # tourney comment',
    'TST1 Last Name 1, First Name 1 4D Club=ABCD',
    'TST22 Last Name 22, First Name 22 5D Club=FooB Xyz=ABC',
).join("\n");

my $dut-callback-called = 0;
my $game-callback-called = 0;
my &old-callback = $dut.change-callback;
$dut.set-change-callback(
    sub {
        $dut-callback-called++;
        &old-callback();
    }
);

$dut.round(1).add-game( # 2 dut CHANGE (add round, add game)
    Games::Go::AGA::Objects::Game.new(
        white-id => 'TST1',
        black-id => 'TST22',
        komi     => 0.5,
        handicap => 2,
        change-callback => sub { $game-callback-called++ },
    )
);
is $dut-callback-called, 2, 'dut-callback-called';

$dut.add-player(    # dut CHANGE
    Games::Go::AGA::Objects::Player.new(
        id         => 'Tst003',
        last-name  => 'Last Name 3',
        first-name => 'First Name 3',
        rank       => '3D',
        flags      => 'Club=A333',
    ),
);

$dut.add-player(    # dut CHANGE
    Games::Go::AGA::Objects::Player.new(
        id         => 'TZZs04',
        last-name  => 'Last Name 4',
        first-name => 'First Name 4',
        rank       => '4k',
        flags      => 'Club=BB44',
    ),
);

my $game = Games::Go::AGA::Objects::Game.new(
    white-id => 'TZZS4',
    black-id => 'TST3',
    komi     => 7.5,
    handicap => 0,
    change-callback => sub { $game-callback-called++ },
);

$dut.round(1).add-game( $game );    # dut CHANGE, round CHANGE

$expect = join("\n",
    $expect,
    'TST3 Last Name 3, First Name 3 3D Club=A333',
    'TZZS4 Last Name 4, First Name 4 4k Club=BB44',
);
is $dut.sprint, $expect, 'sprint OK';

$dut.game(1, 0).set-result('w');    # game CHANGE, round CHANGE, dut CHANGE
is $dut.player-stats('defeated', 'TST1'), <TST22>, 'TST1 wins';
is $dut.player-stats('defeated', 'TST22'), [], 'TST22 wins';
is $dut.player-stats('defeated_by', 'TST1'), [], 'TST1 wins';
is $dut.player-stats('defeated_by', 'TST22'), <TST1>, 'TST22 wins';
$dut.game(1, 'TZZS4').set-result('w');  # game CHANGE, round CHANGE, dut CHANGE
is $dut.player-stats('defeated', 'TZZS4'), ['TST3'], 'TZZS4 wins';
is $dut.player-stats('defeated', 'TST3'), [], 'TST3 wins';

is $dut-callback-called, 7, 'dut-callback-called';
is $game-callback-called, 2, 'game-callback-called';


# vim: expandtab shiftwidth=4 ft=perl6
