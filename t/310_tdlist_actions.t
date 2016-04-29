################################################################################
# ABSTRACT:  tests for Games::Go::AGA::Objects::TDList::Grammar and Actions
#
#   AUTHOR:  Reid Augustin
#    EMAIL:  reid@hellosix.com
#  CREATED:  Thu Apr 21 11:54:38 PDT 2016
################################################################################
use v6;
use Test;
plan 6;

use Games::Go::AGA::Objects::TDList::Grammar;   # associated Grammar
use Games::Go::AGA::Objects::TDList::Actions;   #   and Actions
use Games::Go::AGA::Objects::TDListDB;          # TDList Database object

my @tdlist =
    'Last, First                    123 Full   -10.0   1/2/2003 ABCD CA             ',
    'Last2, First Middle           4567 Spons    4.9   1/1/1992 DEFG                ',
    'Last, First                   8910 Youth    0.0 12/12/2012      WI             ',
    'Corporation       6 7 CA',
    'Last3, First3 M.  4 5',
    'Last, First M.                1112 Full     0.0            HIJK WA             ';

my @match =
#      id     last-name      first-name      rating  club    state mem-type mem-date
    ( '123',  'Last',        'First',        '-10', 'ABCD', 'CA', 'Full',  '2003-01-02', ),
    ( '4567', 'Last2',       'First Middle', '4.9', 'DEFG', '',   'Spons', '1992-01-01', ),
    ( '8910', 'Last',        'First',        '0',   '',     'WI', 'Youth', '2012-12-12', ),
    ( '6',    'Corporation', '',             '7',   '',     'CA', '',      '',           ),
    ( '4',    'Last3',       'First3 M.',    '5',   '',     '',   '',      '',           ),
    ( '1112', 'Last',        'First M.',     '0',   'HIJK', 'WA', 'Full',  '',           );

my $tdlistdb = Games::Go::AGA::Objects::TDListDB.new(
    db-filename => 'test_DELETE_ME.sqlite'
);

for @tdlist -> $line {
    $tdlistdb.update-from-line($line);      # enter TDListN line into database
}

my $sth = $tdlistdb.sth-lib('select_by_id');
for 0 .. @tdlist.end -> $idx {
    my $match = @match[$idx];
    $sth.execute($match.[0]);               # ID, the primary key
    my $row = $sth.fetchall_arrayref[0];    # always just one row
    is $row, $match, "row $idx OK";
#say $row.perl, "\n", $match.perl, ;
}


