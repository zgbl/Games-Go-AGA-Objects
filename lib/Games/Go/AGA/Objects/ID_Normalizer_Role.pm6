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
        if not ($id ~~ m:i/(<[a..z_]>*)0*(\d+)/) {
            die 'ID expects optional letters followed by digits like Tmp00123 or 444';
        }
        $/[0].uc ~ $/[1];
    }
}

=begin pod

=head1 SYNOPSIS

use Games::Go::AGA::Objects::ID_Normalizer_Role;

class My-Class
    does Games::Go::AGA::Objects::ID_Normalizer_Role {

=head1 DESCRIPTION

Games::Go::AGA::Objects::ID_Normalizer_Role contains the B<normalize-id>
method.

=item normalize-id ( Str $id )

Normalizes $id.  Finds a string within $id consisting of at least one
letter followed by at least one number.  Throws an exception if no such
string is found.  Returns the found string will all the letters
upper-cased.

=end pod

# vim: expandtab shiftwidth=4 ft=perl6
