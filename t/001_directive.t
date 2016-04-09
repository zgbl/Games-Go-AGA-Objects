################################################################################
# ABSTRACT:  tests for Games::Go::AGA::Objects::Directive
#
#   AUTHOR:  Reid Augustin
#    EMAIL:  reid@hellosix.com
#  CREATED:  04/07/2016 12:40:28 PM
################################################################################


our $VERSION = '0.001'; # VERSION

use Games::Go::AGA::Objects::Directive;          # the module under test

my $d = Games::Go::AGA::Objects::Directive.new(
    key    => 'Test',
    values => 'test_value',
);

say $d;

$d = Games::Go::AGA::Objects::Directive.new(
    key    => 'Test_2',
    values => qw[ test_value_1 tv_2 TV_4 ],
);

say $d;




