################################################################################
# ABSTRACT:  tests for Games::Go::AGA::Objects::Round
#
#   AUTHOR:  Reid Augustin
#    EMAIL:  reid@hellosix.com
#  CREATED:  04/07/2016 12:40:28 PM
################################################################################
use v6;

use Test;
plan 10;

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
    change-callback => sub { $callback-called++ },
);
$dut.add-game(
    Games::Go::AGA::Objects::Game.new(
        white-id => 'Tst1',
        black-id => 'Tst22',
        komi  => 7.5,
    ),
);
$dut.add-game(
    Games::Go::AGA::Objects::Game.new(
        white-id => 'Tst101',
        black-id => 'Tst1022',
        komi  => 0.5,
        handi => 2,
    ),
);
is $dut.sprint, "# Round 1\nTST1 TST22 ? 0 7.5\nTST101 TST1022 ? 0 0.5", 'sprint OK';

$dut.game(0).set-result('w');
$dut.game('Tst1022', 'Tst101').set-result('b');
is $dut.game(0).winner, 'TST1',   'right winner in first game';
is $dut.game('Tst1022').loser,  'TST101', 'right loser in second game';
is $callback-called, 4, 'callback called';
is $dut.sprint, "# Round 1\nTST1 TST22 w 0 7.5\nTST101 TST1022 b 0 0.5", 'sprint OK';

my $game0 = $dut.game(0);
my $game1 = $dut.game('TST1022');

$dut = Games::Go::AGA::Objects::Round.new(
    :round-number(1),
    :games( $game1, $game0 ),
);
is $callback-called, 4, 'callback called';
is $dut.game(0).white-id, 'TST101', 'pre-built games';

# vim: expandtab shiftwidth=4 ft=perl6
