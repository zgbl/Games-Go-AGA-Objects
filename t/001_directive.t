################################################################################
# ABSTRACT:  tests for Games::Go::AGA::Objects::Directive
#
#   AUTHOR:  Reid Augustin
#    EMAIL:  reid@hellosix.com
#  CREATED:  04/07/2016 12:40:28 PM
################################################################################


use Test;

our $VERSION = '0.001'; # VERSION

# use-ok('Games::Go::AGA::Objects::Directive');          # the module under test
use Games::Go::AGA::Objects::Directive;     # the module under test

my $dut = Games::Go::AGA::Objects::Directive.new(
    key    => 'Test',
    values => 'test_value',
);
isa-ok($dut, 'Games::Go::AGA::Objects::Directive');

is( $dut.key, 'Test',  q[key is 'Test']);
is( $dut.values, 'test_value',  q[value is 'test_value']);

$dut = Games::Go::AGA::Objects::Directive.new(
    key    => 'Test_2',
    values => qw[ test_value_1 tv_2 TV_4 ],
);

my $callback-called;
$dut.set-change-callback( sub { $callback-called++ } );

is( $dut.key, 'Test_2',  q[key is 'Test_2']);
is( $dut.values[0], 'test_value_1',  q[first value is 'test_value_1']);
is( $dut.values[1], 'tv_2',  q[second value is 'tv_2']);
is( $dut.values[2], 'TV_4',  q[third value is 'TV_4']);

is($dut.booleans, qw[ TEST AGA_RATED ], 'default booleans');
is($dut.delete-boolean('AGA_RATED').booleans, 'TEST', 'delete a boolean');
is($dut.add-boolean('Foo').booleans, qw[ TEST FOO ], 'add a boolean');

throws-like(
    {
        $dut = Games::Go::AGA::Objects::Directive.new(
            key    => 'key with spaces',
            values => 'value',
        );
    },
    X::AdHoc
);
throws-like(
    {
        $dut = Games::Go::AGA::Objects::Directive.new(
            key    => 'key',
            values => 'value with spaces',
        );
    },
    X::AdHoc
);

