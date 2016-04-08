#!/usr/bin/env perl6
use v6;
#===============================================================================
#     ABSTRACT:  action object for Games::Go::AGA::Objects::Register::Grammer
#
#       AUTHOR:  Reid Augustin
#        EMAIL:  reid@hellosix.com
#      CREATED:  04/07/2016 12:40:28 PM
#===============================================================================

use Games::Go::AGA::Objects::Register::Grammer;

# an 'action object' for the parser.  use like this:
#   my $register = Games::Go::AGA::DataObjects::Register->new;
#   my $match = Games::Go::AGA::Objects::Register::Grammer.parse($string, :actions($register) );
class Games::Go::AGA::DataObjects::Register {
    method directive ($/) { $/.make: ~$/ }
    method comment   ($/) { $/.make: ~$/ }
    method player    ($/) { $/.make: ~$/ }
}
