
#===============================================================================
#  DESCRIPTION:  tests for Games::Go::AGA::Parse::Register
#
#       AUTHOR:  Reid Augustin
#        EMAIL:  reid@hellosix.com
#      CREATED:  04/07/2016 12:40:28 PM
#===============================================================================


our $VERSION = '0.001'; # VERSION

use Games::Go::AGA::Grammer::Register;   # the module under test

my @text = (
    "# comment\n",
);

for @text -> $text {
    my $match = Games::Go::AGA::Grammer::Register.parse($text);
    say $match.perl;
}



