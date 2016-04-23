################################################################################
# ABSTRACT:  tests for Games::Go::AGA::Objects::TDListDB
#
#   AUTHOR:  Reid Augustin
#    EMAIL:  reid@hellosix.com
#  CREATED:  04/07/2016 12:40:28 PM
################################################################################
use v6;

use Test;
plan 8;

# use-ok('Games::Go::AGA::Objects::TDListDB');          # the module under test
use Games::Go::AGA::Objects::TDListDB;     # the module under test

my $col-types = (
    'last_name VARCHAR NOT NULL',
    'first_name VARCHAR',
    'id VARCHAR NOT NULL PRIMARY KEY',
    'membership-type VARCHAR',
    'rating VARCHAR',
    'membership-date VARCHAR',
    'club VARCHAR',
    'state VARCHAR',
).join(', ');
my $cols = (
    'last_name',
    'first_name',
    'id',
    'membership-type',
    'rating',
    'membership-date',
    'club',
    'state',
).join(', ');
my $u-qs = (
    'last_name = ?',
    'first_name = ?',
    'id = ?',
    'membership-type = ?',
    'rating = ?',
    'membership-date = ?',
    'club = ?',
    'state = ?',
).join(', ');
my $i-qs = (
    '?',
    '?',
    '?',
    '?',
    '?',
    '?',
    '?',
    '?',
).join(', ');

my $dut = Games::Go::AGA::Objects::TDListDB.new(
    db-filename => 'test_DELETE_ME.sqlite',
);
isa-ok($dut, 'Games::Go::AGA::Objects::TDListDB');
is $dut.sql-column-types, $col-types, 'sql-column-types';
is $dut.sql-columns, $cols, 'sql-columns';
is $dut.sql-update-qs, $u-qs, 'sql-update-qs';
is $dut.sql-insert-qs, $i-qs, 'sql-insert-qs';

is $dut.my-print('abc'), 'abc', 'my-print';
