#!/usr/bin/perl
#===============================================================================
#      PODNAME:  Games::Go::AGA::Objects
#     ABSTRACT:  Objects and parsers for AGA Directive, Player, Game, Round, and Tournament
#
#       AUTHOR:  Reid Augustin (REID)
#        EMAIL:  reid@hellosix.com
#      CREATED:  Sat Apr 16 12:32:38 PDT 2016
#===============================================================================
use v6;

class Games::Go::AGA::Objects;

our $VERSION = '0.001'; # VERSION

=head1 SYNOPSIS

 use Games::Go::AGA::Objects;

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
to the AGA Ratings coordinator (send-to-AGA).

Also included are Grammars (parsers) which can generate objects directly from
AGA format files via their corresponding Actions:

    Register::Grammar
    Round::Grammar
    TDListDB::Grammar

=head1 SEE ALSO

=over

=item SeeMe

=back

