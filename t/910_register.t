################################################################################
# ABSTRACT:  tests for Games::Go::AGA::Objects::Register
#
#   AUTHOR:  Reid Augustin
#    EMAIL:  reid@hellosix.com
#  CREATED:  04/07/2016 12:40:28 PM
################################################################################
use v6;
use Test;
plan 3;

our $VERSION = '0.001'; # VERSION

use Games::Go::AGA::Objects::Register;          # the module under test

my $register = Games::Go::AGA::Objects::Register.new(
    comments => (
        'pre-comment',
        'post pre-comment',
    ),
);
is($register.get-comments,
    (
        '# pre-comment',
        '# post pre-comment',
    ),
    'initial comments',
);

for (1 .. 5) -> $ii {
    my $hash = $ii % 2 ?? '' !! '# ';
    $register.add-comment($hash ~ "comment $ii");
}
is($register.get-comments, (
        '# pre-comment',
        '# post pre-comment',
        '# comment 1',
        '# comment 2',
        '# comment 3',
        '# comment 4',
        '# comment 5',
    ), 'add 5 comments',
);

$register.delete-comment( rx/1||2||4/ );
is($register.get-comments, (
        '# pre-comment',
        '# post pre-comment',
        '# comment 3',
        '# comment 5',
    ), 'add 5 comments',
);

