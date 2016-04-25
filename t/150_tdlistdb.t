################################################################################
# ABSTRACT:  tests for Games::Go::AGA::Objects::TDListDB
#
#   AUTHOR:  Reid Augustin
#    EMAIL:  reid@hellosix.com
#  CREATED:  04/07/2016 12:40:28 PM
################################################################################
use v6;

use Test;
plan 5;

# use-ok('Games::Go::AGA::Objects::TDListDB');          # the module under test
use Games::Go::AGA::Objects::TDListDB;     # the module under test

my $col-types = (
    'id VARCHAR NOT NULL PRIMARY KEY',
    'last_name VARCHAR NOT NULL',
    'first_name VARCHAR',
    'rating VARCHAR',
    'club VARCHAR',
    'state VARCHAR',
    'membership_type VARCHAR',
    'membership_date VARCHAR',
).join(', ');
my $cols = (
    'id',
    'last_name',
    'first_name',
    'rating',
    'club',
    'state',
    'membership_type',
    'membership_date',
).join(', ');
my $u-qs = (
    'id = ?',
    'last_name = ?',
    'first_name = ?',
    'rating = ?',
    'club = ?',
    'state = ?',
    'membership_type = ?',
    'membership_date = ?',
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

$dut.my-print('Test my-print');
