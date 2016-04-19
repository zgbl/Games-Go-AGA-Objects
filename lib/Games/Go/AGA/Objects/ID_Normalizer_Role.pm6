#!/usr/bin/env perl6
################################################################################
# ABSTRACT:  Role to normalize AGA IDs
#
#   AUTHOR:  Reid Augustin
#    EMAIL:  reid@hellosix.com
#  CREATED:  04/07/2016 12:40:28 PM
################################################################################
use v6;

role Games::Go::AGA::Objects::ID_Normalizer_Role {
    method normalize-id ( Str $id ) is export(:DEFAULT) {
        # separate word part from number part,
        # remove leading zeros from digit part
        if not ($id ~~ m:i/(<[a..z_]>+)0*(\d+)/) {
            die 'ID expects letters followed by digits like Tmp00123';
        }
        $/[0].uc ~ $/[1];
    }
}
