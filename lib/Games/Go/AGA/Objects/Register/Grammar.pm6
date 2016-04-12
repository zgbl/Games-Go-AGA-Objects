#!/usr/bin/env perl6
#===============================================================================
#     ABSTRACT:  perl 6 Grammar for AGA register.tde files
#
#       AUTHOR:  Reid Augustin
#        EMAIL:  reid@hellosix.com
#      CREATED:  04/07/2016 12:40:28 PM
#===============================================================================
use v6;
use Grammar::Tracer;

grammar Games::Go::AGA::Objects::Register::Grammar {
    token TOP       { ^ <line>* $ }
    token line      { ^^ \s* <directive> || <comment> || <player> || <error> \s* $$ }
    token comment   { '#' <-[#]> .* }
    token directive { '#' '#'+ \s* <key> .* }
        token key   { <alpha> \w* }
        token value { <-[\s,:;]>+ }
    token player    {  <id>
                      \s+ <last-name>
                     [\s* \, \s* <first-name>]?
                      \s+ <rank>|<rating>
                     [\s+ <flags>{say "got flags"}]?
                     [\s* <comment>]?
                    }
        token id         { {say 'id'}(<alpha>*){say "words $0"} (\d+){say "digits $1"} }
        token alphanum   { <[ \w \- ]> }      # add dash to alphanums
        token alpha      { <[\w] - [\d]> }   # alphas without numeric
        token last-name  { [ \s* <alpha> <[\w\-]>* ]* }   # alpha followed by alphanums
        token first-name { [ \s* <alpha> <[\w\-]>* ]* }   # alpha followed by alphanums
        token rank       { \d+ <[dkDK]> }       # like 4k, 6D
        token rating     { '-'? \d+ \.? \d* }   # signed, decimal number
        token flags      { [ \s* <key> [ \=  \w+ ]? ]* }    # reuse key/value?
    token error     { (\S .*) {say "Error: not directive, comment, or player: $0"} }
}
