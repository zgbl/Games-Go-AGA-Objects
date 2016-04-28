################################################################################
# ABSTRACT:  tests for Games::Go::AGA::Objects::Register
#
#   AUTHOR:  Reid Augustin
#    EMAIL:  reid@hellosix.com
#  CREATED:  04/07/2016 12:40:28 PM
################################################################################
use v6;
use Test;
plan 5;

use Games::Go::AGA::Objects::Register;          # the module under test

my $dut = Games::Go::AGA::Objects::Register.new(
    comments => (
        'pre-comment',
        'post pre-comment',
    ),
);

my $callback-called;
my &old-callback = $dut.change-callback;
$dut.set-change-callback(
    method {
        $dut.&old-callback();
        $callback-called++;
    }
);

is($dut.get-comments,
    (
        '# pre-comment',
        '# post pre-comment',
    ),
    'initial comments',
);

for (1 .. 5) -> $ii {
    my $hash = $ii % 2 ?? '' !! '# ';
    $dut.add-comment($hash ~ "comment $ii");
}
is($dut.get-comments, (
        '# pre-comment',
        '# post pre-comment',
        '# comment 1',
        '# comment 2',
        '# comment 3',
        '# comment 4',
        '# comment 5',
    ), 'add 5 comments',
);

$dut.delete-comment( rx/1||2||4/ );
is($dut.get-comments, (
        '# pre-comment',
        '# post pre-comment',
        '# comment 3',
        '# comment 5',
    ), 'remove 3 comments',
);

$dut.add-directive('AAA', 'Abc');
$dut.add-directive(
    Games::Go::AGA::Objects::Directive.new(
        key => 'BBbb',
        value => 'BbB bb bbb',
        comment => 'bbb comment',
    ),
);
$dut.set-directive('AccCcc', 'Ccc ccc ccC');
$dut.set-directive('bbbb', 'new bbb');
my $expect = (
    '# pre-comment',
    '# post pre-comment',
    '# comment 3',
    '# comment 5',
    '## AAA Abc',
    '## AccCcc Ccc ccc ccC',
    '## BBbb new bbb # bbb comment',
).join("\n");

is $dut.sprint, $expect, 'sprint OK';
is $callback-called, 10, 'callback-called';
