#!/usr/bin/env perl6
#===============================================================================
#     ABSTRACT:  perl 6 Grammar for AGA Round (1.tde, 2.tde, etc) files
#
#       AUTHOR:  Reid Augustin
#        EMAIL:  reid@hellosix.com
#      CREATED:  Sun Apr 17 11:52:47 PDT 2016
#===============================================================================
use v6;
#use Grammar::Tracer;   # include for debug help

grammar Games::Go::AGA::Objects::Round::Grammar {
    token TOP       {
        ^                               # start of string
            [ ^^                        # start of line within string
                \h*                     # optional leading whitespace
                [                       # group alternation of:
                       <game>           # game OR
                    || <line-comment>   # comment OR
                    || <error>          # or else it's an error
                ]
                \N*                     # slurp to end of line
                \n?                     # optional end of line
            ]*                          # repeat any number of times
        $                               # end of string
    }
    token game     {
                        \h* <white-id=.word>
                        \h+ <black-id=.word>
                        \h+ <result>
                        \h+ <handicap>
                        \h+ <komi>
                      [ \h+ <game-comment=.comment> ]?
                   }
    token result   { w|b|W|B|\? }       # game result, white, black, or no-result
    token handicap { \d+ }              # stones of handicap: integer, usually less than 10
    token komi     { '-'? [ \d+ '.'? | \d* '.' \d+ ] }    # decimal number, possibly negative
    token comment  { '#' \N* }          # from hash to end of line
    token alpha    { <[\w] - [\d]> }    # alphas without numeric
    token alphanum { <[\w-]> }          # alphanumerics plus '_' and '-'
    token word     { <alpha> <alphanum>* }  # alpha followed by alphanums (normal words)
}

# vim: expandtab shiftwidth=4 ft=perl6
