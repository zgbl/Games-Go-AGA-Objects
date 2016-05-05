################################################################################
# ABSTRACT:  tests for Games::Go::AGA::Objects::Register::Grammar and Actions
#
#   AUTHOR:  Reid Augustin
#    EMAIL:  reid@hellosix.com
#  CREATED:  04/12/2016 06:29:57 PM
################################################################################
use v6;
use Test;
plan 5;

use Games::Go::AGA::Objects::Register::Grammar; # associated Grammar
use Games::Go::AGA::Objects::Register::Actions; #   and Actions

my Pair @texts = (
       qq[# comment]
    => qq[# comment],
 
       qq[# several\n#\n #comments]
    => qq[# several\n#\n #comments],
 
       qq[## AGA\n  ## AGB \n#\n# comment\n##AGc with value \n## agd value # and comment ]
    => qq[#\n# comment\n## AGA\n## AGB\n## AGc with value\n## agd value # and comment],
 
       qq[Tmp001 Augustin, Reid  5d   Club=PALO BYE Drop3   #   what a poser!  ]
    => qq[TMP1 Augustin, Reid 5d Club=PALO BYE Drop3 #   what a poser!],
 
    qq:to/END/
        ## Tourney  Test  Tournament
        ## Date  2016/04/05
        ## Rounds  3
        ## AGA 
        # a comment
            # another comment   
        Tmp001 Augustin, Reid  5d Club=PALO BYE Drop3
        Tmp011 Augustin, Abc   4k    # with a comment
        USA011 Abc, Abc        4.4 DROP2  # 4 dan
        END
    =>
    qq:to/END/
        # a comment
        # another comment
        ## AGA
        ## Date 2016/04/05
        ## Rounds 3
        ## Tourney Test  Tournament
        TMP1 Augustin, Reid 5d Club=PALO BYE Drop3
        TMP11 Augustin, Abc 4k # with a comment
        USA11 Abc, Abc 4.4 DROP2 # 4 dan
        END
);

for @texts -> $pair {
    my $actions = Games::Go::AGA::Objects::Register::Actions.new();
    my $dut = Games::Go::AGA::Objects::Register::Grammar.parse($pair.key, :actions($actions)).ast;

    is($dut.sprint, $pair.value.chomp, 'sprint matches');
}

# vim: expandtab shiftwidth=4 ft=perl6
