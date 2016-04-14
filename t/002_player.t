################################################################################
# ABSTRACT:  tests for Games::Go::AGA::Objects::Player
#
#   AUTHOR:  Reid Augustin
#    EMAIL:  reid@hellosix.com
#  CREATED:  04/07/2016 12:40:28 PM
################################################################################
use v6;

use Test;

our $VERSION = '0.001'; # VERSION

say 'AbCdEfG'.tclc;
# use-ok('Games::Go::AGA::Objects::Player');          # the module under test
use Games::Go::AGA::Objects::Player;     # the module under test

is(Games::Go::AGA::Objects::Player.normalize-id('Test001233'), 'TEST1233', 'normalize-id');
is(Games::Go::AGA::Objects::Player.rank-to-rating('5D'), 5.5, 'dan rank-to-rating');
is(Games::Go::AGA::Objects::Player.rank-to-rating('3k'), -3.5, 'kyu rank-to-rating');
is(Games::Go::AGA::Objects::Player.rating-to-rank(4.3), '4D', 'dan rating-to-rank');
is(Games::Go::AGA::Objects::Player.rating-to-rank(-15.3), '15K', 'kyu rating-to-rank');
throws-like({ Games::Go::AGA::Objects::Player.normalize-id('xxx') }, X::AdHoc );
throws-like({ Games::Go::AGA::Objects::Player.normalize-id('222') }, X::AdHoc );

my $p = Games::Go::AGA::Objects::Player.new(
    id        => 'Test001',
    last-name => 'test_value',
);
isa-ok($p, 'Games::Go::AGA::Objects::Player');

is( $p.id, 'TEST1',  q[id is 'TEST1']);
is( $p.last-name, 'test_value',  q[last-name is 'test_value']);

$p = Games::Go::AGA::Objects::Player.new(
    id         => 'Test2',
    last-name  => 'Last Name',
    first-name => 'First Name',
    rank       => '5D',
);
is( $p.rank, '5D', 'correct rank' );
is( $p.rating, 5.5, 'correct rating');

my $callback-called;
$p.set-change-callback( sub { $callback-called++ } );
$p.set-rating(-4.8);
is( $p.rank, '4K', 'correct rank');
$p.set-rating(4.8);
is( $p.rank, '4D', 'correct rank');
is( $callback-called, 2, 'callback called');
