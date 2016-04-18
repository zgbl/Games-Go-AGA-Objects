################################################################################
# ABSTRACT:  tests for Games::Go::AGA::Objects::Round
#
#   AUTHOR:  Reid Augustin
#    EMAIL:  reid@hellosix.com
#  CREATED:  04/07/2016 12:40:28 PM
################################################################################
use v6;

use Test;
plan 6;

our $VERSION = '0.001'; # VERSION

# use-ok('Games::Go::AGA::Objects::Round');          # the module under test
use Games::Go::AGA::Objects::Round;     # the module under test
use Games::Go::AGA::Objects::Game;      # Rounds contain Games

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
        white-id => 'Tst1',
        black-id => 'Tst22',
        komi  => 7.5.Num,
        change-callback => method { $dut.changed },
    ),
);
$dut.add-game(
    Games::Go::AGA::Objects::Game.new(
        white-id => 'Tst101',
        black-id => 'Tst1022',
        komi  => 0.5.Num,
        handi => 2,
        change-callback => method { $dut.changed },
    ),
);

$dut.get-game(0).set-result('w');
$dut.get-game('Tst1022', 'Tst101').set-result('b');
is $dut.get-game(0).winner, 'TST1',   'right winner in first game';
is $dut.get-game(1).loser,  'TST101', 'right loser in second game';
is $callback-called, 4, 'callback called';

