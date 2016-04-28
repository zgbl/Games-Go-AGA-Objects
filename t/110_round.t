################################################################################
# ABSTRACT:  tests for Games::Go::AGA::Objects::Round
#
#   AUTHOR:  Reid Augustin
#    EMAIL:  reid@hellosix.com
#  CREATED:  04/07/2016 12:40:28 PM
################################################################################
use v6;

use Test;
plan 8;

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
        komi  => 7.5,
        change-callback => method { $dut.changed },
    ),
);
$dut.add-game(
    Games::Go::AGA::Objects::Game.new(
        white-id => 'Tst101',
        black-id => 'Tst1022',
        komi  => 0.5,
        handi => 2,
        change-callback => method { $dut.changed },
    ),
);
is $dut.sprint, "# Round 1\nTST1 TST22 ? 0 7.5\nTST101 TST1022 ? 0 0.5", 'sprint OK';

$dut.get-game(0).set-result('w');
$dut.get-game('Tst1022', 'Tst101').set-result('b');
is $dut.get-game(0).winner, 'TST1',   'right winner in first game';
is $dut.get-game('Tst1022').loser,  'TST101', 'right loser in second game';
is $callback-called, 4, 'callback called';
is $dut.sprint, "# Round 1\nTST1 TST22 w 0 7.5\nTST101 TST1022 b 0 0.5", 'sprint OK';

