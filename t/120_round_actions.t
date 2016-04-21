################################################################################
# ABSTRACT:  tests for Games::Go::AGA::Objects::Round::Grammar and Actions
#
#   AUTHOR:  Reid Augustin
#    EMAIL:  reid@hellosix.com
#  CREATED:  Tue Apr 19 17:20:02 PDT 2016
################################################################################
use v6;
use Test;
plan 1;

use Games::Go::AGA::Objects::Round::Grammar; # associated Grammar
use Games::Go::AGA::Objects::Round::Actions; #   and Actions

my Pair @texts = (
    qq:to/END/
        USA94531 USA94557  w 0  0.5 #      Yao, Kevin (  4.500->  5.113) vs (  3.500->  3.732) Cho, Al
         USA4522 USA94558  b 0 -7.5 # Smith, Steve A. (  4.500->  3.816) vs (  3.500->  3.344) Tang, Gilbert
         USA4533 USA94549  w 0 -7.5 #    Chou, Andrew (  4.500->  4.559) vs (  3.500->  2.740) Yang, Dan
        USA94554 USA94571 b 0 -7.5  #       Liu, Dong (  2.500->  1.610) vs (  1.500->  1.253) Li, Sheryl
        END
    =>
    qq:to/END/
        # Round 0
        USA94531 USA94557 w 0 0.5
        USA4522 USA94558 b 0 -7.5
        USA4533 USA94549 w 0 -7.5
        USA94554 USA94571 b 0 -7.5
        END
);

for @texts -> $pair {
    my $actions = Games::Go::AGA::Objects::Round::Actions.new();
    my $round = Games::Go::AGA::Objects::Round::Grammar.parse($pair.key, :actions($actions)).ast;

    is($round.gist, $pair.value.chomp, 'gist matches');
}


