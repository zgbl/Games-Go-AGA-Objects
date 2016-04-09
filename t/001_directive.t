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

my $d = Games::Go::AGA::Objects::Directive.new(
    key    => 'Test',
    values => 'test_value',
);
isa-ok($d, 'Games::Go::AGA::Objects::Directive');

ok( $d.key eq 'Test',  q[key is 'Test']);
ok( $d.values eq 'test_value',  q[value is 'test_value']);

$d = Games::Go::AGA::Objects::Directive.new(
    key    => 'Test_2',
    values => qw[ test_value_1 tv_2 TV_4 ],
);

ok( $d.key eq 'Test_2',  q[key is 'Test_2']);
ok( $d.values[0] eq 'test_value_1',  q[first value is 'test_value_1']);
ok( $d.values[1] eq 'tv_2',  q[second value is 'tv_2']);
ok( $d.values[2] eq 'TV_4',  q[third value is 'TV_4']);

ok($d.booleans ~~ qw[ TEST AGA_RATED ], 'default booleans');
ok($d.delete_boolean('AGA_RATED') ~~ 'TEST', 'deleted AGA_RATED boolean');
ok($d.add-boolean('Foo') ~~ qw[ TEST FOO ], 'added FOO boolean');

my $X;
try {
    $d = Games::Go::AGA::Objects::Directive.new(
        key    => 'key with spaces',
        values => 'value',
    );
    CATCH {
        default {
            $X = $_;    # save the exception
        }
    }
}
ok($X ~~ X::TypeCheck, 'exception on key with spaces');

try {
    $d = Games::Go::AGA::Objects::Directive.new(
        key    => 'key',
        values => 'value with-space',
    );
    CATCH {
        default {
            $X = $_;    # save the exception
        }
    }
}
ok($X ~~ X::TypeCheck, 'exception on value with space');

