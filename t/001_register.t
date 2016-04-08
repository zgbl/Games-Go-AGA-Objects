################################################################################
# ABSTRACT:  tests for Games::Go::AGA::Objects::Register
#
#   AUTHOR:  Reid Augustin
#    EMAIL:  reid@hellosix.com
#  CREATED:  04/07/2016 12:40:28 PM
################################################################################


our $VERSION = '0.001'; # VERSION

use Games::Go::AGA::Objects::Register;          # the module under test
use Games::Go::AGA::Objects::Register::Brammer; # associated Grammer

my @texts = (
    qq[# comment],
    qq[## AGA ]
    qq[## Rounds 5 ]
    qq[Tmp001 Augustin, Reid  5d Club=PALO BYE Drop3]

    qq:to/END/
        ## Tourney  Test Tournament
        ## Date  2016/04/05
        ## Rounds  3
        ## AGA 
        # a comment
            # another comment   
        Tmp001 Augustin, Reid  5d Club=PALO BYE Drop3
        Tmp011 Augustin, Abc   4k    # with a comment
        USA011 Abc, Abc        4.4   # 4 dan
        END
);

for @texts -> $text {
    my $match = Games::Go::AGA::Objects::Register::Grammer.parse($text);
    say $match.perl;
}



