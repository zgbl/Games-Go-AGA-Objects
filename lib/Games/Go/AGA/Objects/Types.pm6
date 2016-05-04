################################################################################
# ABSTRACT:  Collection of types for AGA Objects
#
#   AUTHOR:  Reid Augustin
#    EMAIL:  reid@hellosix.com
#  CREATED:  04/07/2016 12:40:28 PM
################################################################################
use v6;

unit module Games::Go::AGA::Objects::Types;

my package EXPORT::DEFAULT {
    subset Str-no-Space of Str where {
        m/^\S*$/
         #  or die 'no spaces allowed'
    };
    subset AGA-Id of Str where {
        m/^<[A..Za..z]>* <[1..9]>+\d*$/
         #  or die 'Invalid AGA ID (try .normalize-id?)'
    };
    subset Rank of Str where {
        m/^\d+<[kKdD]>$/
         #  or die 'Invalid Rank (expect like 4D or 3k)'
    };
    subset Rating of Rat where {
        ($_ >= 1 and $_ < 10) or ($_ <= -1 and $_ > -100) or ($_ == 0.0)
         #  or die 'Invalid Rating (expect -99.99 to -1 or 1 to 9.99)'
    };
    subset Rank-or-Rating where * ~~ Rank | Rating;
    subset Non-Neg-Int of Int where {
        (* >= 0)
         #  or die 'expect Int greater than or equal to 0'
    };
    subset Pos-Int of Int where {
        (* > 0)
         #  or die 'expect Int greater than 0'
    };
    subset Result of Str where {
        m/^<[wb?]>$/
         #  or die q[expect 'w', 'b', or '?' for Result]
    };
    subset Directive-Val of Str where {
        .match(/i<[#\n]>/).not
    }
    subset Comment of Str where {
        $_ eq '' || $_.match(/^ \h* '#' \N* $/)
    }
}

# vim: expandtab shiftwidth=4 ft=perl6
