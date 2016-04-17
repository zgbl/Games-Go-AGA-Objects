################################################################################
# ABSTRACT:  tests for Games::Go::AGA::Objects::Game
#
#   AUTHOR:  Reid Augustin
#    EMAIL:  reid@hellosix.com
#  CREATED:  04/07/2016 12:40:28 PM
################################################################################
use v6;

use Test;
plan 5;

our $VERSION = '0.001'; # VERSION

# use-ok('Games::Go::AGA::Objects::Game');          # the module under test
use Games::Go::AGA::Objects::Game;     # the module under test
use Games::Go::AGA::Objects::Player;

my $dut = Games::Go::AGA::Objects::Game.new(
    white => Games::Go::AGA::Objects::Player.new(
        id         => 'Tst1',
        last-name  => 'Last',
        first-name => 'First 1',
        rank       => '3d',
    ),
    black => Games::Go::AGA::Objects::Player.new(
        id         => 'Tst22',
        last-name  => 'Last 2',
        first-name => 'First 2',
        rating     => 3.8,
        club       => 'PALO',
    ),
    komi  => 7.5.Num,
);
isa-ok($dut, 'Games::Go::AGA::Objects::Game');

is( $dut.black.id, 'TST22',  q[black ID is 'Tst22']);
is( $dut.white.last-name, 'Last',  q[white last-name is 'Last']);

my $callback-called;
$dut.set-change-callback( method { $callback-called++ } );

$dut.set-result('w');
is( $dut.winner.id, 'TST1', 'correct winner ID');
is( $callback-called, 1, 'callback called');
