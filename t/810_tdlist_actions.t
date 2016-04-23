################################################################################
# ABSTRACT:  tests for Games::Go::AGA::Objects::TDList::Grammar and Actions
#
#   AUTHOR:  Reid Augustin
#    EMAIL:  reid@hellosix.com
#  CREATED:  Thu Apr 21 11:54:38 PDT 2016
################################################################################
use v6;
use Test;
plan 1;

use Games::Go::AGA::Objects::TDList::Grammar;   # associated Grammar
use Games::Go::AGA::Objects::TDList::Actions;   #   and Actions
use Games::Go::AGA::Objects::TDListDB;          # TDList Database object

my Pair @pairs = (
    'Last, First                    123 Full   -10.0   1/2/2003 ABCD CA             '
#         id    last-name     first-name      rating  mem-date      mem-type club    state
    => ( 123,  'Last',        'First',        -10.0,  '1/2/2003',   'Full',  'ABCD', 'CA' ),
    'Last2, First Middle           4567 Spons    4.9   1/1/1992 DEFG                '
    => ( 4567, 'Last2',       'First Middle', 4.9,    '1/1/1992',   'Spons', 'DEFG', ''   ),
    'Last, First                   8910 Youth    0.0 12/12/2012      WI             '
    => ( 8910, 'Last',        'First',        0.0,    '12/12/2012', 'Youth', '',     'WI' ),
    'Corporation       6 7 CA'
    => ( 6,    'Corporation', '',             7,      '',           '',      '',     'CA' ),
    'Last3, First3 M.  4 5'
    => ( 4,    'Last3',       'First3 M',     5,      '',           '',      '',     ''   ),
    'Last, First M.                1112 Full     0.0            HIJK WA             '
    => ( 1112, 'Last',        'First M.',     0.0,    '',           'Full',  'HIJK', 'WA' ),
);

my $tdlistdb = Games::Go::AGA::Objects::TDListDB.new(
    dbdname => 'test_DELETE_ME.sqlite'
);

for @pairs -> $pair {
    $tdlistdb.update-from-line($pair.key);       # enter TDListN line into database
}

for @pairs -> $pair {
    my $match = $pair.value;
    my %rows = $tdlistdb.sth-lib('select_by_id').execute($match[0].Str).fetchall_hash;
    say %rows;
}


