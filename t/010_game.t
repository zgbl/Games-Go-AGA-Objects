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

my $dut = Games::Go::AGA::Objects::Game.new(
    white-id => 'Tst1',
    black-id => 'Tst22',
    komi     => 7.5.Num,
);
isa-ok($dut, 'Games::Go::AGA::Objects::Game');

is( $dut.black-id, 'TST22',  q[black ID]);
is( $dut.white-id, 'TST1',  q[white ID]);

my $callback-called;
$dut.set-change-callback( method { $callback-called++ } );

$dut.set-result('w');
is( $dut.winner, 'TST1', 'winner ID');
is( $callback-called, 1, 'callback called');
