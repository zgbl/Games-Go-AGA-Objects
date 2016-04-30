################################################################################
# ABSTRACT:  tests for Games::Go::AGA::Objects::Player
#
#   AUTHOR:  Reid Augustin
#    EMAIL:  reid@hellosix.com
#  CREATED:  04/07/2016 12:40:28 PM
################################################################################
use v6;

use Test;
plan 17;

our $VERSION = '0.001'; # VERSION

# use-ok('Games::Go::AGA::Objects::Player');          # the module under test
use Games::Go::AGA::Objects::Player;     # the module under test

is Games::Go::AGA::Objects::Player.normalize-id('Test001233'), 'TEST1233', 'normalize-id';
is Games::Go::AGA::Objects::Player.rank-to-rating('5D'), 5.5, 'dan rank-to-rating';
is Games::Go::AGA::Objects::Player.rank-to-rating('3k'), -3.5, 'kyu rank-to-rating';
is Games::Go::AGA::Objects::Player.rating-to-rank(4.3), '4D', 'dan rating-to-rank';
is Games::Go::AGA::Objects::Player.rating-to-rank(-15.3), '15K', 'kyu rating-to-rank';
throws-like({ Games::Go::AGA::Objects::Player.normalize-id('xxx') }, X::AdHoc );

my $dut = Games::Go::AGA::Objects::Player.new(
    id        => 'Test001',
    last-name => 'test_value',
);
isa-ok($dut, 'Games::Go::AGA::Objects::Player');

is $dut.id, 'TEST1',  q[id is 'TEST1'];
is $dut.last-name, 'test_value',  q[last-name is 'test_value'];
is $dut.sprint, 'TEST1 test_value <no-rank>', 'sprint OK';

$dut = Games::Go::AGA::Objects::Player.new(
    id         => 'Test2',
    last-name  => 'Last Name',
    first-name => 'First Name',
    rank       => '5D',
    flags      => 'Club=FooB Xyz=ABC',
);
is $dut.rank, '5D', 'correct rank' ;

my $callback-called;
$dut.set-change-callback( method { $callback-called++ } );
$dut.set-rating(-4.8);
is $dut.rating, -4.8, 'correct rating';
$dut.set-rank('4d');
is $dut.rank, '4D', 'correct rank';
is $dut.rating.so, False, 'rating Niled';
is $dut.sprint, 'TEST2 Last Name, First Name 4D Club=FooB Xyz=ABC', 'sprint OK';
is $dut.club, 'FooB', 'club OK';
is $callback-called, 2, 'callback called';

# vim: expandtab shiftwidth=4 ft=perl6
