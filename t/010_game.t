################################################################################
# ABSTRACT:  tests for Games::Go::AGA::Objects::Game
#
#   AUTHOR:  Reid Augustin
#    EMAIL:  reid@hellosix.com
#  CREATED:  04/07/2016 12:40:28 PM
################################################################################
use v6;

use Test;
plan 10;

our $VERSION = '0.001'; # VERSION

# use-ok('Games::Go::AGA::Objects::Game');          # the module under test
use Games::Go::AGA::Objects::Game;     # the module under test

my $callback-called;
my $dut = Games::Go::AGA::Objects::Game.new(
    white-id => 'Tst1',
    black-id => 'Tst22',
    komi     => 0.5,
    handicap => 2,
    change-callback => method { $callback-called++ },
);
isa-ok($dut, 'Games::Go::AGA::Objects::Game');

is $dut.black-id, 'TST22', 'black ID';
is $dut.white-id, 'TST1',  'white ID';
is $dut.winner,   False,   'no winner';
is $dut.loser,    False,   'no loser';
is $dut.gist, 'TST1 TST22 2 0.5 ?', 'gist OK';

$dut.set-table-number(3);
$dut.set-handicap(0);
$dut.set-komi(-6.5);
$dut.set-result('w');
$dut.set-white-adj(4.4);
is $dut.winner, 'TST1',  'winner ID';
is $dut.loser,  'TST22', 'loser ID';
is $dut.gist, 'TST1 TST22 0 -6.5 w # Tbl 3 adjusted ratings: 4.4, ?', 'gist OK';
is $callback-called, 5, 'callback called';
