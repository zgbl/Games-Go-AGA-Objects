#!/usr/bin/env perl6
#===============================================================================
#      PODNAME:  Games::Go::AGA::Objects
#     ABSTRACT:  Objects and parsers for American Go Association files.
#
#       AUTHOR:  Reid Augustin (REID)
#        EMAIL:  reid@hellosix.com
#      CREATED:  Sat Apr 16 12:32:38 PDT 2016
#===============================================================================
use v6;

class Games::Go::AGA::Objects {
}

=begin pod

=head1 DESCRIPTION

Games::Go::AGA::Objects contains a collection of object definitions and
grammars (parsers) for various items defined by American Go Association
file formats.

Included are objects for:

    Directive
    Player
    Game
    Register    ( of comments, Directives and Players )
    Round       ( list of Games )
    Tournament  ( Register and a list of Rounds )
    TDListDB    ( TDList(n).txt in a database format )

Register and Round include methods to produce register.tde and Round.tde (1.tde,
2.tde, etc) files.  Tournament includes a method to produce the result file to send
to the AGA Ratings coordinator (send-to-aga).

Also included are Grammars (parsers) to generate objects directly from AGA
format files via their corresponding Actions:

    Register::Grammar Register::Actions
    Round::Grammar    Round::Actions
    TDListDB::Grammar TDListDB::Actions

=head1 SEE ALSO
=item Games::Go::AGA::Objects::Types
=item Games::Go::AGA::Objects::ID_Normalizer_Role
=item Games::Go::AGA::Objects::Directive
=item Games::Go::AGA::Objects::Player
=item Games::Go::AGA::Objects::Game
=item Games::Go::AGA::Objects::Register
=item Games::Go::AGA::Objects::Register::Grammar
=item Games::Go::AGA::Objects::Register::Actions
=item Games::Go::AGA::Objects::Round
=item Games::Go::AGA::Objects::Round::Grammar
=item Games::Go::AGA::Objects::Round::Actions
=item Games::Go::AGA::Objects::Tournament
=item Games::Go::AGA::Objects::TDListDB
=item Games::Go::AGA::Objects::TDList::Grammar
=item Games::Go::AGA::Objects::TDList::Actions

=end pod
