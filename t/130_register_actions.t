################################################################################
# ABSTRACT:  tests for Games::Go::AGA::Objects::Register::Grammar
#
#   AUTHOR:  Reid Augustin
#    EMAIL:  reid@hellosix.com
#  CREATED:  04/12/2016 06:29:57 PM
################################################################################
use v6;
use Test;

our $VERSION = '0.001'; # VERSION

use Games::Go::AGA::Objects::Register::Grammar; # associated Grammar
use Games::Go::AGA::Objects::Register::Actions; #   and Actions

my @texts = (
    qq[# comment],
    qq[# several\n#\n #comments],
    qq[## AGA\n  ## AGB \n##AGc ],
    qq[## Dir1\n  ## Dir2  \n ##dir3 ],
    qq[## Ro-unds 5 ],
    qq[## Dir1 5\n ##Dir2 6 \n##    Dir3],
#   qq[Tmp001 Augustin, Reid  5d Club=PALO BYE Drop3],

#   qq:to/END/
#       ## Tourney  Test Tournament
#       ## Date  2016/04/05
#       ## Rounds  3
#       ## AGA 
#       # a comment
#           # another comment   
#       Tmp001 Augustin, Reid  5d Club=PALO BYE Drop3
#       Tmp011 Augustin, Abc   4k    # with a comment
#       USA011 Abc, Abc        4.4 DROP2  # 4 dan
#       END
);

for @texts -> $text {
    say "text: $text\n";
    my $actions = Games::Go::AGA::Objects::Register::Actions.new();
    my $register = Games::Go::AGA::Objects::Register::Grammar.parse($text, :actions($actions)).ast;
#   say "register.WHAT ", $register.WHAT;
    say "register.gist: ", $register.gist;
    say '';
}

