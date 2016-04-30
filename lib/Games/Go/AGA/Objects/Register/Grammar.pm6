#!/usr/bin/env perl6
#===============================================================================
#     ABSTRACT:  perl 6 Grammar for AGA register.tde files
#
#       AUTHOR:  Reid Augustin
#        EMAIL:  reid@hellosix.com
#      CREATED:  04/07/2016 12:40:28 PM
#===============================================================================
use v6;
#use Grammar::Tracer;   # include for debug help

grammar Games::Go::AGA::Objects::Register::Grammar {
    token TOP       {
        ^                             # start of string
            [ ^^                      # start of line within string
              <line-space>*           # optional leading whitespace
                [                     # group alternation of:
                       <directive>    # directive OR
                    || <line-comment> # comment OR
                    || <player>       # player line OR
                    || <error>        # or else it's an error
                ]
              \N*                     # slurp to end of line (shouldn't be anything here)
              \n?                     # optional end of line
            ]*                        # repeat any number of times
        $                             # end of string
    }
    token directive      {
                            '#'
                            '#'+
                            <line-space>* <key>
                            [ <line-space>+ <value=.to-end> ]?
                            [ <line-space>* <directive-comment=.comment> ]?
                         }
        token key        { <key=.word> }
        token to-end     { <-[#\n]>* }
    token line-comment   { [ '#' <-[#]> \N* ] | '#' }    # full-line comment
    token player         {  <id>
                           <line-space>+ <last-name=.name>
                          [<line-space>* \, <line-space>* <first-name=.name> ]?
                           <line-space>+ [ <rank>|<rating> ] 
                          [<line-space>+ <flags> ]?
                          [<line-space>* <player-comment=.comment> ]?
                         }
        token id         { <alpha>* \d+ }
        token name       { [ <line-space>* <alpha> \w* ]* }   # alpha followed by alphanums
        token rank       { \d+ <[dkDK]> }           # like 4k, 6D
        token rating     { '-'? \d+ \.? \d* }       # signed, decimal number
        token flags      { <flag>+ }
        token flag       { <line-space>* <word> [ '=' <alphanum>+ ]? }
        token comment    { '#' \N* }                # from hash to end of line
        token alpha      { <[\w] - [\d]> }          # alphas without numeric
        token alphanum   { <[\w-]> }                # alphanumerics plus '_' and '-'
        token word       { <alpha> <alphanum>* }    # alpha followed by alphanums (normal words)
        token line-space { \h }                     # white-space without EOL (horizontal)
    token error     { (\S .*) {say "Error: not directive, comment, or player: $0"} }
}

# vim: expandtab shiftwidth=4 ft=perl6
