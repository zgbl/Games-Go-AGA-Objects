################################################################################
# ABSTRACT:  tests for Games::Go::AGA::Objects::Directive
#
#   AUTHOR:  Reid Augustin
#    EMAIL:  reid@hellosix.com
#  CREATED:  04/07/2016 12:40:28 PM
################################################################################
use v6;

use Test;
plan 24;

# use-ok('Games::Go::AGA::Objects::Directive');          # the module under test
use Games::Go::AGA::Objects::Directive;     # the module under test

my $dut = Games::Go::AGA::Objects::Directive.new(
    key    => 'Aga-rated',
);
isa-ok($dut, 'Games::Go::AGA::Objects::Directive');
is $dut.key, 'Aga-rated',  q[key is 'Aga-rated'];
is $dut.value, '',  q[value is ''];
is $dut.gist, '## Aga-rated', 'gist OK';

$dut = Games::Go::AGA::Objects::Directive.new(
    key    => 'TEST',
    value  => 'test_value',
);
isa-ok($dut, 'Games::Go::AGA::Objects::Directive');
is $dut.gist, '## TEST test_value', 'gist OK';

is $dut.key, 'TEST',  q[key is 'TEST'];
is $dut.value, 'test_value',  q[value is 'test_value'];

$dut = Games::Go::AGA::Objects::Directive.new(
    key     => 'Test_2',
    value   => 'test_value_1 tv_2 TV_4',
    comment => "a comment\n but discard this part",
);

my $callback-called;
$dut.set-change-callback( method { $callback-called++ } );

is $dut.key, 'Test_2',  q[key is 'Test_2'];
is $dut.value, 'test_value_1 tv_2 TV_4',  q[value is good];
$dut.set-value('New Value');
is $dut.value, 'New Value',  q[new value is good];

is $dut.comment, '# a comment',  q[comment is '# a comment'];
$dut.set-comment('a comment');
is $dut.comment, '# a comment',  q[comment still '# a comment'];
$dut.set-comment('   #a comment');
is $dut.comment, '   #a comment',  q[comment now '   #a comment'];
is $dut.gist, '## Test_2 New Value    #a comment', 'gist is good';

is $dut.booleans, < Aga_rated Test >, 'default booleans';
is $dut.delete-boolean('AGA_RATED').booleans, 'Test', 'delete a boolean';
is $dut.add-boolean('foo').booleans, < Foo Test >, 'add a boolean';

is $dut.lists, < Date Online_registration >, 'default lists';
is $dut.delete-list('Online_registration').lists, 'Date', 'delete a list';
is $dut.add-list('foo').lists, < Date Foo >, 'add a list';

throws-like(
    {
        $dut = Games::Go::AGA::Objects::Directive.new(
            key    => 'key with spaces',
            value  => 'value',
        );
    },
    X::TypeCheck::Assignment,
);

is $dut.gist, '## Test_2 New Value    #a comment', 'gist is good';
is $callback-called, 3, 'callback called';
