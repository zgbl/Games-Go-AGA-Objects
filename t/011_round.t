################################################################################
# ABSTRACT:  tests for Games::Go::AGA::Objects::Round
#
#   AUTHOR:  Reid Augustin
#    EMAIL:  reid@hellosix.com
#  CREATED:  04/07/2016 12:40:28 PM
################################################################################
use v6;

use Test;
plan 14;

our $VERSION = '0.001'; # VERSION

# use-ok('Games::Go::AGA::Objects::Round');          # the module under test
use Games::Go::AGA::Objects::Round;     # the module under test

my $dut = Games::Go::AGA::Objects::Round.new(
    round-number  => 4,
);
isa-ok($dut, 'Games::Go::AGA::Objects::Round');
is $dut.get-next-table-number, 1, 'table 1';
is $dut.get-next-table-number, 2, 'table 2';

$dut = Games::Go::AGA::Objects::Round.new(
    round-number => 1
);

my $callback-called;
$dut.set-change-callback( method { $callback-called++ } );
is( $callback-called, 2, 'callback called');
