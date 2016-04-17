################################################################################
# ABSTRACT:  tests for Games::Go::AGA::Objects::Round
#
#   AUTHOR:  Reid Augustin
#    EMAIL:  reid@hellosix.com
#  CREATED:  04/07/2016 12:40:28 PM
################################################################################
use v6;

use Test;
plan 4;

our $VERSION = '0.001'; # VERSION

# use-ok('Games::Go::AGA::Objects::Round');          # the module under test
use Games::Go::AGA::Objects::Round;     # the module under test

my $dut = Games::Go::AGA::Objects::Round.new(
    round-number  => 4,
);
isa-ok($dut, 'Games::Go::AGA::Objects::Round');
is $dut.get-next-table-number, 1, 'table 1';
is $dut.get-next-table-number, 2, 'table 2';

my $callback-called;
$dut = Games::Go::AGA::Objects::Round.new(
    round-number => 1,
    change-callback => method { $callback-called++ },
);
$dut.add-game(
    Games::Go::AGA::Objects::Game.new(
        white => Games::Go::AGA::Objects::Player.new(
            id         => 'Tst1',
            last-name  => 'Last1',
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
        change-callback => method { $dut.changed },
    ),
);

$dut.get-game(0).set-result('w');
is( $callback-called, 2, 'callback called');

