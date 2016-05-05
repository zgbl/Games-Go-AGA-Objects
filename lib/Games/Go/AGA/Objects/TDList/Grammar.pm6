#!/usr/bin/env perl6
#===============================================================================
#     ABSTRACT:  perl 6 Grammar for AGA TDList(N) files
#
#       AUTHOR:  Reid Augustin
#        EMAIL:  reid@hellosix.com
#      CREATED:  Wed Apr 20 12:49:10 PDT 2016
#===============================================================================
use v6;
# use Grammar::Tracer;   # include for debug help

grammar Games::Go::AGA::Objects::TDList::Grammar {
    token TOP {
        ^                           # start of string
            [                       # group alternation of:
                 <player>         # player OR
              || <error>          # or else it's an error
            ]
            \h*                     # slurp trailing whitespace
            \n?                     # optional end of line
        $                           # end of string
    }
    token player    {
                          \h* <last-name=.name>
                        [ \h* ',' \h* <first-name=.name> ]?
                          \h+ <id>
                        [ \h+ <membership-type=.word> ]?
                          \h+ <rank-or-rating>
                        [ \h+ <membership-date=.date> ]?
                        [ \h+ <club> ]?
                        [ \h+ <state> ]?
                    }
    token name           { <word> [\h+ <word>]* }
    token id             { \d+ }
    token rank-or-rating { <rank> | <rating> }
    token rank           { \d+ <[dkDK]> }           # like 4k, 6D
    token rating         { '-'? \d+ [ \. \d+ ]? }
    token date           { \d\d? <[-/]> \d\d? <[-/]> \d\d\d?\d? }
#   token alpha          { <[\w] - [\d]> }       # alphas without numeric
    token alphanum       { <[\w.-]> }            # alphanumerics plus '_' and a few extra chars
    token state          { <alpha> <alpha> }     # two letters
    token club           { <alpha> <alpha> <alpha> <alpha> } # four letters
    token word           { <alpha> <alphanum>* } # alpha followed by alphanums (normal words)
}

# vim: expandtab shiftwidth=4 ft=perl6
