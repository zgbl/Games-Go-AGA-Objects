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
    token TOP       {
        ^                           # start of string
            [ ^^                    # start of line within string
              \s*                   # optional leading whitespace
                [                   # group alternation of:
                       <directive>  # directive OR
                    || <comment>    # comment OR
                    || <player>     # player line OR
                    || <error>      # or else it's an error
                ]
              \N*                   # slurp to end of line (shouldn't be anything here)
              \n?                   # optional end of line
            ]*                      # repeat any number of times
        $                           # end of string
    }
    token directive      { '#' '#'+ \s* <key> [ \s+ <values=.to-eol> ]? }
        token key        { <key=.word> }
        token to-eol     { \N+ }
    token comment        { '#' <-[#]> \N* }
    token player         {  <id>
                           \s+ <last-name=.name>
                          [\s* \, \s* <first-name=.name>]?
                           \s+ [ <rank>|<rating> ]
                          [\s+ <flags>]?
                          [\s* <player-comment=.comment>]?
                         }
        token id         { <alpha>* \d+ }
        token alpha      { <[\w] - [\d]> }          # alphas without numeric
        token alphanum   { <[\w-]> }                # alphanumerics plus '_' and '-'
        token word       { <alpha> <alphanum>* }    # alpha followed by alphanums (normal words)
        token name       { [ \s* <alpha> \w* ]* }   # alpha followed by alphanums
        token rank       { \d+ <[dkDK]> }           # like 4k, 6D
        token rating     { '-'? \d+ \.? \d* }       # signed, decimal number
        token flags      { [ \s* <word> [ \=  <alphanum>+ ]? ]* }
    token error     { (\S .*) {say "Error: not directive, comment, or player: $0"} }
}
