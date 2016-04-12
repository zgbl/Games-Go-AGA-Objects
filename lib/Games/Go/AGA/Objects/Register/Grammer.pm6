#!/usr/bin/env perl6
#===============================================================================
#     ABSTRACT:  perl 6 Grammer for AGA register.tde files
#
#       AUTHOR:  Reid Augustin
#        EMAIL:  reid@hellosix.com
#      CREATED:  04/07/2016 12:40:28 PM
#===============================================================================
use v6;

grammar Games::Go::AGA::Objects::Register::Grammer {
    token TOP       { ^ [^^ \s* <directive> | <comment> | <player> | <empty> \s* $$]* $ }

    token comment   { '#' <-[#]> .* }
    token directive { '#' '#'+ \s* <key> \s+ [<value> \s*  <[,:;]>* ]* }
        token key   { \w+ }
        token value { <-[\s,:;]>+ }
    token player    {  <id>
                      \s+ <last-name>
                     [\s* \, \s* <first-name>]?
                      \s+ <rank>|<rating>
                     [\s+ <flags>]?
                     [\s* <comment>]?
                    }
        token id         { \w* \d+ }
        token last-name  { [\s* <[\w] - [\d]> <[\w\-]>* ]* }   # alpha followed by alphanums
        token first-name { [\s* <[\w] - [\d]> <[\w\-]>* ]* }   # alpha followed by alphanums
        token rank       { << \d+ [dkDK] >> }   # like 4k, 6D
        token rating     { '-'? \d+ \.? \d* }   # signed, decimal number
        token flags      { [ <key> [\= <value>]? ]* }    # reuse key/value?
    token empty     { \S {say 'Error: not directive, comment, or player'} }
}
